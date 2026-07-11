import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/suppliers/supplier_integration.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/supplier_alert_repository.dart';
import 'package:pos_app/local/repositories/supplier_delivery_processor.dart';

void main() {
  late AppDatabase database;
  late SupplierAlertRepository alerts;
  late _FakeSupplierAdapter adapter;
  late SupplierDeliveryProcessor deliveries;
  final now = DateTime(2026, 7, 11, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    alerts = SupplierAlertRepository(database);
    adapter = _FakeSupplierAdapter();
    deliveries = SupplierDeliveryProcessor(
      database: database,
      adapters: [adapter],
    );
    await _seed(database, now);
  });

  tearDown(() => database.close());

  test('routes only owner-approved inventory fields and is idempotent',
      () async {
    final first = await alerts.routePendingLowStockEvents();
    final second = await alerts.routePendingLowStockEvents();

    expect(first, 1);
    expect(second, 0);
    final job =
        await database.select(database.supplierDeliveryJobs).getSingle();
    final payload = jsonDecode(job.payloadJson) as Map<String, dynamic>;
    expect(payload, {'sku': 'SKU-001', 'stockOnHand': 2});
    expect(payload, isNot(contains('productName')));
    expect(payload, isNot(contains('reorderPoint')));
    expect(payload, isNot(contains('invoiceId')));
  });

  test('delivers minimized alert with a permanent idempotency key', () async {
    await alerts.routePendingLowStockEvents();

    final result = await deliveries.processNext(now);

    expect(result.succeeded, isTrue);
    expect(adapter.alerts, hasLength(1));
    expect(adapter.alerts.single.authorizedData.keys, {'sku', 'stockOnHand'});
    expect(adapter.alerts.single.idempotencyKey,
        'supplier.low_stock:connector-1:low-stock-1');
    final job =
        await database.select(database.supplierDeliveryJobs).getSingle();
    expect(job.status, SupplierDeliveryStatus.completed.name);
    expect(job.externalReference, 'supplier-ack-1');
    expect(job.leaseId, isNull);
  });

  test('disabled connector never sends an already queued alert', () async {
    await alerts.routePendingLowStockEvents();
    await (database.update(database.supplierConnectors)).write(
      const SupplierConnectorsCompanion(isEnabled: Value(false)),
    );

    final result = await deliveries.processNext(now);

    expect(result.processed, isFalse);
    expect(adapter.alerts, isEmpty);
    final job =
        await database.select(database.supplierDeliveryJobs).getSingle();
    expect(job.status, SupplierDeliveryStatus.queued.name);
    expect(job.attemptCount, 0);
  });

  test('failed supplier delivery backs off and retries idempotently', () async {
    adapter.failuresRemaining = 1;
    await alerts.routePendingLowStockEvents();

    final failed = await deliveries.processNext(now);
    final early = await deliveries.processNext(now);
    final retried = await deliveries.processNext(
      now.add(const Duration(seconds: 3)),
    );

    expect(failed.succeeded, isFalse);
    expect(early.processed, isFalse);
    expect(retried.succeeded, isTrue);
    expect(adapter.alerts, hasLength(2));
    expect(adapter.alerts.map((alert) => alert.idempotencyKey).toSet(),
        {'supplier.low_stock:connector-1:low-stock-1'});
  });
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database.into(database.branches).insert(
        BranchesCompanion.insert(
          id: 'branch-main',
          code: '001',
          name: 'Main Branch',
          createdAt: now,
        ),
      );
  await database.into(database.products).insert(
        ProductsCompanion.insert(
          id: 'product-1',
          sku: 'SKU-001',
          name: 'Private Product Name',
          taxCategory: 'vat12',
          unitPriceCentavos: 10000,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database.into(database.syncOutboxEvents).insert(
        SyncOutboxEventsCompanion.insert(
          id: 'low-stock-1',
          branchId: 'branch-main',
          aggregateType: 'inventory',
          aggregateId: 'branch-main:product-1',
          eventType: 'inventory.low_stock',
          idempotencyKey: 'inventory.low_stock:branch-main:product-1:sale-1',
          payloadJson: jsonEncode({
            'branchId': 'branch-main',
            'productId': 'product-1',
            'sku': 'SKU-001',
            'name': 'Private Product Name',
            'stockOnHand': 2,
            'reorderPoint': 3,
            'triggerInvoiceId': 'private-invoice-id',
          }),
          createdAt: now,
        ),
      );
  await database.into(database.supplierConnectors).insert(
        SupplierConnectorsCompanion.insert(
          id: 'connector-1',
          branchId: 'branch-main',
          name: 'Approved Supplier',
          connectorType: 'test',
          secretReference: 'secure-storage:supplier-1',
          isEnabled: const Value(true),
          approvedBy: 'owner-1',
          approvedAt: now,
          createdAt: now,
        ),
      );
  await database.into(database.supplierProductSubscriptions).insert(
        SupplierProductSubscriptionsCompanion.insert(
          connectorId: 'connector-1',
          productId: 'product-1',
          allowedFieldsJson: jsonEncode([
            SupplierAlertField.sku.name,
            SupplierAlertField.stockOnHand.name,
          ]),
          suggestedOrderQuantity: 10,
          approvedBy: 'owner-1',
          approvedAt: now,
        ),
      );
}

class _FakeSupplierAdapter implements SupplierConnectorAdapter {
  final alerts = <SupplierAlertEnvelope>[];
  var failuresRemaining = 0;

  @override
  String get connectorType => 'test';

  @override
  Future<SupplierDeliveryAcknowledgement> deliver(
    SupplierAlertEnvelope alert,
  ) async {
    alerts.add(alert);
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('Supplier unavailable.');
    }
    return SupplierDeliveryAcknowledgement(
      externalReference: 'supplier-ack-${alerts.length}',
      acceptedAt: alert.occurredAt.add(const Duration(seconds: 1)),
    );
  }
}
