import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/pos_authorization.dart';
import '../../features/inventory/inventory_schema.dart';
import '../database.dart';

class InventoryWorkspaceRepository {
  InventoryWorkspaceRepository(this.database);
  final AppDatabase database;
  static const _uuid = Uuid();
  static const branchKeys = [
    'location',
    'batches',
    'last_restocked',
    'expiry_date'
  ];

  Future<Map<String, dynamic>> read(String productId, String branchId) async {
    final product = await (database.select(database.products)
          ..where((p) => p.id.equals(productId)))
        .getSingle();
    final inventory = await (database.select(database.branchInventories)
          ..where((p) =>
              p.productId.equals(productId) & p.branchId.equals(branchId)))
        .getSingle();
    final profile =
        jsonDecode(product.inventoryProfileJson) as Map<String, dynamic>;
    final data = <String, dynamic>{
      ...?profile['data'] as Map<String, dynamic>?,
      ...jsonDecode(inventory.inventoryDetailsJson) as Map<String, dynamic>,
      'name': product.name,
      'sku': product.sku,
      'selling_price': (product.unitPriceCentavos / 100).toStringAsFixed(2),
      'category': product.categoryId,
      'tax_category': product.taxCategory,
      'quantity': inventory.stockOnHand,
      'reorder_level': inventory.reorderPoint,
    };
    data.putIfAbsent('unit', () => 'pc');
    data.putIfAbsent('cost_price', () => '0.00');
    return {
      'local_id': product.id,
      'tier': profile['tier'] ?? 'basic',
      'revision': product.version,
      'cloud_id': profile['cloud_id'],
      'cloud_revision': profile['cloud_revision'],
      'cloud_quantity': profile['cloud_quantity'],
      'data': data
    };
  }

  Future<String> save(
      {required Map<String, dynamic> document,
      required String branchId,
      required StaffPrincipal actor,
      required String reason,
      required InventorySchema schema,
      required int expectedQuantity}) async {
    const PosAuthorizationPolicy()
        .require(actor, PosPermission.adjustInventory, branchId: branchId);
    final data = Map<String, dynamic>.from(document['data'] as Map);
    schema.validate(data);
    if (!schema.tiers.any((t) => t['key'] == document['tier'])) {
      throw const FormatException('Choose a valid inventory tier');
    }
    if (reason.trim().isEmpty || reason.length > 255) {
      throw const FormatException(
          'Provide a change reason (up to 255 characters)');
    }
    return database.transaction(() async {
      final id = document['local_id'] as String? ?? _uuid.v4();
      final existing = await (database.select(database.products)
            ..where((p) => p.id.equals(id)))
          .getSingleOrNull();
      final stock = await (database.select(database.branchInventories)
            ..where(
                (p) => p.productId.equals(id) & p.branchId.equals(branchId)))
          .getSingleOrNull();
      if (existing != null && existing.version != document['revision']) {
        throw StateError('This product changed. Reopen it before saving.');
      }
      final quantity = int.parse('${data['quantity'] ?? 0}');
      if (quantity != (stock?.stockOnHand ?? 0) &&
          expectedQuantity != (stock?.stockOnHand ?? 0)) {
        throw StateError(
            'Stock changed. Reopen the item before adjusting stock.');
      }
      if (existing != null && data['sku'] != existing.sku) {
        throw const FormatException('Existing SKU cannot change');
      }
      final before = existing != null && stock != null
          ? await read(id, branchId)
          : <String, dynamic>{
              'data': <String, dynamic>{'quantity': 0}
            };
      final sku = existing?.sku ??
          ((data['sku'] as String? ?? '').trim().isEmpty
              ? 'ITM${_uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase()}'
              : data['sku'] as String);
      final now = DateTime.now();
      final profile = {
        'tier': document['tier'],
        'cloud_id': document['cloud_id'],
        'cloud_revision': document['cloud_revision'],
        'cloud_quantity': document['cloud_quantity'],
        'data': {
          for (final entry in data.entries)
            if (!branchKeys.contains(entry.key) &&
                !['quantity', 'reorder_level'].contains(entry.key))
              entry.key: entry.value
        },
      };
      final priceParts = '${data['selling_price'] ?? '0'}'.split('.');
      final centavos = int.parse(priceParts[0]) * 100 +
          int.parse(
              priceParts.length > 1 ? priceParts[1].padRight(2, '0') : '0');
      await database
          .into(database.products)
          .insertOnConflictUpdate(ProductsCompanion.insert(
            id: id,
            sku: sku,
            name: '${data['name']}'.trim(),
            taxCategory: '${data['tax_category'] ?? 'vat12'}',
            unitPriceCentavos: centavos,
            categoryId: Value('${data['category'] ?? 'uncategorized'}'),
            colorArgb: Value(existing?.colorArgb ?? 0xFF1565C0),
            isActive: Value(existing?.isActive ?? true),
            version: Value((existing?.version ?? 0) + 1),
            inventoryProfileJson: Value(jsonEncode(profile)),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ));
      await database
          .into(database.branchInventories)
          .insertOnConflictUpdate(BranchInventoriesCompanion.insert(
            productId: id,
            branchId: branchId,
            stockOnHand: Value(quantity),
            reorderPoint: Value(int.parse('${data['reorder_level'] ?? 0}')),
            version: Value((stock?.version ?? 0) + 1),
            updatedAt: now,
            inventoryDetailsJson: Value(jsonEncode({
              for (final key in branchKeys)
                if (data.containsKey(key)) key: data[key]
            })),
          ));
      final delta = quantity - (stock?.stockOnHand ?? 0);
      if (delta != 0) {
        await database
            .into(database.inventoryMovements)
            .insert(InventoryMovementsCompanion.insert(
              id: _uuid.v4(),
              branchId: branchId,
              productId: id,
              type: 'manual_adjustment',
              quantityDelta: delta,
              balanceAfter: quantity,
              referenceType: 'inventory_editor',
              referenceId: id,
              occurredAt: now,
            ));
      }
      await database
          .into(database.inventoryChanges)
          .insert(InventoryChangesCompanion.insert(
            id: _uuid.v4(),
            productId: id,
            branchId: branchId,
            actorId: actor.id,
            reason: reason.trim(),
            beforeJson: jsonEncode(before),
            afterJson: jsonEncode(await read(id, branchId)),
            createdAt: now,
          ));
      return id;
    });
  }

  Future<List<InventoryChange>> history(String productId, String branchId) =>
      (database.select(database.inventoryChanges)
            ..where((r) =>
                r.productId.equals(productId) & r.branchId.equals(branchId))
            ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
            ..limit(100))
          .get();
}
