import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_seed.dart';

void main() {
  test('seeds the clean three-branch sample inventory', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await seedDatabaseIfEmpty(database);

    final branches = await database.select(database.branches).get();
    expect(
      branches.map((branch) => (branch.id, branch.code, branch.name)).toSet(),
      {
        ('branch-main', 'MAIN', 'Head Office'),
        ('branch-br002', 'BGC', 'BGC'),
        ('branch-br003', 'MKT', 'Makati'),
      },
    );

    final products = await database.select(database.products).get();
    expect(products, hasLength(1));
    expect(products.single.sku, 'SAMPLE-001');
    expect(products.single.name, 'Sample Product');
    expect(products.single.unitPriceCentavos, 10000);

    final inventory = await database.select(database.branchInventories).get();
    expect(inventory, hasLength(3));
    expect(inventory.every((row) => row.stockOnHand == 10), isTrue);
  });
}
