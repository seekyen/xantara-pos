import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import '../database_seed.dart';

/// Applies an authenticated cloud catalog snapshot to the offline POS store.
///
/// The cloud catalog is authoritative only after the outbound queue has been
/// drained. [CloudSyncController] enforces that ordering before calling this
/// repository, so replacing stock cannot hide an unsent local sale.
class CloudCatalogRepository {
  const CloudCatalogRepository(this.database);

  final AppDatabase database;

  Future<int> replaceMainCatalog(Object? response) async {
    if (response is! List) {
      throw const FormatException('Catalog response must be a list.');
    }
    final items = response.map(_CloudCatalogItem.parse).toList(growable: false);
    final skus = items.map((item) => item.sku).toSet();
    if (skus.length != items.length) {
      throw const FormatException('Catalog response contains duplicate SKUs.');
    }

    return database.transaction(() async {
      const branchCode = 'MAIN';
      var branch = await (database.select(database.branches)
            ..where((row) => row.code.equals(branchCode)))
          .getSingleOrNull();
      if (branch == null) {
        final now = DateTime.now();
        final branchId = branchIdForCode(branchCode);
        await database.into(database.branches).insert(
              BranchesCompanion.insert(
                id: branchId,
                code: branchCode,
                name: 'Main Branch',
                createdAt: now,
              ),
            );
        branch = await (database.select(database.branches)
              ..where((row) => row.id.equals(branchId)))
            .getSingle();
      }

      final now = DateTime.now();
      for (final item in items) {
        final existing = await (database.select(database.products)
              ..where((row) => row.sku.equals(item.sku)))
            .getSingleOrNull();
        final productId = existing?.id ?? item.sku;
        await database.into(database.products).insertOnConflictUpdate(
              ProductsCompanion.insert(
                id: productId,
                sku: item.sku,
                name: item.name,
                taxCategory: item.taxCategory,
                unitPriceCentavos: item.unitPriceCentavos,
                categoryId: Value(item.categoryId),
                colorArgb: Value(existing?.colorArgb ?? 0xFF1565C0),
                isActive: const Value(true),
                version: Value((existing?.version ?? 0) + 1),
                inventoryProfileJson: Value(jsonEncode({
                  'source': 'cloud',
                  'cloud_id': item.cloudId,
                  'cloud_revision': item.revision,
                  'cloud_quantity': item.quantity,
                  'tier': item.tier,
                  'data': item.data,
                })),
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
              ),
            );

        final existingStock = await (database.select(database.branchInventories)
              ..where((row) =>
                  row.branchId.equals(branch!.id) &
                  row.productId.equals(productId)))
            .getSingleOrNull();
        await database.into(database.branchInventories).insertOnConflictUpdate(
              BranchInventoriesCompanion.insert(
                branchId: branch.id,
                productId: productId,
                stockOnHand: Value(item.quantity),
                reorderPoint: Value(item.reorderPoint),
                version: Value((existingStock?.version ?? 0) + 1),
                inventoryDetailsJson: Value(jsonEncode({
                  'source': 'cloud',
                  'branch': branchCode,
                  'stock': item.stock,
                })),
                updatedAt: now,
              ),
            );
      }

      // The authenticated MAIN response contains every active cloud product.
      // Keep historic rows for invoice integrity, but hide products removed or
      // deactivated in the admin site from new POS sales.
      final localProducts = await database.select(database.products).get();
      for (final product in localProducts) {
        if (!skus.contains(product.sku) && product.isActive) {
          await (database.update(database.products)
                ..where((row) => row.id.equals(product.id)))
              .write(ProductsCompanion(
            isActive: const Value(false),
            updatedAt: Value(now),
          ));
        }
      }
      return items.length;
    });
  }
}

class _CloudCatalogItem {
  const _CloudCatalogItem({
    required this.cloudId,
    required this.revision,
    required this.tier,
    required this.data,
    required this.stock,
    required this.sku,
    required this.name,
    required this.taxCategory,
    required this.unitPriceCentavos,
    required this.categoryId,
    required this.quantity,
    required this.reorderPoint,
  });

  factory _CloudCatalogItem.parse(Object? value) {
    if (value is! Map) {
      throw const FormatException('Every catalog item must be an object.');
    }
    final dataValue = value['data'];
    if (dataValue is! Map) {
      throw const FormatException('Every catalog item requires data.');
    }
    final data = Map<String, dynamic>.from(dataValue);
    final sku = '${data['sku'] ?? ''}'.trim();
    final name = '${data['name'] ?? ''}'.trim();
    if (sku.isEmpty || name.isEmpty) {
      throw const FormatException(
          'Every catalog item requires a SKU and name.');
    }
    final quantity = _wholeNumber(data['quantity'], 'quantity');
    final reorderPoint = _wholeNumber(data['reorder_level'], 'reorder level');
    final taxCategory = '${data['tax_category'] ?? 'vat12'}';
    if (!const {'vat12', 'vat_exempt', 'zero_rated', 'non_vat'}
        .contains(taxCategory)) {
      throw FormatException('Invalid tax category for $sku.');
    }
    return _CloudCatalogItem(
      cloudId: value['id'],
      revision: _wholeNumber(value['revision'], 'revision'),
      tier: '${value['tier'] ?? 'basic'}',
      data: data,
      stock: value['stock'],
      sku: sku,
      name: name,
      taxCategory: taxCategory,
      unitPriceCentavos: _moneyToCentavos(data['selling_price']),
      categoryId: '${data['category'] ?? 'uncategorized'}'.trim().isEmpty
          ? 'uncategorized'
          : '${data['category']}'.trim(),
      quantity: quantity,
      reorderPoint: reorderPoint,
    );
  }

  final Object? cloudId;
  final int revision;
  final String tier;
  final Map<String, dynamic> data;
  final Object? stock;
  final String sku;
  final String name;
  final String taxCategory;
  final int unitPriceCentavos;
  final String categoryId;
  final int quantity;
  final int reorderPoint;
}

int _wholeNumber(Object? value, String field) {
  final number = value is num ? value : num.tryParse('${value ?? 0}');
  if (number == null || !number.isFinite || number < 0 || number % 1 != 0) {
    throw FormatException(
        'Catalog $field must be a non-negative whole number.');
  }
  return number.toInt();
}

int _moneyToCentavos(Object? value) {
  final text = '${value ?? 0}'.trim();
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
    throw const FormatException(
        'Catalog selling price must have at most two decimal places.');
  }
  final parts = text.split('.');
  return int.parse(parts[0]) * 100 +
      int.parse(parts.length == 1 ? '00' : parts[1].padRight(2, '0'));
}
