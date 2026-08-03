import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/catalog_repository.dart';

void main() {
  late AppDatabase database;
  late CatalogRepository repository;
  final now = DateTime(2026, 7, 11, 9);

  Future<void> seedBranch(String branchId) => database.into(database.branches).insert(
        BranchesCompanion.insert(
          id: branchId,
          code: branchId,
          name: branchId,
          createdAt: now,
        ),
      );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = CatalogRepository(database);
    await seedBranch('branch-main');
    await seedBranch('branch-2');
  });

  tearDown(() => database.close());

  test('creates a product and lists it for the branch with stock', () async {
    final id = await repository.createProduct(
      branchId: 'branch-main',
      name: 'Hot Coffee',
      unitPriceCentavos: 8500,
      categoryId: 'beverages',
      colorArgb: 0xFF6F4E37,
      stock: 50,
    );

    final rows = await repository.watchBranchProducts('branch-main').first;
    expect(rows, hasLength(1));
    expect(rows.single.product.id, id);
    expect(rows.single.product.name, 'Hot Coffee');
    expect(rows.single.inventory.stockOnHand, 50);

    final otherBranch = await repository.watchBranchProducts('branch-2').first;
    expect(otherBranch, isEmpty);
  });

  test('keeps branch stock independent across branches', () async {
    final id = await repository.createProduct(
      branchId: 'branch-main',
      name: 'Iced Coffee',
      unitPriceCentavos: 9500,
      categoryId: 'beverages',
      colorArgb: 0xFF4A90D9,
      stock: 40,
    );
    await repository.adjustStock(
        branchId: 'branch-main', productId: id, stock: 10);
    await database.into(database.branchInventories).insert(
          BranchInventoriesCompanion.insert(
            branchId: 'branch-2',
            productId: id,
            stockOnHand: const Value(99),
            updatedAt: now,
          ),
        );

    final mainRows = await repository.watchBranchProducts('branch-main').first;
    final branch2Rows = await repository.watchBranchProducts('branch-2').first;
    expect(mainRows.single.inventory.stockOnHand, 10);
    expect(branch2Rows.single.inventory.stockOnHand, 99);
  });

  test('updates product fields, stock, and availability together', () async {
    final id = await repository.createProduct(
      branchId: 'branch-main',
      name: 'Green Tea',
      unitPriceCentavos: 7500,
      categoryId: 'beverages',
      colorArgb: 0xFF5D8A5E,
      stock: 30,
    );

    await repository.updateProduct(
      productId: id,
      branchId: 'branch-main',
      name: 'Matcha Latte',
      unitPriceCentavos: 12000,
      categoryId: 'desserts',
      colorArgb: 0xFF123456,
      stock: 5,
      isAvailable: false,
    );

    final rows = await repository.watchBranchProducts('branch-main').first;
    expect(rows, isEmpty, reason: 'unavailable products are excluded');

    final product = await (database.select(database.products)
          ..where((row) => row.id.equals(id)))
        .getSingle();
    expect(product.name, 'Matcha Latte');
    expect(product.unitPriceCentavos, 12000);
    expect(product.categoryId, 'desserts');
    expect(product.isActive, isFalse);

    final inventory = await (database.select(database.branchInventories)
          ..where((row) =>
              row.branchId.equals('branch-main') & row.productId.equals(id)))
        .getSingle();
    expect(inventory.stockOnHand, 5);
  });

  test('adjusts stock and records an inventory movement', () async {
    final id = await repository.createProduct(
      branchId: 'branch-main',
      name: 'Mineral Water',
      unitPriceCentavos: 2500,
      categoryId: 'beverages',
      colorArgb: 0xFF78C1D4,
      stock: 100,
    );

    await repository.adjustStock(
        branchId: 'branch-main', productId: id, stock: 80);

    final movements = await (database.select(database.inventoryMovements)
          ..where((row) => row.productId.equals(id)))
        .get();
    expect(movements, hasLength(1));
    expect(movements.single.type, 'manual_adjustment');
    expect(movements.single.quantityDelta, -20);
    expect(movements.single.balanceAfter, 80);
  });

  test(
      'deletes the product once no branch carries it, but keeps it when '
      'another branch still does', () async {
    final id = await repository.createProduct(
      branchId: 'branch-main',
      name: 'Lemonade',
      unitPriceCentavos: 7000,
      categoryId: 'beverages',
      colorArgb: 0xFFD4C026,
      stock: 20,
    );
    await database.into(database.branchInventories).insert(
          BranchInventoriesCompanion.insert(
            branchId: 'branch-2',
            productId: id,
            stockOnHand: const Value(5),
            updatedAt: now,
          ),
        );

    await repository.deleteProduct(branchId: 'branch-main', productId: id);
    final stillExists = await (database.select(database.products)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    expect(stillExists != null, isTrue,
        reason: 'branch-2 still carries this product');

    await repository.deleteProduct(branchId: 'branch-2', productId: id);
    final gone = await (database.select(database.products)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    expect(gone == null, isTrue);
  });
}
