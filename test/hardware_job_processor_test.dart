import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/hardware_job_processor.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';

void main() {
  late AppDatabase database;
  late OfflineSaleRepository sales;
  late _FakePrinter printer;
  late _FakeCashDrawer drawer;
  late HardwareJobProcessor processor;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    sales = OfflineSaleRepository(database);
    printer = _FakePrinter();
    drawer = _FakeCashDrawer();
    processor = HardwareJobProcessor(
      database: database,
      printer: printer,
      cashDrawer: drawer,
    );
    await _seed(database);
  });

  tearDown(() => database.close());

  test('sale durably queues and processes receipt and cash drawer jobs',
      () async {
    final invoice = await sales.issueSale(_cashSale());

    expect(await database.select(database.hardwareJobs).get(), hasLength(2));
    expect(
        (await processor.processNext(DateTime(2026, 7, 11, 10, 1))).succeeded,
        isTrue);
    expect(
        (await processor.processNext(DateTime(2026, 7, 11, 10, 1))).succeeded,
        isTrue);

    expect(printer.receipts, hasLength(1));
    expect(drawer.jobIds, hasLength(1));
    expect(printer.receipts.single, contains('VAT INVOICE'));
    expect(printer.receipts.single,
        contains('Invoice No: ${invoice.invoiceNumber}'));
    expect(printer.receipts.single, contains('MIN: MIN-001'));
    expect(printer.receipts.single, isNot(contains('REPRINT ONLY')));
    final jobs = await database.select(database.hardwareJobs).get();
    expect(jobs.every((job) => job.status == HardwareJobStatus.completed.name),
        isTrue);
  });

  test('reprint is visibly marked and creates an audit record', () async {
    final invoice = await sales.issueSale(_cashSale(openCashDrawer: false));
    await processor.processNext(DateTime(2026, 7, 11, 10, 1));

    await sales.queueInvoiceReprint(
      invoiceId: invoice.id,
      actorId: 'supervisor-1',
      requestedAt: DateTime(2026, 7, 11, 11),
    );
    await processor.processNext(DateTime(2026, 7, 11, 11, 1));

    expect(printer.receipts, hasLength(2));
    expect(printer.receipts.last, contains('REPRINT ONLY'));
    expect(printer.receipts.last, contains('Reprinted:'));
    final audits = await database.select(database.auditEvents).get();
    expect(
      audits.map((event) => event.eventType),
      contains('invoice.reprint_requested'),
    );
  });

  test('failed hardware jobs wait and retry without changing the sale',
      () async {
    printer.failuresRemaining = 1;
    final invoice = await sales.issueSale(_cashSale(openCashDrawer: false));
    final firstAttemptAt = DateTime(2026, 7, 11, 10, 1);

    final failed = await processor.processNext(firstAttemptAt);
    final tooEarly = await processor.processNext(firstAttemptAt);
    final retried = await processor.processNext(
      firstAttemptAt.add(const Duration(seconds: 3)),
    );

    expect(failed.succeeded, isFalse);
    expect(tooEarly.processed, isFalse);
    expect(retried.succeeded, isTrue);
    expect(printer.calls, 2);
    final job = await database.select(database.hardwareJobs).getSingle();
    expect(job.status, HardwareJobStatus.completed.name);
    expect(job.attemptCount, 2);
    expect(await database.select(database.invoices).getSingle(),
        isA<Invoice>().having((row) => row.id, 'id', invoice.id));
  });

  test('recovers a hardware job interrupted by an app restart', () async {
    await sales.issueSale(_cashSale(openCashDrawer: false));
    final job = await database.select(database.hardwareJobs).getSingle();
    await (database.update(database.hardwareJobs)
          ..where((row) => row.id.equals(job.id)))
        .write(
      HardwareJobsCompanion(
        status: Value(HardwareJobStatus.processing.name),
        processingStartedAt: Value(DateTime(2026, 7, 11, 9)),
      ),
    );

    final recovered = await processor.recoverInterruptedJobs(
      now: DateTime(2026, 7, 11, 10),
      staleAfter: const Duration(minutes: 5),
    );
    final result = await processor.processNext(DateTime(2026, 7, 11, 10));

    expect(recovered, 1);
    expect(result.succeeded, isTrue);
    expect(printer.receipts, hasLength(1));
    expect((await database.select(database.hardwareJobs).getSingle()).status,
        HardwareJobStatus.completed.name);
  });
}

Future<void> _seed(AppDatabase database) async {
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
}

OfflineSaleRequest _cashSale({bool openCashDrawer = true}) {
  return OfflineSaleRequest(
    branchId: 'branch-main',
    terminalId: 'terminal-1',
    actorId: 'cashier-1',
    issuedAt: DateTime(2026, 7, 11, 10),
    payment: PaymentEvidence(
      id: 'payment-1',
      provider: PaymentProvider.cash,
      status: PaymentStatus.captured,
      amountCentavos: 11200,
      reference: 'CASH-payment-1',
      authorizedAt: DateTime(2026, 7, 11, 10),
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
    lines: const [
      OfflineSaleLineRequest(productId: 'product-1', quantity: 1),
    ],
    openCashDrawer: openCashDrawer,
  );
}

class _FakePrinter implements ReceiptPrinterAdapter {
  final receipts = <String>[];
  var failuresRemaining = 0;
  var calls = 0;

  @override
  Future<void> printReceipt(
    String formattedReceipt, {
    required String jobId,
  }) async {
    calls++;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('Printer unavailable.');
    }
    receipts.add(formattedReceipt);
  }
}

class _FakeCashDrawer implements CashDrawerAdapter {
  final jobIds = <String>[];

  @override
  Future<void> openDrawer({required String jobId}) async {
    jobIds.add(jobId);
  }
}
