import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/bir_reporting_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';

void main() {
  late AppDatabase database;
  late OfflineSaleRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = OfflineSaleRepository(database);
    final now = DateTime(2026, 7, 11, 9);

    await database.into(database.branches).insert(
          BranchesCompanion.insert(
            id: 'branch-main',
            code: '001',
            name: 'Main Branch',
            createdAt: now,
          ),
        );
    await database.into(database.terminals).insert(
          TerminalsCompanion.insert(
            id: 'terminal-1',
            branchId: 'branch-main',
            code: 'POS01',
            machineIdentificationNumber: 'MIN-001',
            permitToUseNumber: 'PTU-001',
            machineSerialNumber: 'SERIAL-001',
            createdAt: now,
          ),
        );
    await database.into(database.invoiceSequences).insert(
          InvoiceSequencesCompanion.insert(
            terminalId: 'terminal-1',
            nextValue: 1,
            updatedAt: now,
          ),
        );
    await database.into(database.products).insert(
          ProductsCompanion.insert(
            id: 'product-1',
            sku: 'SKU-001',
            name: 'Test Product',
            taxCategory: TaxCategory.vat12.name,
            unitPriceCentavos: 11200,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database.into(database.branchInventories).insert(
          BranchInventoriesCompanion.insert(
            branchId: 'branch-main',
            productId: 'product-1',
            stockOnHand: const Value(10),
            reorderPoint: const Value(3),
            updatedAt: now,
          ),
        );
  });

  tearDown(() => database.close());

  test('commits invoice, serial, stock, audit, and outbox atomically',
      () async {
    final invoice = await repository.issueSale(
      _request(quantity: 2, paymentReference: 'cash:20000'),
    );

    expect(invoice.invoiceNumber, '001-POS01-00000001');
    expect(invoice.totalCentavos, 22400);
    expect((await database.select(database.invoices).get()).length, 1);
    expect((await database.select(database.invoiceLines).get()).length, 1);
    expect((await database.select(database.payments).get()).length, 1);
    expect(
        (await database.select(database.inventoryMovements).get()).length, 1);
    expect((await database.select(database.auditEvents).get()).length, 1);
    expect((await database.select(database.syncOutboxEvents).get()).length, 1);

    final inventory =
        await database.select(database.branchInventories).getSingle();
    final sequence =
        await database.select(database.invoiceSequences).getSingle();
    expect(inventory.stockOnHand, 8);
    expect(inventory.version, 2);
    expect(sequence.nextValue, 2);
  });

  test('queues a low-stock event without contacting a supplier', () async {
    await (database.update(database.branchInventories)
          ..where(
            (row) =>
                row.branchId.equals('branch-main') &
                row.productId.equals('product-1'),
          ))
        .write(const BranchInventoriesCompanion(stockOnHand: Value(4)));

    await repository.issueSale(
      _request(quantity: 2, paymentReference: 'cash:30000'),
    );

    final events = await database.select(database.syncOutboxEvents).get();
    expect(events.map((event) => event.eventType), contains('invoice.issued'));
    expect(events.map((event) => event.eventType),
        contains('inventory.low_stock'));
    expect(events, hasLength(2));
  });

  test('rolls back every financial record when stock is insufficient',
      () async {
    expect(
      () => repository.issueSale(
        _request(quantity: 11, paymentReference: 'cash:200000'),
      ),
      throwsA(isA<StateError>()),
    );

    expect(await database.select(database.invoices).get(), isEmpty);
    expect(await database.select(database.invoiceLines).get(), isEmpty);
    expect(await database.select(database.payments).get(), isEmpty);
    expect(await database.select(database.inventoryMovements).get(), isEmpty);
    expect(await database.select(database.auditEvents).get(), isEmpty);
    expect(await database.select(database.syncOutboxEvents).get(), isEmpty);

    final inventory =
        await database.select(database.branchInventories).getSingle();
    final sequence =
        await database.select(database.invoiceSequences).getSingle();
    expect(inventory.stockOnHand, 10);
    expect(sequence.nextValue, 1);
  });

  test('void preserves the invoice and atomically restores inventory',
      () async {
    final issued = await repository.issueSale(
      _request(quantity: 2, paymentReference: 'cash:30000'),
    );

    await repository.voidInvoice(
      VoidInvoiceRequest(
        invoiceId: issued.id,
        actorId: 'supervisor-1',
        reason: 'Customer cancelled before leaving',
        voidedAt: DateTime(2026, 7, 11, 10, 5),
      ),
    );

    final storedInvoice = await database.select(database.invoices).getSingle();
    final inventory =
        await database.select(database.branchInventories).getSingle();
    final sequence =
        await database.select(database.invoiceSequences).getSingle();
    final movements = await database.select(database.inventoryMovements).get();
    final audits = await database.select(database.auditEvents).get();
    final outbox = await database.select(database.syncOutboxEvents).get();

    expect(storedInvoice.invoiceNumber, issued.invoiceNumber);
    expect(storedInvoice.totalCentavos, issued.totalCentavos);
    expect(storedInvoice.status, InvoiceStatus.voided.name);
    expect(storedInvoice.voidReason, 'Customer cancelled before leaving');
    expect(inventory.stockOnHand, 10);
    expect(sequence.nextValue, 2);
    expect(movements.map((movement) => movement.type), ['sale', 'sale_void']);
    expect(audits.map((event) => event.eventType),
        ['invoice.issued', 'invoice.voided']);
    expect(outbox.map((event) => event.eventType),
        ['invoice.issued', 'invoice.voided']);
  });

  test('rejects a duplicate void without changing balances or logs', () async {
    final issued = await repository.issueSale(
      _request(quantity: 1, paymentReference: 'cash:20000'),
    );
    final request = VoidInvoiceRequest(
      invoiceId: issued.id,
      actorId: 'supervisor-1',
      reason: 'Duplicate test',
      voidedAt: DateTime(2026, 7, 11, 10, 5),
    );
    await repository.voidInvoice(request);

    expect(() => repository.voidInvoice(request), throwsA(isA<StateError>()));

    final inventory =
        await database.select(database.branchInventories).getSingle();
    expect(inventory.stockOnHand, 10);
    expect(
        await database.select(database.inventoryMovements).get(), hasLength(2));
    expect(await database.select(database.auditEvents).get(), hasLength(2));
    expect(
        await database.select(database.syncOutboxEvents).get(), hasLength(2));
  });

  test('rolls back void when inventory cannot be restored', () async {
    final issued = await repository.issueSale(
      _request(quantity: 1, paymentReference: 'cash:20000'),
    );
    await database.delete(database.branchInventories).go();

    expect(
      () => repository.voidInvoice(
        VoidInvoiceRequest(
          invoiceId: issued.id,
          actorId: 'supervisor-1',
          reason: 'Rollback test',
          voidedAt: DateTime(2026, 7, 11, 10, 5),
        ),
      ),
      throwsA(isA<StateError>()),
    );

    final storedInvoice = await database.select(database.invoices).getSingle();
    expect(storedInvoice.status, InvoiceStatus.issued.name);
    expect(
        await database.select(database.inventoryMovements).get(), hasLength(1));
    expect(await database.select(database.auditEvents).get(), hasLength(1));
    expect(
        await database.select(database.syncOutboxEvents).get(), hasLength(1));
  });

  test('produces an offline e-journal and terminal reading including voids',
      () async {
    final first = await repository.issueSale(
      _request(quantity: 1, paymentReference: 'cash:first'),
    );
    await repository.issueSale(
      _request(quantity: 2, paymentReference: 'cash:second'),
    );
    await repository.voidInvoice(
      VoidInvoiceRequest(
        invoiceId: first.id,
        actorId: 'supervisor-1',
        reason: 'Reporting test',
        voidedAt: DateTime(2026, 7, 11, 10, 5),
      ),
    );

    final reports = BirReportingRepository(database);
    final journal = await reports.electronicSalesJournal(
      branchId: 'branch-main',
      terminalId: 'terminal-1',
      from: DateTime(2026, 7, 11),
      to: DateTime(2026, 7, 12),
    );
    final reading = await reports.terminalReading(
      branchId: 'branch-main',
      terminalId: 'terminal-1',
      from: DateTime(2026, 7, 11),
      to: DateTime(2026, 7, 12),
      generatedAt: DateTime(2026, 7, 11, 23, 59),
    );

    expect(journal, hasLength(2));
    expect(journal.first.status, InvoiceStatus.voided.name);
    expect(reading.transactionCount, 2);
    expect(reading.voidCount, 1);
    expect(reading.grossSalesCentavos, 33600);
    expect(reading.voidSalesCentavos, 11200);
    expect(reading.netSalesCentavos, 22400);
    expect(reading.vatableSalesCentavos, 20000);
    expect(reading.vatAmountCentavos, 2400);
    expect(reading.paymentTotalsCentavos, {'cash': 22400});
    expect(reading.beginningInvoiceNumber, '001-POS01-00000001');
    expect(reading.endingInvoiceNumber, '001-POS01-00000002');
  });
}

OfflineSaleRequest _request({
  required int quantity,
  required String paymentReference,
}) {
  return OfflineSaleRequest(
    branchId: 'branch-main',
    terminalId: 'terminal-1',
    actorId: 'cashier-1',
    issuedAt: DateTime(2026, 7, 11, 10),
    payment: PaymentEvidence(
      id: 'payment-$paymentReference',
      provider: PaymentProvider.cash,
      status: PaymentStatus.captured,
      amountCentavos: quantity * 11200,
      reference: paymentReference,
      authorizedAt: DateTime(2026, 7, 11, 10),
      isOffline: true,
      cashTenderedCentavos: quantity * 11200 + 1000,
      changeCentavos: 1000,
    ),
    sellerName: 'Example Retail Inc.',
    sellerTin: '000-000-000-00000',
    sellerAddress: 'Quezon City',
    registrationType: TaxRegistrationType.vat,
    softwareName: 'Xantara POS',
    softwareVersion: '1.0.0',
    lines: [
      OfflineSaleLineRequest(
        productId: 'product-1',
        quantity: quantity,
      ),
    ],
  );
}
