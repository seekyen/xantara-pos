import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/features/reports/terminal_readings_screen.dart';
import 'package:pos_app/features/reports/daily_report_csv.dart';
import 'package:pos_app/features/reports/cash_drawer_panel.dart';
import 'package:pos_app/features/auth/providers/auth_provider.dart';
import 'package:pos_app/features/setup/company_setup_screen.dart';
import 'package:pos_app/features/pos/fnb/providers/pos_provider.dart'
    show localPosStoreProvider;
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  late AppDatabase db;
  late Directory dir;
  late CompanyRegistration company;
  late TerminalCloseoutRepository reports;
  late StaffAuthRepository staff;
  var paymentNo = 0;
  final clock = DateTime.utc(2026, 9, 30, 8);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('xz-readings-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    final registration = CompanyRegistrationRepository(db, staff: staff);
    company = await registration.register(fixture.setup());
    await registration.activate(
        email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    reports = TerminalCloseoutRepository(db, clock: () => clock, staff: staff);
    paymentNo = 0;
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  Future<String> sell(DateTime time) async {
    final base =
        fixture.sale(terminal: company.terminalId, actor: company.ownerId);
    final evidence =
        await CashPaymentGateway(createEvidenceId: () => 'pay-${paymentNo++}')
            .capture(PaymentRequest(
                idempotencyKey: 'sale-$paymentNo',
                amountCentavos: 11200,
                provider: PaymentProvider.cash,
                requestedAt: time,
                cashTenderedCentavos: 12000));
    final invoice = await OfflineSaleRepository(db).issueSale(
        OfflineSaleRequest(
            branchId: base.branchId,
            terminalId: base.terminalId,
            actorId: base.actorId,
            issuedAt: time,
            payment: evidence,
            sellerName: base.sellerName,
            sellerTin: base.sellerTin,
            sellerAddress: base.sellerAddress,
            registrationType: base.registrationType,
            softwareName: base.softwareName,
            softwareVersion: base.softwareVersion,
            lines: base.lines));
    return invoice.id;
  }

  Future<ReadingSnapshot> x(String day, {String? actor}) => reports.xReading(
      actorId: actor ?? company.ownerId,
      branchId: CompanyRegistration.branchId,
      terminalId: company.terminalId,
      day: day);
  Future<ReadingSnapshot> close(ReadingSnapshot reading,
          {String? actor, String password = fixture.password}) =>
      reports.closeDay(
          actorId: actor ?? company.ownerId,
          password: password,
          reviewed: reading);

  test(
      'X preserves invoice sequence; Z persists immutable totals and is idempotent',
      () async {
    await sell(DateTime.utc(2026, 9, 28, 5));
    final a = await x('2026-09-28');
    expect(a.totals['net'], 11200);
    expect(a.totals['vat'], 1200);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    expect(await db.customSelect('SELECT * FROM fiscal_z_readings').get(),
        isEmpty);
    final z = await close(a);
    expect(z.zNumber, 1);
    expect((await close(a)).data, z.data);
    final encoded = jsonEncode(z.data);
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db, clock: () => clock);
    final history = await reports.history(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId);
    expect(jsonEncode(history.single.data), encoded);
    await expectLater(
        db.customStatement("UPDATE fiscal_z_readings SET snapshot_json='{}'"),
        throwsA(anything));
    await expectLater(
        db.customStatement('DELETE FROM fiscal_z_readings'), throwsA(anything));
    await expectLater(db.customStatement('DELETE FROM fiscal_reading_events'),
        throwsA(anything));
  });

  Future<DailyJournalExport> journal(String day,
          {String? actor, String? branch}) =>
      reports.exportJournal(
          actorId: actor ?? company.ownerId,
          branchId: branch ?? CompanyRegistration.branchId,
          terminalId: company.terminalId,
          day: day);

  test(
      'journal preserves full originals and dates later voids and copies separately',
      () async {
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    await close(await x('2026-09-28'));
    final original = await journal('2026-09-28');
    expect(original.documentCount, 3);
    expect(original.reconstructedCount, 0);
    expect(original.text, contains('Product'));
    expect(original.text, contains('Cash Tendered'));
    expect(original.text, contains('RECONCILIATION: PASS'));
    await OfflineSaleRepository(db).queueInvoiceReprint(
        invoiceId: invoice,
        actorId: company.ownerId,
        requestedAt: DateTime.utc(2026, 9, 29, 4));
    await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
        invoiceId: invoice,
        actorId: company.ownerId,
        reason: 'Later adjustment',
        voidedAt: DateTime.utc(2026, 9, 29, 5)));
    expect((await journal('2026-09-28')).text, original.text);
    final later = await journal('2026-09-29');
    expect(later.documentCount, 2);
    expect(later.text, contains('invoice.reprint_requested'));
    expect(later.text, contains('invoice.voided'));
    expect(later.text, contains('Later adjustment'));
    expect(later.text, contains('Net PHP -112.00'));
    await reports.recordInvoicePdfCopy(
        actorId: company.ownerId, invoiceId: invoice);
    expect((await journal('2026-09-30')).text,
        contains('invoice.pdf_copy_requested'));
    await expectLater(
        db.customStatement('DELETE FROM journal_documents'), throwsA(anything));
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db, clock: () => clock);
    expect((await journal('2026-09-28')).text, original.text);
  });

  test(
      'journal v8 backfill is labelled and repeat exports do not duplicate documents',
      () async {
    await sell(DateTime.utc(2026, 9, 28, 5));
    await close(await x('2026-09-28'));
    await db.customStatement('DROP TABLE journal_documents');
    await db.customStatement('PRAGMA user_version=8');
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db, clock: () => clock);
    final result = await journal('2026-09-28');
    expect(result.documentCount, 3);
    expect(result.reconstructedCount, 3);
    expect(result.text, contains('RECONSTRUCTED FROM STORED RECORDS'));
    expect((await journal('2026-09-28')).text, result.text);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
  });

  test(
      'journal handles empty days and rejects unauthorized scope and damaged source totals',
      () async {
    expect(
        (await journal('2026-09-28')).text, contains('NO JOURNAL DOCUMENTS'));
    await expectLater(journal('2026-10-01'), throwsArgumentError);
    await expectLater(journal('2026-09-28', actor: 'unknown'),
        throwsA(isA<AuthorizationException>()));
    await expectLater(journal('2026-09-28', branch: 'not-assigned'),
        throwsA(isA<AuthorizationException>()));
    await sell(DateTime.utc(2026, 9, 28, 5));
    await db.customStatement('UPDATE invoices SET vat_amount_centavos=1');
    await expectLater(journal('2026-09-28'), throwsStateError);
  });

  test('journal failure rolls the sale, number and audit back together',
      () async {
    final auditCount = (await db.select(db.auditEvents).get()).length;
    await db.customStatement(
        "CREATE TRIGGER fail_journal BEFORE INSERT ON journal_documents BEGIN SELECT RAISE(ABORT,'test interrupted capture'); END");
    await expectLater(sell(DateTime.utc(2026, 9, 28, 5)), throwsA(anything));
    expect(await db.select(db.invoices).get(), isEmpty);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    expect((await db.select(db.auditEvents).get()).length, auditCount);
  });

  Future<void> cash(String kind, int amount,
      {String note = '',
      String? actor,
      ReadingSnapshot? reading,
      String password = fixture.password}) async {
    await reports.recordCash(
        actorId: actor ?? company.ownerId,
        reading: reading ?? await x('2026-09-28'),
        kind: kind,
        amountCentavos: amount,
        note: note,
        password: password);
  }

  test('cash float, movements, count, review and immutable Z survive reopening',
      () async {
    await cash('opening', 50000);
    await sell(DateTime.utc(2026, 9, 28, 5));
    await cash('cash_in', 1000, note: 'Additional float');
    await cash('cash_out', 500, note: 'Bank deposit slip 123');
    expect((await x('2026-09-28')).data['cashDrawer']['expected'], 61700);
    await expectLater(cash('count', 61600), throwsArgumentError);
    await cash('count', 61600, note: 'Short PHP 1.00; recounted twice');
    await expectLater(close(await x('2026-09-28')), throwsStateError);
    await expectLater(cash('review', 0, password: 'wrong'),
        throwsA(isA<AuthenticationException>()));
    await cash('review', 0);
    final z = await close(await x('2026-09-28'));
    expect(z.data['cashDrawer']['variance'], -100);
    expect(z.data['cashDrawer']['reviewed'], true);
    expect(dailyReportCsv(z),
        contains('"Overage (+) / shortage (-)","-1.00","PHP"'));
    expect(z.format(), contains('CASH DRAWER: Manager reviewed'));
    await expectLater(
        cash('cash_in', 10, reading: z, note: 'Closed'), throwsStateError);
    await expectLater(db.customStatement('DELETE FROM cash_drawer_events'),
        throwsA(anything));
    await expectLater(
        db.customStatement('UPDATE cash_drawer_events SET amount_centavos=0'),
        throwsA(anything));
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db,
        clock: () => clock, staff: StaffAuthRepository(db));
    final saved = await reports.history(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId);
    expect(saved.single.data['cashDrawer'], z.data['cashDrawer']);
    final audits = await db.select(db.auditEvents).get();
    expect(audits.where((e) => e.eventType.startsWith('cash_drawer.')),
        hasLength(5));
    final exported = await journal('2026-09-28');
    expect(exported.text, contains('cash_drawer.opening'));
    expect(exported.text, contains('cash_drawer.review'));
    expect(exported.text, contains('Bank deposit slip 123'));
    expect(exported.text, contains('RECONCILIATION: PASS'));
  });

  test(
      'voids require explicit refund payout and later changes invalidate count',
      () async {
    await cash('opening', 0);
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    await cash('count', 11200);
    await cash('review', 0);
    final stale = await x('2026-09-28');
    await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
        invoiceId: invoice,
        actorId: company.ownerId,
        reason: 'Returned',
        voidedAt: DateTime.utc(2026, 9, 28, 6)));
    final afterVoid = await x('2026-09-28');
    expect(afterVoid.data['cashDrawer']['expected'], 11200);
    expect(afterVoid.data['cashDrawer']['reviewed'], false);
    await expectLater(close(stale), throwsStateError);
    await expectLater(
        cash('refund', 11200, note: 'Receipt refund', reading: stale),
        throwsStateError);
    await cash('refund', 11200, note: 'Refund handed to customer for $invoice');
    expect((await x('2026-09-28')).data['cashDrawer']['expected'], 0);
    await cash('count', 0);
    await cash('review', 0);
    await cash('cash_in', 100, note: 'Additional float');
    expect((await x('2026-09-28')).data['cashDrawer']['reviewed'], false);
    await expectLater(close(await x('2026-09-28')), throwsStateError);
  });

  test(
      'cashier may count but not review; stale duplicate and branch access rejected',
      () async {
    final cashier = await staff.createStaff(CreateStaffRequest(
        displayName: 'Cashier',
        email: 'drawer@test.example',
        password: fixture.password,
        role: StaffRole.cashier,
        branchIds: {CompanyRegistration.branchId},
        createdBy: company.ownerId,
        createdAt: clock));
    final initial = await x('2026-09-28');
    await cash('opening', 0, actor: cashier, reading: initial);
    await expectLater(
        cash('opening', 0, actor: cashier, reading: initial), throwsStateError);
    await cash('count', 0, actor: cashier);
    await expectLater(cash('review', 0, actor: cashier),
        throwsA(isA<AuthorizationException>()));
    final wrongBranch =
        ReadingSnapshot({...initial.data, 'branchId': 'not-assigned'});
    await expectLater(cash('count', 0, actor: cashier, reading: wrongBranch),
        throwsA(isA<AuthorizationException>()));
    final days = await reports.openDays(
        actorId: cashier,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId);
    expect(days, contains('2026-09-28'));
    expect(await db.customSelect('SELECT * FROM cash_drawer_events').get(),
        hasLength(2));
  });

  test('v7 migration adds empty drawer ledger without changing prior invoices',
      () async {
    await sell(DateTime.utc(2026, 9, 28, 5));
    await db.customStatement('DROP TABLE cash_drawer_events');
    await db.customStatement('PRAGMA user_version=7');
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db,
        clock: () => clock, staff: StaffAuthRepository(db));
    final reading = await x('2026-09-28');
    expect(reading.totals['net'], 11200);
    expect(reading.data['cashDrawer']['started'], false);
    expect(await db.customSelect('SELECT * FROM cash_drawer_events').get(),
        isEmpty);
    await cash('opening', 0);
  });

  test('later-day void is a new adjustment and leaves the original Z unchanged',
      () async {
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    final z1 = await close(await x('2026-09-28'));
    await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
        invoiceId: invoice,
        actorId: company.ownerId,
        reason: 'Returned next day',
        voidedAt: DateTime.utc(2026, 9, 29, 5)));
    final adjustment = await x('2026-09-29');
    expect(adjustment.data['saleCount'], 0);
    expect(adjustment.data['voidCount'], 1);
    expect(adjustment.totals['net'], -11200);
    expect(adjustment.totals['vat'], -1200);
    expect(adjustment.data['payments'], {'cash': -11200});
    final z2 = await close(adjustment);
    expect(z2.zNumber, 2);
    expect(z2.data['oldGrandTotal'], 11200);
    expect(z2.data['newGrandTotal'], 0);
    final history = await reports.history(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId);
    expect(history.last.data, z1.data);
  });

  test('closed-day sale and void roll back and next day stays open', () async {
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    await close(await x('2026-09-28'));
    await expectLater(sell(DateTime.utc(2026, 9, 28, 6)), throwsA(anything));
    await expectLater(
        OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
            invoiceId: invoice,
            actorId: company.ownerId,
            reason: 'Too late for closed day',
            voidedAt: DateTime.utc(2026, 9, 28, 7))),
        throwsA(anything));
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    expect((await db.select(db.invoices).getSingle()).status, 'issued');
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 9);
    await sell(DateTime.utc(2026, 9, 29, 5));
    expect((await x('2026-09-29')).totals['net'], 11200);
  });

  test('stale review, missing earlier closeout and future dates are rejected',
      () async {
    await sell(DateTime.utc(2026, 9, 28, 5));
    final stale = await x('2026-09-28');
    await sell(DateTime.utc(2026, 9, 28, 6));
    await expectLater(close(stale), throwsStateError);
    await expectLater(close(await x('2026-09-29')), throwsStateError);
    await expectLater(x('2026-10-01'), throwsArgumentError);
    expect(await db.customSelect('SELECT * FROM fiscal_z_readings').get(),
        isEmpty);
  });

  test('cashier can view X but cannot close; password failure is retained',
      () async {
    final cashier = await staff.createStaff(CreateStaffRequest(
        displayName: 'Cashier',
        email: 'cash@test.example',
        password: fixture.password,
        role: StaffRole.cashier,
        branchIds: {CompanyRegistration.branchId},
        createdBy: company.ownerId,
        createdAt: clock));
    final reading = await x('2026-09-28', actor: cashier);
    await expectLater(
        close(reading, actor: cashier), throwsA(isA<AuthorizationException>()));
    await expectLater(close(reading, password: 'wrong'),
        throwsA(isA<AuthenticationException>()));
    expect(
        (await (db.select(db.staffUsers)
                  ..where((u) => u.id.equals(company.ownerId)))
                .getSingle())
            .failedLoginAttempts,
        1);
    await expectLater(
        reports.xReading(
            actorId: cashier,
            branchId: 'another-branch',
            terminalId: company.terminalId,
            day: '2026-09-28'),
        throwsA(isA<AuthorizationException>()));
  });

  test('Manila midnight groups sales and voids by event date', () async {
    await sell(DateTime.utc(2026, 9, 28, 15, 59, 59));
    await sell(DateTime.utc(2026, 9, 28, 16));
    expect((await x('2026-09-28')).data['saleCount'], 1);
    expect((await x('2026-09-29')).data['saleCount'], 1);
    expect(
        (await journal('2026-09-28')).text, contains('Issued: 1 | Voids: 0'));
    expect(
        (await journal('2026-09-29')).text, contains('Issued: 1 | Voids: 0'));
  });

  test('concurrent closes allocate one Z and same-day voids net to zero',
      () async {
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
        invoiceId: invoice,
        actorId: company.ownerId,
        reason: 'Same day',
        voidedAt: DateTime.utc(2026, 9, 28, 6)));
    final reading = await x('2026-09-28');
    expect(reading.data['saleCount'], 1);
    expect(reading.data['voidCount'], 1);
    expect(reading.totals['net'], 0);
    final saved = await Future.wait([close(reading), close(reading)]);
    expect(saved[0].data, saved[1].data);
    expect(await db.customSelect('SELECT * FROM fiscal_z_readings').get(),
        hasLength(1));
    await reports.recordOutputRequest(
        actorId: company.ownerId, reading: saved.first);
    await reports.recordOutputRequest(
        actorId: company.ownerId, reading: reading);
    final copies = await journal('2026-09-30');
    expect(copies.text, contains('reading.z_copy_requested'));
    expect(copies.text, contains('reading.x_copy_requested'));
    expect(
        (await db.select(db.auditEvents).get())
            .where((e) => e.eventType == 'reading.z_copy_requested'),
        hasLength(1));
  });

  test(
      'v6 migration backfills historical sales and later voids without changing invoices',
      () async {
    final invoice = await sell(DateTime.utc(2026, 9, 28, 5));
    await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
        invoiceId: invoice,
        actorId: company.ownerId,
        reason: 'Later void',
        voidedAt: DateTime.utc(2026, 9, 29, 5)));
    for (final trigger in [
      'fiscal_sale_day_guard',
      'fiscal_void_day_guard',
      'fiscal_sale_event',
      'fiscal_void_event'
    ]) {
      await db.customStatement('DROP TRIGGER $trigger');
    }
    await db.customStatement('DROP TABLE fiscal_reading_events');
    await db.customStatement('DROP TABLE fiscal_z_readings');
    await db.customStatement('PRAGMA user_version=6');
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    reports = TerminalCloseoutRepository(db, clock: () => clock);
    expect((await x('2026-09-28')).totals['net'], 11200);
    expect((await x('2026-09-29')).totals['net'], -11200);
    expect((await db.select(db.invoices).getSingle()).status, 'voided');
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
  });

  test('CSV matches open and closed snapshots without closing a day', () async {
    await sell(DateTime.utc(2026, 9, 28, 5));
    final reading = await x('2026-09-28');
    final csv = dailyReportCsv(reading);
    expect(csv, startsWith('\uFEFF'));
    expect(csv, contains('"Net sales","112.00","PHP"'));
    expect(csv, contains('"Net payments: cash","112.00","PHP"'));
    expect(csv, contains('Open / X snapshot'));
    expect(await db.customSelect('SELECT * FROM fiscal_z_readings').get(),
        isEmpty);
    final saved = await close(reading);
    expect(dailyReportCsv(saved), contains('Closed / Z #1'));
    final hostile = ReadingSnapshot({
      ...reading.data,
      'seller': {
        ...reading.data['seller'] as Map,
        'name': '=1+1',
        'branchCode': 'Shop, "North"\nSecond line',
      }
    });
    final escaped = dailyReportCsv(hostile);
    expect(escaped, contains('"Company","\'=1+1",""'));
    expect(escaped, contains('"Shop, ""North""\nSecond line"'));
    final negative = ReadingSnapshot({
      ...reading.data,
      'totals': {
        ...reading.totals,
        'net': -11225,
      }
    });
    expect(dailyReportCsv(negative), contains('"Net sales","-112.25","PHP"'));
  });

  testWidgets('phone report shows saved totals and requires review before Z',
      (tester) async {
    await tester.runAsync(() => sell(DateTime.utc(2026, 9, 28, 5)));
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      localPosStoreProvider.overrideWithValue(MemoryPosStore()),
      companyRegistrationProvider.overrideWith((ref) => company),
    ]);
    addTearDown(container.dispose);
    await tester.runAsync(() => container
        .read(authProvider.notifier)
        .login('owner@example.test', fixture.password));
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TerminalReadingsScreen())));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('End-of-day reports'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Download for Excel (CSV)'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Download for Excel (CSV)'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Save Z and close day'), 350,
        scrollable: find.byType(Scrollable).first);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Save Z and close day'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      expect(await db.customSelect('SELECT * FROM fiscal_z_readings').get(),
          isEmpty);
    });
  });

  testWidgets('cash entry validates decimal amounts before sending a command',
      (tester) async {
    final reading = await tester.runAsync(() => x('2026-09-28'));
    final commands = <List<Object>>[];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: CashDrawerPanel(
                    reading: reading!,
                    busy: false,
                    canRecord: true,
                    canReview: true,
                    onSave: (kind, amount, note, password) async =>
                        commands.add([kind, amount, note, password]))))));
    final amount = find.widgetWithText(TextField, 'Opening float (PHP)');
    await tester.enterText(amount, '12.345');
    await tester.ensureVisible(find.text('Save opening float'));
    await tester.tap(find.text('Save opening float'));
    await tester.pump();
    expect(commands, isEmpty);
    expect(find.textContaining('up to two decimal places'), findsOneWidget);
    await tester.enterText(amount, '500.25');
    await tester.tap(find.text('Save opening float'));
    await tester.pump();
    expect(commands.single, ['opening', 50025, '', '']);
    expect(tester.takeException(), isNull);
  });
}
