import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/features/auth/providers/auth_provider.dart';
import 'package:pos_app/features/checkout/providers/loyalty_provider.dart';
import 'package:pos_app/features/checkout/screens/checkout_screen.dart';
import 'package:pos_app/features/pos/fnb/providers/cart_provider.dart';
import 'package:pos_app/features/pos/fnb/providers/pos_provider.dart' as pos;
import 'package:pos_app/features/setup/company_setup_screen.dart';
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/invoice_particulars_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/hardware_job_processor.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  for (final hardwareFailure in [false, true]) {
    testWidgets(
        'F&B saves buyer and preview with hardware failure: $hardwareFailure',
        (tester) async {
      tester.view.physicalSize = const Size(1100, 1700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database =
          AppDatabase(NativeDatabase.memory(), requireRegistration: true);
      addTearDown(database.close);
      final registration = CompanyRegistrationRepository(database,
          staff: StaffAuthRepository(database,
              passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
      final profile = await tester.runAsync(() async {
        final p = await registration.register(fixture.setup());
        await registration.activate(
            email: 'owner@example.test', password: fixture.password);
        await fixture.stock(database);
        return p;
      });
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(database),
        pos.localPosStoreProvider.overrideWithValue(MemoryPosStore()),
        companyRegistrationProvider.overrideWith((ref) => profile),
        if (hardwareFailure)
          hardwareJobProcessorProvider
              .overrideWithValue(_UnavailableProcessor(database)),
        loyaltyRulesProvider.overrideWith((ref) => Stream.value([]))
      ]);
      addTearDown(container.dispose);
      await tester.runAsync(() => container
          .read(authProvider.notifier)
          .login('owner@example.test', fixture.password));
      container.read(cartProvider.notifier).addItem(const pos.Product(
          id: 'p',
          name: 'Product',
          price: 112,
          categoryId: 'test',
          color: Colors.blue));
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
              home: Scaffold(
                  body: Builder(
                      builder: (context) => TextButton(
                          onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const CheckoutScreen()),
                          child: const Text('Checkout')))))));
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      final promo = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.hintText == 'Promo code...');
      await tester.ensureVisible(promo);
      await tester.enterText(promo, 'DISC200');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
          find.text(
              'Demo promotions are only available in the training workspace.'),
          findsOneWidget);
      expect(find.textContaining('Promo applied:'), findsNothing);
      await tester.ensureVisible(find.text('Proceed to Payment'));
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      for (final e in {
        'name': 'F&B Business',
        'tin': '123456789',
        'address': 'Buyer office'
      }.entries) {
        final f = find.byKey(ValueKey('invoice-buyer-${e.key}'));
        await tester.ensureVisible(f);
        await tester.enterText(f, e.value);
      }
      final cash = find.byKey(const ValueKey('fnb-cash-received'));
      await tester.ensureVisible(cash);
      await tester.enterText(cash, '200');
      await tester.pump();
      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirm Payment · ₱112.00'));
      for (var i = 0;
          i < 8 && find.text('Sale saved').evaluate().isEmpty;
          i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pumpAndSettle();
      }
      expect(find.text('Sale saved'), findsOneWidget);
      final saved = await tester.runAsync(() => OfflineSaleRepository(database)
          .watchSales(branchId: CompanyRegistration.branchId)
          .first);
      expect(saved, hasLength(1));
      expect(saved!.single.invoice.buyer!.registeredName, 'F&B Business');
      final expected = const BirReceiptFormatter().format(ReceiptPrintData(
          invoice: saved.single.invoice,
          payment: saved.single.payment,
          cashierName: 'Company Owner',
          isReprint: false));
      expect(tester.widget<SelectableText>(find.byType(SelectableText)).data,
          expected);
      expect(tester.takeException(), isNull);
    });
  }
  late AppDatabase db;
  late Directory dir;
  late CompanyRegistration company;
  late InvoiceParticularsRepository particulars;
  const buyer = BirBuyerDetails(
      registeredName: '  Business Buyer  ',
      tin: '123-456-789-00000',
      address: 'Buyer registered address',
      isBusiness: true);
  final footer = <String, String>{
    'supplierName': 'Test Supplier',
    'supplierAddress': 'Test Address',
    'supplierTin': '123-456-789-00000',
    'accreditationNumber': 'TEST-ACC',
    'accreditationIssuedOn': '2026-01-01',
    'accreditationValidUntil': '2027-01-01'
  };
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('invoice-fields-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    final staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    final registration = CompanyRegistrationRepository(db, staff: staff);
    company = await registration.register(fixture.setup());
    await registration.activate(
        email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    particulars = InvoiceParticularsRepository(db, staff: staff);
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  Future<void> save(Map<String, String> values) => particulars.saveFooter(
      email: 'owner@example.test', password: fixture.password, values: values);

  test(
      'business buyer validation rejects incomplete details without consuming a serial',
      () async {
    await expectLater(
        OfflineSaleRepository(db).issueSale(fixture.sale(
            terminal: company.terminalId,
            actor: company.ownerId,
            buyer: const BirBuyerDetails(
                registeredName: 'Business', isBusiness: true))),
        throwsA(isA<BirInvoiceValidationException>()));
    expect(await db.select(db.invoices).get(), isEmpty);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    expect(await db.customSelect('SELECT * FROM invoice_particulars').get(),
        isEmpty);
  });
  test('buyer and supplier snapshots survive restart and later footer changes',
      () async {
    await save(footer);
    final invoice = await OfflineSaleRepository(db).issueSale(fixture.sale(
        terminal: company.terminalId, actor: company.ownerId, buyer: buyer));
    expect(invoice.buyer!.registeredName, 'Business Buyer');
    await save({...footer, 'supplierName': 'Future Supplier'});
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    final record = (await OfflineSaleRepository(db)
            .watchSales(branchId: CompanyRegistration.branchId)
            .first)
        .single;
    expect(record.invoice.buyer!.isBusiness, true);
    expect(
        record.invoice.seller.invoiceFooter['supplierName'], 'Test Supplier');
    final text = const BirReceiptFormatter().format(ReceiptPrintData(
        invoice: record.invoice,
        payment: record.payment,
        cashierName: 'Owner',
        isReprint: true,
        reprintedAt: DateTime.now()));
    for (final value in [
      'VAT REG TIN: 123-456-789-00000',
      'Buyer: Business Buyer',
      'Buyer TIN: 123-456-789-00000',
      'Buyer Address: Buyer registered address',
      'PTU issued: 2026-09-01',
      'Supplier: Test Supplier',
      'REPRINT ONLY'
    ]) {
      expect(text, contains(value));
    }
    expect(text, isNot(contains('Future Supplier')));
    // Exercise the actual queued reprint loader after reopening, not only the formatter.
    final printer = _CapturedPrinter();
    final processor = HardwareJobProcessor(
        database: db, printer: printer, cashDrawer: _TestDrawer());
    await OfflineSaleRepository(db).queueInvoiceReprint(
        invoiceId: invoice.id,
        actorId: company.ownerId,
        requestedAt: DateTime.now());
    for (var i = 0; i < 5; i++) {
      if (!(await processor.processNext(DateTime.now())).processed) break;
    }
    final reprint =
        printer.receipts.singleWhere((s) => s.contains('REPRINT ONLY'));
    expect(reprint, contains('Buyer: Business Buyer'));
    expect(reprint, contains('Supplier: Test Supplier'));
    expect(reprint, isNot(contains('Future Supplier')));
    final journal = await TerminalCloseoutRepository(db).exportJournal(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        day: manilaBusinessDay(DateTime.now()));
    expect(journal.text, contains('Buyer: Business Buyer'));
    expect(journal.text, contains('Supplier: Test Supplier'));
    expect(journal.text, contains('RECONCILIATION: PASS'));
    await expectLater(
        db.customStatement("UPDATE invoice_particulars SET data_json='{}'"),
        throwsA(anything));
    await expectLater(db.customStatement('DELETE FROM invoice_particulars'),
        throwsA(anything));
  });
  test('footer rejects bad credentials and incomplete or invalid particulars',
      () async {
    await expectLater(
        particulars.saveFooter(
            email: 'owner@example.test', password: 'wrong', values: footer),
        throwsA(anything));
    await expectLater(
        save({...footer, 'supplierTin': 'x'}), throwsArgumentError);
    await expectLater(
        save({...footer, 'supplierAddress': ''}), throwsArgumentError);
    await expectLater(save({...footer, 'accreditationIssuedOn': '2026-02-30'}),
        throwsArgumentError);
    expect(await particulars.footer(), isEmpty);
  });
  test(
      'v9 upgrade creates empty particulars without inventing historical footer data',
      () async {
    await db.customStatement('DROP TABLE invoice_particulars');
    await db.customStatement('DROP TABLE invoice_footer_config');
    await db.customStatement('PRAGMA user_version=9');
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/pos.sqlite')),
        requireRegistration: true);
    expect(await db.customSelect('SELECT * FROM invoice_particulars').get(),
        isEmpty);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    expect((await CompanyRegistrationRepository(db).read())!.companyId,
        company.companyId);
  });
  test(
      'buyer validation accepts personal names and rejects malformed TIN or control text',
      () {
    expect(
        const BirBuyerDetails(registeredName: 'Personal customer').validate(),
        isEmpty);
    expect(
        const BirBuyerDetails(registeredName: 'Customer', tin: 'not-a-tin')
            .validate(),
        isNotEmpty);
    expect(const BirBuyerDetails(registeredName: 'Fake\nTOTAL 0').validate(),
        isNotEmpty);
    expect(buyer.validate(), isEmpty);
  });
}

class _CapturedPrinter implements ReceiptPrinterAdapter {
  final receipts = <String>[];
  @override
  Future<void> printReceipt(String formattedReceipt,
      {required String jobId}) async {
    receipts.add(formattedReceipt);
  }
}

class _TestDrawer implements CashDrawerAdapter {
  @override
  Future<void> openDrawer({required String jobId}) async {}
}

class _UnavailableProcessor extends HardwareJobProcessor {
  _UnavailableProcessor(AppDatabase db)
      : super(
            database: db,
            printer: _CapturedPrinter(),
            cashDrawer: _TestDrawer());
  @override
  Future<HardwareJobProcessResult> processNext(DateTime now) async =>
      throw StateError('Injected hardware worker outage');
}
