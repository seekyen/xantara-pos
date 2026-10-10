import 'dart:io';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/pricing/commercial_discounts.dart';
import 'package:pos_app/features/business_profiles/business_profile.dart';
import 'package:pos_app/features/reports/daily_report_csv.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/business_profile_repository.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/recovery_inspection_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'mixed-tax allocation is stable across cart order and conserves every centavo',
      () {
    final gross = {'vat': 11200, 'exempt': 3000, 'zero': 5000};
    expect(allocateCommercialDiscount(gross, 1920),
        {'vat': 1120, 'exempt': 300, 'zero': 500});
    for (final amount in [0, 1, 7, 1919, 19200]) {
      final a = allocateCommercialDiscount(gross, amount);
      final b = allocateCommercialDiscount(
          Map.fromEntries(gross.entries.toList().reversed), amount);
      expect(a, b);
      expect(a.values.reduce((a, b) => a + b), amount);
      for (final key in a.keys) {
        expect(a[key], inInclusiveRange(0, gross[key]!));
      }
    }
    expect(allocateCommercialDiscount({'z': 1, 'a': 1, 'b': 1}, 1),
        {'z': 0, 'a': 1, 'b': 0});
    expect(() => allocateCommercialDiscount(gross, 19201), throwsArgumentError);
  });
  test(
      'discount inputs preserve fractional percentage precision and reject fractional centavos',
      () {
    expect(commercialDiscountAmount(22400, '12.345', percentage: true), 2765);
    expect(commercialDiscountAmount(22400, '12.34', percentage: false), 1234);
    for (final bad in ['1.001', '1e2', 'NaN', '-1', '']) {
      expect(() => commercialDiscountAmount(22400, bad, percentage: false),
          throwsArgumentError);
    }
    expect(() => commercialDiscountAmount(22400, '100.01', percentage: true),
        throwsArgumentError);
  });
  test(
      'registered repository rejects demo promotion before changing fiscal data',
      () async {
    final db = AppDatabase(NativeDatabase.memory(), requireRegistration: true);
    addTearDown(db.close);
    final staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    final registration = CompanyRegistrationRepository(db, staff: staff);
    final company = await registration.register(fixture.setup());
    await registration.activate(
        email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    final before = await RecoveryInspectionRepository(db).checkpoint();
    await expectLater(
        OfflineSaleRepository(db).issueSale(fixture.sale(
            terminal: company.terminalId,
            actor: company.ownerId,
            demoPromotionCode: 'DISC200')),
        throwsStateError);
    expect(await RecoveryInspectionRepository(db).inspect(expected: before),
        isEmpty);
  });
  test(
      'closed file backup restores identity, Z, journal and next serial; stale/reused serial copies fail',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('xantara-restore-inspection-');
    final source = File('${directory.path}/source.sqlite');
    final backup = File('${directory.path}/backup.sqlite');
    var db = AppDatabase(NativeDatabase(source),
        requireRegistration: true, requireBusinessProfile: true);
    final staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    await BusinessProfileRepository(db)
        .initializeEmpty(BusinessCheckoutType.fnb);
    final reg = CompanyRegistrationRepository(db, staff: staff);
    final company = await reg.register(fixture.setup());
    await reg.activate(email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    final time = DateTime.utc(2026, 10, 10, 1);
    await OfflineSaleRepository(db).issueSale(fixture.sale(
        terminal: company.terminalId,
        actor: company.ownerId,
        checkoutType: 'fnb',
        issuedAt: time));
    final reports = TerminalCloseoutRepository(db,
        staff: staff, clock: () => time.add(const Duration(hours: 1)));
    final x = await reports.xReading(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        day: '2026-10-10');
    final z = await reports.closeDay(
        actorId: company.ownerId, password: fixture.password, reviewed: x);
    final csv = dailyReportCsv(z);
    expect(csv, contains('"TIN","123456789"'));
    expect(csv, contains('"PTU number","PTU-2026-001"'));
    expect(csv, isNot(contains('restaurant combined')));
    final checkpoint = await RecoveryInspectionRepository(db).checkpoint();
    await db.close();
    await source
        .copy(backup.path); // Closed database: WAL writes are checkpointed.
    final restoredFile = await backup.copy('${directory.path}/restored.sqlite');
    final restored = AppDatabase(NativeDatabase(restoredFile),
        requireRegistration: true, requireBusinessProfile: true);
    db = AppDatabase(NativeDatabase(source),
        requireRegistration: true, requireBusinessProfile: true);
    try {
      expect(
          await RecoveryInspectionRepository(restored)
              .inspect(expected: checkpoint),
          isEmpty);
      expect((await CompanyRegistrationRepository(restored).read())!.companyId,
          company.companyId);
      expect(await BusinessProfileRepository(restored).readType(),
          BusinessCheckoutType.fnb);
      expect(
          (await restored.select(restored.invoiceSequences).getSingle())
              .nextValue,
          43);
      await restored.customStatement(
          "CREATE TRIGGER inspection_interrupt BEFORE INSERT ON invoice_lines BEGIN SELECT RAISE(ABORT, 'Injected power-loss boundary'); END");
      await expectLater(
          OfflineSaleRepository(restored).issueSale(fixture.sale(
              terminal: company.terminalId,
              actor: company.ownerId,
              checkoutType: 'fnb',
              paymentId: 'pay-interrupted',
              issuedAt: time.add(const Duration(days: 1)))),
          throwsA(anything));
      await restored.customStatement('DROP TRIGGER inspection_interrupt');
      expect(
          await RecoveryInspectionRepository(restored)
              .inspect(expected: checkpoint),
          isEmpty);
      final restoredReports = TerminalCloseoutRepository(restored);
      final history = await restoredReports.history(
          actorId: company.ownerId,
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId);
      expect(jsonEncode(history.single.data), jsonEncode(z.data));
      final journal = await restoredReports.exportJournal(
          actorId: company.ownerId,
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId,
          day: '2026-10-10');
      expect(journal.text, contains('RECONCILIATION: PASS'));
      final next = await OfflineSaleRepository(db).issueSale(fixture.sale(
          terminal: company.terminalId,
          actor: company.ownerId,
          checkoutType: 'fnb',
          paymentId: 'pay-next',
          issuedAt: time.add(const Duration(days: 1))));
      expect(next.invoiceNumber, endsWith('00000043'));
      final current = await RecoveryInspectionRepository(db).checkpoint();
      final differences = await RecoveryInspectionRepository(restored)
          .inspect(expected: current);
      expect(differences, contains(contains('invoices')));
      expect(differences, contains(contains('invoice_sequences')));
      await restored
          .customStatement('UPDATE invoice_sequences SET next_value=42');
      expect(
          await RecoveryInspectionRepository(restored)
              .inspect(expected: checkpoint),
          contains(contains('reuse an issued serial')));
      final evidence = Platform.environment['RECOVERY_EVIDENCE_DIR'];
      if (evidence != null) {
        final folder = Directory(evidence)..createSync(recursive: true);
        File('${folder.path}/restore-check.json').writeAsStringSync(jsonEncode({
          'synthetic': true,
          'sourceSchema': checkpoint.schemaVersion,
          'tablesChecked': checkpoint.tables.length,
          'restoredZ': z.zNumber,
          'restoredNextSerial': 43,
          'sourceNextInvoice': next.invoiceNumber,
          'staleCopyRejected': true,
          'interruptedSaleRolledBack': true,
          'reusedSerialRejected': true,
          'physicalPrinterVerified': false,
          'liveRestoreAuthorized': false
        }));
        File('${folder.path}/restored-journal.txt')
            .writeAsStringSync(journal.text);
        File('${folder.path}/restored-z.csv').writeAsStringSync(csv);
      }
    } finally {
      await restored.close();
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
