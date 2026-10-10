import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/core/loyalty/loyalty_points.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/hardware_job_processor.dart';
import 'package:pos_app/local/repositories/loyalty_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';

void main() {
  group('points rule', () {
    test('a promo day is the Manila calendar day of the instant', () {
      expect(manilaDay(DateTime.utc(2026, 9, 20, 17)), '2026-09-21');
      expect(manilaDay(DateTime.utc(2026, 9, 20, 15, 59)), '2026-09-20');
      expect(manilaDay(DateTime.utc(2026, 12, 31, 16)), '2027-01-01');
    });

    test('pesos become centavos only for clean decimal amounts', () {
      expect(pesosToCentavos('50'), 5000);
      expect(pesosToCentavos('50.5'), 5050);
      expect(pesosToCentavos('50.25'), 5025);
      expect(pesosToCentavos('0.01'), 1);
      expect(pesosToCentavos(20), 2000);
      for (final bad in ['abc', '-5', '1.234', '', null, '1e3', '5,000']) {
        expect(pesosToCentavos(bad), isNull, reason: '$bad');
      }
    });

    const payday = LoyaltyPromoRule(
      name: 'Payday',
      startDate: '2026-07-10',
      endDate: '2026-07-12',
      spendPerPointCentavos: 2000,
    );
    final noon = DateTime.utc(2026, 7, 11, 4);

    test('whole steps of the net amount, inside the promo dates only', () {
      final estimate = estimateLoyaltyPoints(
          netCentavos: 10000, issuedAt: noon, promos: [payday]);
      expect((estimate.points, estimate.promoName), (5, 'Payday'));
      // A remainder short of a full step earns nothing.
      expect(
          estimateLoyaltyPoints(
                  netCentavos: 1999, issuedAt: noon, promos: [payday])
              .points,
          0);
      expect(
          estimateLoyaltyPoints(
                  netCentavos: 10000,
                  issuedAt: DateTime.utc(2026, 7, 12, 15, 59),
                  promos: [payday])
              .points,
          5,
          reason: 'the last day is included');
      expect(
          estimateLoyaltyPoints(
                  netCentavos: 10000,
                  issuedAt: DateTime.utc(2026, 7, 12, 16),
                  promos: [payday])
              .points,
          0,
          reason: 'it ended at midnight Manila time');
      expect(
          estimateLoyaltyPoints(netCentavos: 0, issuedAt: noon, promos: [payday])
              .points,
          0);
      expect(
          estimateLoyaltyPoints(netCentavos: 10000, issuedAt: noon, promos: [])
              .promoName,
          isNull);
    });

    test('overlapping promos do not stack: the best one for the customer wins',
        () {
      const rich = LoyaltyPromoRule(
        name: 'Rich',
        startDate: '2026-07-01',
        endDate: '2026-07-31',
        spendPerPointCentavos: 1000,
      );
      final estimate = estimateLoyaltyPoints(
          netCentavos: 10000, issuedAt: noon, promos: [payday, rich]);
      expect((estimate.points, estimate.promoName), (10, 'Rich'));
    });
  });

  group('device cache and sale', () {
    late AppDatabase database;
    late LoyaltyRepository loyalty;
    late OfflineSaleRepository sales;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      loyalty = LoyaltyRepository(database);
      sales = OfflineSaleRepository(database);
      await _seed(database);
    });

    tearDown(() => database.close());

    Map<String, Object?> cloud({List<Object?>? customers, List<Object?>? promos}) => {
          'customers': customers ??
              [
                {'id': 7, 'name': 'Maria Santos', 'phone': '0917 111', 'email': 'm@x.ph', 'loyalty_points': 12},
                {'id': 8, 'name': 'jose reyes', 'phone': '', 'email': null, 'loyalty_points': 0},
              ],
          'promos': promos ??
              [
                {'id': 1, 'name': 'July Points', 'start_date': '2026-07-01', 'end_date': '2026-07-31', 'spend_per_point': '20.00', 'is_active': true, 'status': 'running'},
              ],
        };

    test('the download replaces the cache and skips malformed rows', () async {
      expect(await loyalty.replaceFromCloud(cloud()), 2);
      final bad = cloud(customers: [
        {'id': 9, 'name': 'Only Ana', 'loyalty_points': -3},
        {'id': '', 'name': 'No id'},
        {'id': 10, 'name': '  '},
        'junk',
      ], promos: [
        {'id': 2, 'name': 'Good', 'start_date': '2026-08-01', 'end_date': '2026-08-02', 'spend_per_point': '50'},
        {'id': 3, 'name': 'Backwards', 'start_date': '2026-08-05', 'end_date': '2026-08-01', 'spend_per_point': '50'},
        {'id': 4, 'name': 'Free', 'start_date': '2026-08-01', 'end_date': '2026-08-02', 'spend_per_point': '0'},
        {'id': 5, 'name': 'Paused', 'start_date': '2026-08-01', 'end_date': '2026-08-02', 'spend_per_point': '5', 'is_active': false},
        {'id': 6, 'name': 'Bad date', 'start_date': 'tomorrow', 'end_date': '2026-08-02', 'spend_per_point': '5'},
      ]);
      expect(await loyalty.replaceFromCloud(bad), 1);
      final customers = await database.select(database.loyaltyCustomers).get();
      expect(customers.map((c) => (c.id, c.points)), [('9', 0)]);
      final promos = await database.select(database.loyaltyPromos).get();
      expect(promos.map((p) => (p.name, p.spendPerPointCentavos)), [('Good', 5000)]);
    });

    test('a response of the wrong shape leaves the previous cache alone', () async {
      await loyalty.replaceFromCloud(cloud());
      for (final broken in <Object?>[null, 'oops', {'customers': []}, {'customers': 1, 'promos': []}]) {
        await expectLater(loyalty.replaceFromCloud(broken), throwsFormatException);
      }
      expect(await database.select(database.loyaltyCustomers).get(), hasLength(2));
      expect(await database.select(database.loyaltyPromos).get(), hasLength(1));
    });

    test('customers are searched by name or phone without wildcards leaking', () async {
      await loyalty.replaceFromCloud(cloud());
      expect((await loyalty.searchCustomers('')).map((c) => c.name), ['jose reyes', 'Maria Santos']);
      expect((await loyalty.searchCustomers('MARIA')).map((c) => c.id), ['7']);
      expect((await loyalty.searchCustomers('0917')).map((c) => c.id), ['7']);
      expect(await loyalty.searchCustomers('%'), isEmpty);
      expect(await loyalty.searchCustomers('zzz'), isEmpty);
    });

    test('a sale attached to a customer stores the estimate and sends the customer id', () async {
      await loyalty.replaceFromCloud(cloud());
      final invoice = await sales.issueSale(_sale(loyaltyCustomerId: '7'));

      // P112.00 total less P12.00 VAT = P100.00 net -> 5 points at P20 per point.
      final link = await loyalty.loyaltyForInvoice(invoice.id);
      expect((link!.customerId, link.customerName, link.estimatedPoints, link.promoName),
          ('7', 'Maria Santos', 5, 'July Points'));

      final event = (await database.select(database.syncOutboxEvents).get())
          .singleWhere((e) => e.eventType == 'invoice.issued');
      final payload = jsonDecode(event.payloadJson) as Map<String, dynamic>;
      expect(payload['customerId'], '7');
      expect(payload['customerName'], 'Maria Santos');
      expect(payload['totalCentavos'], 11200);
      expect((payload['taxSummary'] as Map)['vatAmountCentavos'], 1200);
      expect(payload['issuedAt'], isA<String>());

      // The BIR invoice row itself is untouched by the loyalty link.
      final row = await database.select(database.invoices).getSingle();
      expect((row.buyerName, row.buyerTin, row.buyerAddress), (null, null, null));
    });

    test('a sale without a customer has no link and no customer id', () async {
      final invoice = await sales.issueSale(_sale());
      expect(await loyalty.loyaltyForInvoice(invoice.id), isNull);
      final event = (await database.select(database.syncOutboxEvents).get())
          .singleWhere((e) => e.eventType == 'invoice.issued');
      expect((jsonDecode(event.payloadJson) as Map).containsKey('customerId'), isFalse);
    });

    test('with no promo running the customer is still linked with 0 points', () async {
      await loyalty.replaceFromCloud(cloud(promos: []));
      final invoice = await sales.issueSale(_sale(loyaltyCustomerId: '8'));
      final link = await loyalty.loyaltyForInvoice(invoice.id);
      expect((link!.estimatedPoints, link.promoName), (0, null));
    });

    test('an unknown customer aborts the whole sale', () async {
      await loyalty.replaceFromCloud(cloud());
      await expectLater(sales.issueSale(_sale(loyaltyCustomerId: '999')), throwsStateError);
      expect(await database.select(database.invoices).get(), isEmpty);
      expect(await database.select(database.invoiceLoyalty).get(), isEmpty);
      expect(await database.select(database.syncOutboxEvents).get(), isEmpty);
      expect((await database.select(database.invoiceSequences).getSingle()).nextValue, 1);
      expect((await database.select(database.branchInventories).getSingle()).stockOnHand, 10);
    });

    test('the printed receipt (and a reprint) shows the customer and estimated points', () async {
      await loyalty.replaceFromCloud(cloud());
      final printer = _FakePrinter();
      final processor = HardwareJobProcessor(
          database: database, printer: printer, cashDrawer: _FakeDrawer());
      final invoice = await sales.issueSale(_sale(loyaltyCustomerId: '7', openCashDrawer: false));
      await processor.processNext(DateTime(2026, 7, 11, 10, 1));
      expect(printer.receipts.single, contains('Customer: Maria Santos'));
      expect(printer.receipts.single, contains('Points earned: ~5 (confirmed on sync)'));

      await sales.queueInvoiceReprint(
          invoiceId: invoice.id, actorId: 'cashier-1', requestedAt: DateTime(2026, 7, 11, 11));
      await processor.processNext(DateTime(2026, 7, 11, 11, 1));
      expect(printer.receipts.last, contains('Points earned: ~5'));
      expect(printer.receipts.last, contains('REPRINT ONLY'));
    });

    test('a receipt without a customer has no loyalty lines', () async {
      final printer = _FakePrinter();
      final processor = HardwareJobProcessor(
          database: database, printer: printer, cashDrawer: _FakeDrawer());
      await sales.issueSale(_sale(openCashDrawer: false));
      await processor.processNext(DateTime(2026, 7, 11, 10, 1));
      expect(printer.receipts.single, isNot(contains('Customer:')));
      expect(printer.receipts.single, isNot(contains('Points earned')));
    });
  });

  test('upgrading a version 4 database adds the loyalty tables', () async {
    final directory = await Directory.systemTemp.createTemp('xantara-loyalty-migration-');
    final file = File('${directory.path}/pos.sqlite');
    final original = AppDatabase(NativeDatabase(file));
    await original.customSelect('SELECT 1').get(); // force creation
    await original.customStatement('DROP TABLE invoice_loyalty');
    await original.customStatement('DROP TABLE loyalty_customers');
    await original.customStatement('DROP TABLE loyalty_promos');
    await original.customStatement('DROP TABLE company_registration');
    await original.customStatement('PRAGMA user_version = 4');
    await original.close();

    final migrated = AppDatabase(NativeDatabase(file));
    try {
      await LoyaltyRepository(migrated).replaceFromCloud({
        'customers': [
          {'id': 1, 'name': 'Maria', 'loyalty_points': 3}
        ],
        'promos': [],
      });
      expect(await migrated.select(migrated.loyaltyCustomers).get(), hasLength(1));
      expect(await migrated.select(migrated.invoiceLoyalty).get(), isEmpty);
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<void> _seed(AppDatabase database) async {
  final now = DateTime(2026, 7, 11, 9);
  await database.into(database.branches).insert(
      BranchesCompanion.insert(id: 'branch-main', code: '001', name: 'Main Branch', createdAt: now));
  await database.into(database.terminals).insert(TerminalsCompanion.insert(
      id: 'terminal-1',
      branchId: 'branch-main',
      code: 'POS01',
      machineIdentificationNumber: 'MIN-001',
      permitToUseNumber: 'PTU-001',
      machineSerialNumber: 'SERIAL-001',
      createdAt: now));
  await database.into(database.invoiceSequences).insert(
      InvoiceSequencesCompanion.insert(terminalId: 'terminal-1', nextValue: 1, updatedAt: now));
  await database.into(database.products).insert(ProductsCompanion.insert(
      id: 'product-1',
      sku: 'SKU-001',
      name: 'Test Product',
      taxCategory: TaxCategory.vat12.name,
      unitPriceCentavos: 11200,
      createdAt: now,
      updatedAt: now));
  await database.into(database.branchInventories).insert(BranchInventoriesCompanion.insert(
      branchId: 'branch-main',
      productId: 'product-1',
      stockOnHand: const Value(10),
      reorderPoint: const Value(3),
      updatedAt: now));
}

OfflineSaleRequest _sale({String? loyaltyCustomerId, bool openCashDrawer = true}) {
  final issuedAt = DateTime(2026, 7, 11, 10);
  return OfflineSaleRequest(
    branchId: 'branch-main',
    terminalId: 'terminal-1',
    actorId: 'cashier-1',
    issuedAt: issuedAt,
    payment: PaymentEvidence(
      id: 'payment-${loyaltyCustomerId ?? 'none'}',
      provider: PaymentProvider.cash,
      status: PaymentStatus.captured,
      amountCentavos: 11200,
      reference: 'cash:12000',
      authorizedAt: issuedAt,
      isOffline: true,
      cashTenderedCentavos: 12000,
      changeCentavos: 800,
    ),
    sellerName: 'Example Retail Inc.',
    sellerTin: '000-000-000-00000',
    sellerAddress: 'Quezon City',
    registrationType: TaxRegistrationType.vat,
    softwareName: 'Xantara POS',
    softwareVersion: '1.0.0',
    lines: const [OfflineSaleLineRequest(productId: 'product-1', quantity: 1)],
    loyaltyCustomerId: loyaltyCustomerId,
    openCashDrawer: openCashDrawer,
  );
}

class _FakePrinter implements ReceiptPrinterAdapter {
  final receipts = <String>[];

  @override
  Future<void> printReceipt(String formattedReceipt, {required String jobId}) async {
    receipts.add(formattedReceipt);
  }
}

class _FakeDrawer implements CashDrawerAdapter {
  @override
  Future<void> openDrawer({required String jobId}) async {}
}
