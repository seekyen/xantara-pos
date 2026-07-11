import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/suppliers/supplier_integration.dart';
import '../database.dart';

class SupplierAlertRepository {
  SupplierAlertRepository(this.database, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  final AppDatabase database;
  final Uuid _uuid;

  /// Converts local low-stock events into supplier-specific, minimized jobs.
  /// Re-running this method is safe because each connector/source pair has a
  /// permanent idempotency key.
  Future<int> routePendingLowStockEvents() async {
    return database.transaction(() async {
      final events = await (database.select(database.syncOutboxEvents)
            ..where((row) => row.eventType.equals('inventory.low_stock'))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();
      var created = 0;
      for (final event in events) {
        final source = jsonDecode(event.payloadJson) as Map<String, dynamic>;
        final productId = source['productId'] as String?;
        if (productId == null || productId.isEmpty) continue;
        final branch = await (database.select(database.branches)
              ..where((row) => row.id.equals(event.branchId)))
            .getSingleOrNull();
        if (branch == null) continue;

        final subscriptions =
            await (database.select(database.supplierProductSubscriptions)
                  ..where(
                    (row) =>
                        row.productId.equals(productId) &
                        row.isEnabled.equals(true),
                  ))
                .get();
        for (final subscription in subscriptions) {
          final connector = await (database.select(database.supplierConnectors)
                ..where(
                  (row) =>
                      row.id.equals(subscription.connectorId) &
                      row.branchId.equals(event.branchId) &
                      row.isEnabled.equals(true),
                ))
              .getSingleOrNull();
          if (connector == null) continue;

          final fields = _parseFields(subscription.allowedFieldsJson);
          if (fields.isEmpty) continue;
          final minimized = <String, Object?>{};
          for (final field in fields) {
            switch (field) {
              case SupplierAlertField.branchCode:
                minimized['branchCode'] = branch.code;
                break;
              case SupplierAlertField.sku:
                minimized['sku'] = source['sku'];
                break;
              case SupplierAlertField.productName:
                minimized['productName'] = source['name'];
                break;
              case SupplierAlertField.stockOnHand:
                minimized['stockOnHand'] = source['stockOnHand'];
                break;
              case SupplierAlertField.reorderPoint:
                minimized['reorderPoint'] = source['reorderPoint'];
                break;
              case SupplierAlertField.suggestedOrderQuantity:
                minimized['suggestedOrderQuantity'] =
                    subscription.suggestedOrderQuantity;
                break;
            }
          }
          final idempotencyKey =
              'supplier.low_stock:${connector.id}:${event.id}';
          final exists = await (database.select(database.supplierDeliveryJobs)
                ..where((row) => row.idempotencyKey.equals(idempotencyKey)))
              .getSingleOrNull();
          if (exists != null) continue;
          await database.into(database.supplierDeliveryJobs).insert(
                SupplierDeliveryJobsCompanion.insert(
                  id: _uuid.v4(),
                  connectorId: connector.id,
                  sourceEventId: event.id,
                  branchId: event.branchId,
                  productId: productId,
                  status: SupplierDeliveryStatus.queued.name,
                  idempotencyKey: idempotencyKey,
                  payloadJson: jsonEncode(minimized),
                  createdAt: event.createdAt,
                ),
              );
          created++;
        }
      }
      return created;
    });
  }

  Set<SupplierAlertField> _parseFields(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! List) return const {};
    return decoded
        .whereType<String>()
        .map(
          (name) => SupplierAlertField.values
              .where((field) => field.name == name)
              .firstOrNull,
        )
        .whereType<SupplierAlertField>()
        .toSet();
  }
}
