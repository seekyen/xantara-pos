import 'dart:io';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/compliance/credit_note.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/credit_note_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'split returns conserve all original cents and tax, including tiny discounted lines',
      () {
    for (final price in [1, 5, 112, 11201]) {
      for (final tax in TaxCategory.values) {
        final line = BirInvoiceLine(
            productId: 'p',
            description: 'P',
            quantity: 7,
            unitPriceCentavos: price,
            discountCentavos: price,
            taxCategory: tax,
            vatReliefCentavos: tax == TaxCategory.vatExempt ? price : 0);
        final sum = <String, int>{};
        for (var i = 0; i < 7; i++) {
          final part = creditPortion(line, i, 1);
          expect(part.values.every((v) => v >= 0), true);
          expect(
              part['vatable']! +
                  part['vat']! +
                  part['exempt']! +
                  part['zero']! +
                  part['nonVat']!,
              part['total']);
          for (final e in part.entries) {
            sum[e.key] = (sum[e.key] ?? 0) + e.value;
          }
        }
        expect(sum, creditPortion(line, 0, 7));
        expect(sum['total'], line.netCentavos);
        expect(() => creditPortion(line, 6, 2), throwsArgumentError);
      }
    }
  });
  late AppDatabase db;
  late Directory dir;
  late CompanyRegistration company;
  late StaffAuthRepository staff;
  late CreditNoteRepository returns;
  late TerminalCloseoutRepository reports;
  late BirInvoice invoice;
  var now = DateTime.utc(2026, 10, 10, 1);
  setUp(() async {
    now = DateTime.utc(2026, 10, 10, 1);
    dir = await Directory.systemTemp.createTemp('credit-note-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    final reg = CompanyRegistrationRepository(db, staff: staff);
    company = await reg.register(fixture.setup());
    await reg.activate(email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    invoice = await OfflineSaleRepository(db).issueSale(OfflineSaleRequest(
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        actorId: company.ownerId,
        issuedAt: now,
        payment: PaymentEvidence(
            id: 'payment',
            provider: PaymentProvider.cash,
            status: PaymentStatus.captured,
            amountCentavos: 33600,
            reference: 'cash',
            authorizedAt: now,
            isOffline: true,
            cashTenderedCentavos: 33600,
            changeCentavos: 0),
        sellerName: 'unused',
        sellerTin: 'unused',
        sellerAddress: 'unused',
        registrationType: TaxRegistrationType.vat,
        softwareName: 'POS',
        softwareVersion: '1',
        lines: const [OfflineSaleLineRequest(productId: 'p', quantity: 3)]));
    returns = CreditNoteRepository(db, staff: staff, clock: () => now);
    reports = TerminalCloseoutRepository(db, staff: staff, clock: () => now);
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  Future<ReadingSnapshot> x() => reports.xReading(
      actorId: company.ownerId,
      branchId: CompanyRegistration.branchId,
      terminalId: company.terminalId,
      day: manilaBusinessDay(now));
  Future<void> open() async => reports.recordCash(
      actorId: company.ownerId,
      reading: await x(),
      kind: 'opening',
      amountCentavos: 50000,
      note: 'Float');
  Future<Map<String, dynamic>> issue(
      {String key = 'r1',
      int quantity = 1,
      bool restock = true,
      int? expected,
      String? email,
      String? actor}) async {
    final line = (await db.select(db.invoiceLines).getSingle()).id;
    return returns.issue(
        invoiceId: invoice.id,
        actorId: actor ?? company.ownerId,
        supervisorEmail: email ?? 'owner@example.test',
        supervisorPassword: fixture.password,
        requestKey: key,
        reason: 'Returned item',
        lines: [ReturnLineRequest(line, quantity, restock: restock)],
        expectedTotalCentavos: expected ?? quantity * 11200,
        cashRefundConfirmed: true);
  }

  test(
      'partial return preserves invoice, restocks once, links one refund and survives restart',
      () async {
    await open();
    final original = await db.select(db.invoices).getSingle();
    final result = await issue();
    expect(result['number'], contains('CN-00000001'));
    expect((await issue())['id'], result['id']);
    expect(
        (await db.select(db.invoices).getSingle()).toJson(), original.toJson());
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 8);
    final refunds = await db
        .customSelect("SELECT * FROM cash_drawer_events WHERE kind='refund'")
        .get();
    expect(refunds, hasLength(1));
    expect(
        (jsonDecode(refunds.single.read<String>('payload_json'))
            as Map)['creditNoteId'],
        result['id']);
    final reading = await x();
    expect(reading.totals['net'], 22400);
    expect(reading.totals['vat'], 2400);
    expect(reading.data['creditNoteTotal'], 11200);
    expect((reading.data['cashDrawer'] as Map)['expected'], 72400);
    final journal = await reports.exportJournal(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        day: '2026-10-10');
    expect(journal.text, contains('RECONCILIATION: PASS'));
    expect(journal.text, contains('CREDIT NOTE'));
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    final reopened = CreditNoteRepository(db, clock: () => now);
    final context =
        await reopened.inspect(invoiceId: invoice.id, actorId: company.ownerId);
    expect(context.notes.single, result);
    expect(context.returned.values.single, 1);
    expect(
        await reopened.copyText(
            noteId: result['id'] as String, actorId: company.ownerId),
        contains('CREDIT NOTE COPY'));
  });
  test(
      'full return does not restock damaged goods and cannot be repeated or voided',
      () async {
    await open();
    await issue(quantity: 3, restock: false);
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 7);
    expect((await x()).totals['net'], 0);
    await expectLater(issue(key: 'excess'), throwsArgumentError);
    await expectLater(issue(key: 'r1', quantity: 2), throwsStateError);
    await expectLater(
        OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
            invoiceId: invoice.id,
            actorId: company.ownerId,
            reason: 'Do not double reverse',
            voidedAt: now)),
        throwsStateError);
    expect(await db.customSelect('SELECT * FROM credit_notes').get(),
        hasLength(1));
  });
  test(
      'closed original Z remains unchanged; next-day credit affects its own day and invalidates count',
      () async {
    final originalZ = await reports.closeDay(
        actorId: company.ownerId,
        password: fixture.password,
        reviewed: await x());
    now = now.add(const Duration(days: 1));
    await open();
    await reports.recordCash(
        actorId: company.ownerId,
        reading: await x(),
        kind: 'count',
        amountCentavos: 50000,
        note: '');
    final before = await x();
    await issue();
    final after = await x();
    expect(after.totals['net'], -11200);
    expect(after.totals['vat'], -1200);
    expect((after.data['cashDrawer'] as Map)['countFresh'], false);
    await expectLater(
        reports.closeDay(
            actorId: company.ownerId,
            password: fixture.password,
            reviewed: before),
        throwsStateError);
    final saved = await reports.history(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId);
    expect(saved.single.data, originalZ.data);
    expect(
        (await reports.exportJournal(
                actorId: company.ownerId,
                branchId: CompanyRegistration.branchId,
                terminalId: company.terminalId,
                day: manilaBusinessDay(now)))
            .text,
        contains('RECONCILIATION: PASS'));
  });
  test(
      'cashier cannot self-authorize, missing drawer/stale amount fail before credit mutation',
      () async {
    final cashier = await staff.createStaff(CreateStaffRequest(
        displayName: 'Cashier',
        email: 'cashier@example.test',
        role: StaffRole.cashier,
        password: fixture.password,
        branchIds: {CompanyRegistration.branchId},
        createdBy: company.ownerId,
        createdAt: now));
    await expectLater(issue(actor: cashier, email: 'cashier@example.test'),
        throwsA(isA<AuthorizationException>()));
    await expectLater(issue(), throwsStateError);
    await open();
    await expectLater(issue(expected: 1), throwsStateError);
    expect(await db.customSelect('SELECT * FROM credit_notes').get(), isEmpty);
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 7);
  });
  test('interrupted refund rolls back credit sequence, inventory and outbox',
      () async {
    await open();
    await db.customStatement(
        "CREATE TRIGGER stop_refund BEFORE INSERT ON cash_drawer_events WHEN NEW.kind='refund' BEGIN SELECT RAISE(ABORT,'interrupted'); END");
    await expectLater(issue(), throwsA(anything));
    expect(await db.customSelect('SELECT * FROM credit_notes').get(), isEmpty);
    expect(await db.customSelect('SELECT * FROM credit_note_sequences').get(),
        isEmpty);
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 7);
    expect(
        (await db.select(db.syncOutboxEvents).get())
            .where((e) => e.eventType == 'credit_note.issued'),
        isEmpty);
    await db.customStatement('DROP TRIGGER stop_refund');
    expect((await issue())['number'], contains('CN-00000001'));
  });
  test('v12 upgrade preserves invoice serial and adds empty credit-note tables',
      () async {
    for (final trigger in [
      'credit_notes_no_update',
      'credit_notes_no_delete',
      'credit_note_day_guard',
      'invoice_return_void_guard'
    ]) {
      await db.customStatement('DROP TRIGGER $trigger');
    }
    await db.customStatement('DROP INDEX cash_credit_note_once');
    await db.customStatement('DROP TABLE credit_notes');
    await db.customStatement('DROP TABLE credit_note_sequences');
    await db.customStatement('PRAGMA user_version=12');
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    expect(await db.customSelect('SELECT * FROM credit_notes').get(), isEmpty);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    expect((await db.select(db.invoices).getSingle()).totalCentavos, 33600);
  });
}
