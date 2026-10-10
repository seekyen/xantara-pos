import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/features/auth/providers/auth_provider.dart';
import 'package:pos_app/features/auth/models/user_model.dart';
import 'package:pos_app/features/inventory/inventory_schema.dart';
import 'package:pos_app/features/inventory/screens/inventory_screen.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/database_seed.dart';
import 'package:pos_app/local/repositories/inventory_workspace_repository.dart';

const actor = StaffPrincipal(
    id: 'owner',
    displayName: 'Owner',
    email: 'owner@example.test',
    role: StaffRole.owner,
    branchIds: {'branch-main'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late InventoryWorkspaceRepository repository;
  late InventorySchema schema;
  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await seedDatabaseIfEmpty(database);
    repository = InventoryWorkspaceRepository(database);
    schema = await InventorySchema.load();
  });
  tearDown(() => database.close());

  Map<String, dynamic> draft() => {
        'tier': 'large',
        'revision': 0,
        'data': {
          ...schema.defaults(),
          'name': 'Test item',
          'selling_price': '12.34',
          'cost_price': '10.00',
          'quantity': 5,
          'reorder_level': 6,
          'units': [
            {'unit': 'box', 'factor': '12'}
          ]
        }
      };

  test('Product metadata, stock and history save atomically', () async {
    final id = await repository.save(
        document: draft(),
        branchId: 'branch-main',
        actor: actor,
        reason: 'Opening stock',
        schema: schema,
        expectedQuantity: 0);
    final doc = await repository.read(id, 'branch-main');
    expect(doc['data']['sku'], startsWith('ITM'));
    expect(doc['data']['quantity'], 5);
    expect(doc['data']['selling_price'], '12.34');
    expect((await repository.history(id, 'branch-main')).single.reason,
        'Opening stock');
    final changed = {...doc, 'tier': 'basic'};
    await repository.save(
        document: changed,
        branchId: 'branch-main',
        actor: actor,
        reason: 'Simplify',
        schema: schema,
        expectedQuantity: 5);
    expect((await repository.read(id, 'branch-main'))['data']['units'],
        isNotEmpty);
    expect((await repository.history(id, 'branch-main')).length, 2);
    await expectLater(
        repository.save(
            document: changed,
            branchId: 'branch-main',
            actor: actor,
            reason: 'Stale',
            schema: schema,
            expectedQuantity: 5),
        throwsStateError);
  });

  test('Invalid money and unauthorized branch do not mutate inventory',
      () async {
    final doc = draft();
    doc['data']['selling_price'] = '12.345';
    await expectLater(
        repository.save(
            document: doc,
            branchId: 'branch-main',
            actor: actor,
            reason: 'Bad cost',
            schema: schema,
            expectedQuantity: 0),
        throwsFormatException);
    await expectLater(
        repository.save(
            document: draft(),
            branchId: 'branch-br002',
            actor: actor,
            reason: 'Wrong branch',
            schema: schema,
            expectedQuantity: 0),
        throwsA(isA<AuthorizationException>()));
    expect(await database.select(database.inventoryChanges).get(), isEmpty);
  });

  test('Schema v3 migration preserves catalog and stock', () async {
    final directory =
        await Directory.systemTemp.createTemp('xantara-inventory-migration-');
    final file = File('${directory.path}/inventory.sqlite');
    final original = AppDatabase(NativeDatabase(file));
    await seedDatabaseIfEmpty(original);
    final before = await original.select(original.products).get();
    await original.customStatement('DROP TABLE inventory_changes');
    await original.customStatement('DROP TABLE company_registration');
    await original.customStatement('DROP TABLE invoice_loyalty');
    await original.customStatement('DROP TABLE loyalty_customers');
    await original.customStatement('DROP TABLE loyalty_promos');
    await original.customStatement(
        'ALTER TABLE products DROP COLUMN inventory_profile_json');
    await original.customStatement(
        'ALTER TABLE branch_inventories DROP COLUMN inventory_details_json');
    await original.customStatement('PRAGMA user_version = 3');
    await original.close();
    final migrated = AppDatabase(NativeDatabase(file));
    try {
      expect((await migrated.select(migrated.products).get()).map((p) => p.id),
          before.map((p) => p.id));
      expect(await migrated.select(migrated.inventoryChanges).get(), isEmpty);
    } finally {
      await migrated.close();
      await directory.delete(recursive: true);
    }
  });

  testWidgets('Phone inventory editor switches tiers and saves a basic item',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)]);
    addTearDown(container.dispose);
    container.read(authProvider.notifier).state = const AuthState(
        user: UserModel(
            id: 'owner',
            name: 'Owner',
            email: 'owner@example.test',
            role: 'owner',
            branchIds: {'branch-main'}));
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InventoryScreen())));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Add item'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.text('Inventory tier'), findsOneWidget);
    expect(find.text('Supplier offers'), findsNothing);
    await tester.tap(find.text('Basic').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Standard').last);
    await tester.pumpAndSettle();
    expect(find.text('Reorder controls and unit conversions'), findsOneWidget);
    await tester.tap(find.text('Standard').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Basic').last);
    await tester.pumpAndSettle();
    final name = find.widgetWithText(TextFormField, 'Product name *');
    await tester.ensureVisible(name);
    await tester.enterText(name, 'Phone saved item');
    final reason = find.widgetWithText(TextFormField, 'Change reason');
    await tester.ensureVisible(reason);
    await tester.enterText(reason, 'Phone test');
    await tester.runAsync(() async {
      await tester.tap(find.text('Save on device'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    expect(find.text('New inventory item'), findsNothing);
    final saved = await database.select(database.products).get();
    expect(saved.where((p) => p.name == 'Phone saved item'), hasLength(1));
    expect(
        (await database.select(database.inventoryChanges).get()).single.reason,
        'Phone test');
  });
}
