import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class CatalogProduct {
  const CatalogProduct({required this.product, required this.inventory});

  final Product product;
  final BranchInventory inventory;
}

/// Branch-scoped product catalog and stock. Each branch owns an independent
/// [BranchInventories] row per product, matching the pre-existing per-branch
/// isolation behavior; the [Products] row (name/price/category/tax) is
/// shared across branches.
class CatalogRepository {
  CatalogRepository(this.database, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase database;
  final Uuid _uuid;

  Stream<List<CatalogProduct>> watchBranchProducts(String branchId) {
    final query = database.select(database.products).join([
      innerJoin(
        database.branchInventories,
        database.branchInventories.productId.equalsExp(database.products.id) &
            database.branchInventories.branchId.equals(branchId),
      ),
    ])
      ..where(database.products.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(database.products.name)]);
    return query.watch().map(
          (rows) => rows
              .map((row) => CatalogProduct(
                    product: row.readTable(database.products),
                    inventory: row.readTable(database.branchInventories),
                  ))
              .toList(growable: false),
        );
  }

  Future<String> createProduct({
    required String branchId,
    required String name,
    required int unitPriceCentavos,
    required String categoryId,
    required int colorArgb,
    required int stock,
    String taxCategory = 'vat12',
  }) {
    return database.transaction(() async {
      final now = DateTime.now();
      final id = _uuid.v4();
      await database.into(database.products).insert(
            ProductsCompanion.insert(
              id: id,
              sku: id,
              name: name,
              taxCategory: taxCategory,
              unitPriceCentavos: unitPriceCentavos,
              categoryId: Value(categoryId),
              colorArgb: Value(colorArgb),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.into(database.branchInventories).insert(
            BranchInventoriesCompanion.insert(
              branchId: branchId,
              productId: id,
              stockOnHand: Value(stock),
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  Future<void> updateProduct({
    required String productId,
    required String branchId,
    required String name,
    required int unitPriceCentavos,
    required String categoryId,
    required int colorArgb,
    required int stock,
    required bool isAvailable,
  }) {
    return database.transaction(() async {
      final now = DateTime.now();
      await (database.update(database.products)
            ..where((row) => row.id.equals(productId)))
          .write(
        ProductsCompanion(
          name: Value(name),
          unitPriceCentavos: Value(unitPriceCentavos),
          categoryId: Value(categoryId),
          colorArgb: Value(colorArgb),
          isActive: Value(isAvailable),
          updatedAt: Value(now),
        ),
      );
      await _writeStock(branchId: branchId, productId: productId, stock: stock);
    });
  }

  Future<void> setAvailability(String productId, bool isActive) {
    return (database.update(database.products)
          ..where((row) => row.id.equals(productId)))
        .write(
      ProductsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> adjustStock({
    required String branchId,
    required String productId,
    required int stock,
  }) {
    return database.transaction(
      () => _writeStock(branchId: branchId, productId: productId, stock: stock),
    );
  }

  Future<void> _writeStock({
    required String branchId,
    required String productId,
    required int stock,
  }) async {
    final now = DateTime.now();
    final inventory = await (database.select(database.branchInventories)
          ..where(
            (row) =>
                row.branchId.equals(branchId) &
                row.productId.equals(productId),
          ))
        .getSingleOrNull();
    final clamped = stock.clamp(0, 999999);
    if (inventory == null) {
      await database.into(database.branchInventories).insert(
            BranchInventoriesCompanion.insert(
              branchId: branchId,
              productId: productId,
              stockOnHand: Value(clamped),
              updatedAt: now,
            ),
          );
      return;
    }
    await (database.update(database.branchInventories)
          ..where(
            (row) =>
                row.branchId.equals(branchId) &
                row.productId.equals(productId),
          ))
        .write(
      BranchInventoriesCompanion(
        stockOnHand: Value(clamped),
        version: Value(inventory.version + 1),
        updatedAt: Value(now),
      ),
    );
    await database.into(database.inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: _uuid.v4(),
            branchId: branchId,
            productId: productId,
            type: 'manual_adjustment',
            quantityDelta: clamped - inventory.stockOnHand,
            balanceAfter: clamped,
            referenceType: 'admin_adjustment',
            referenceId: productId,
            occurredAt: now,
          ),
        );
  }

  /// Removes this branch's stock record; if no branch carries the product
  /// any more, the product itself is removed (or deactivated if it is
  /// still referenced by historic invoice lines).
  Future<void> deleteProduct({
    required String branchId,
    required String productId,
  }) {
    return database.transaction(() async {
      await (database.delete(database.branchInventories)
            ..where(
              (row) =>
                  row.branchId.equals(branchId) &
                  row.productId.equals(productId),
            ))
          .go();
      final remaining = await (database.select(database.branchInventories)
            ..where((row) => row.productId.equals(productId)))
          .get();
      if (remaining.isNotEmpty) return;
      try {
        await (database.delete(database.products)
              ..where((row) => row.id.equals(productId)))
            .go();
      } catch (_) {
        await (database.update(database.products)
              ..where((row) => row.id.equals(productId)))
            .write(const ProductsCompanion(isActive: Value(false)));
      }
    });
  }
}
