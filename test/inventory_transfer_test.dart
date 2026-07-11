import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/inventory/inventory_transfer.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/inventory_transfer_repository.dart';

void main() {
  late AppDatabase database;
  late InventoryTransferRepository transfers;
  final now = DateTime(2026, 7, 11, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    transfers = InventoryTransferRepository(database);
    await _seed(database, now);
  });

  tearDown(() => database.close());

  test('dispatch deducts only source stock and creates in-transit records',
      () async {
    final id = await transfers.dispatch(_command(now, quantity: 4));

    expect(await _stock(database, 'branch-source'), 6);
    expect(await _stock(database, 'branch-destination'), 3);
    final transfer =
        await database.select(database.inventoryTransfers).getSingle();
    expect(transfer.id, id);
    expect(transfer.status, InventoryTransferStatus.inTransit.name);
    final movements = await database.select(database.inventoryMovements).get();
    expect(movements, hasLength(1));
    expect(movements.single.type, 'transfer_out');
    expect(movements.single.quantityDelta, -4);
    expect(await database.select(database.auditEvents).get(), hasLength(1));
    expect(
        await database.select(database.syncOutboxEvents).get(), hasLength(1));
  });

  test('destination receipt adds stock once and preserves paired ledgers',
      () async {
    final id = await transfers.dispatch(_command(now, quantity: 4));

    await transfers.receive(
      transferId: id,
      destinationBranchId: 'branch-destination',
      actorId: 'receiver-1',
      receivedAt: now.add(const Duration(hours: 2)),
    );

    expect(await _stock(database, 'branch-source'), 6);
    expect(await _stock(database, 'branch-destination'), 7);
    final transfer =
        await database.select(database.inventoryTransfers).getSingle();
    expect(transfer.status, InventoryTransferStatus.received.name);
    expect(transfer.receivedBy, 'receiver-1');
    final movements = await database.select(database.inventoryMovements).get();
    expect(movements.map((movement) => movement.type),
        ['transfer_out', 'transfer_in']);
    expect(await database.select(database.auditEvents).get(), hasLength(2));
    expect(
        await database.select(database.syncOutboxEvents).get(), hasLength(2));

    expect(
      () => transfers.receive(
        transferId: id,
        destinationBranchId: 'branch-destination',
        actorId: 'receiver-1',
        receivedAt: now.add(const Duration(hours: 3)),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await _stock(database, 'branch-destination'), 7);
  });

  test('wrong branch cannot receive a transfer', () async {
    final id = await transfers.dispatch(_command(now, quantity: 2));

    expect(
      () => transfers.receive(
        transferId: id,
        destinationBranchId: 'branch-source',
        actorId: 'receiver-1',
        receivedAt: now.add(const Duration(hours: 1)),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await _stock(database, 'branch-source'), 8);
    expect(await _stock(database, 'branch-destination'), 3);
  });

  test('insufficient stock rolls back transfer, ledger, audit, and outbox',
      () async {
    expect(
      () => transfers.dispatch(_command(now, quantity: 11)),
      throwsA(isA<StateError>()),
    );

    expect(await _stock(database, 'branch-source'), 10);
    expect(await database.select(database.inventoryTransfers).get(), isEmpty);
    expect(await database.select(database.inventoryMovements).get(), isEmpty);
    expect(await database.select(database.auditEvents).get(), isEmpty);
    expect(await database.select(database.syncOutboxEvents).get(), isEmpty);
  });

  test('source cancellation restores stock without crediting destination',
      () async {
    final id = await transfers.dispatch(_command(now, quantity: 4));

    await transfers.cancel(
      transferId: id,
      sourceBranchId: 'branch-source',
      actorId: 'manager-1',
      reason: 'Shipment damaged before dispatch',
      cancelledAt: now.add(const Duration(minutes: 30)),
    );

    expect(await _stock(database, 'branch-source'), 10);
    expect(await _stock(database, 'branch-destination'), 3);
    final transfer =
        await database.select(database.inventoryTransfers).getSingle();
    expect(transfer.status, InventoryTransferStatus.cancelled.name);
    expect(transfer.cancellationReason, 'Shipment damaged before dispatch');
  });
}

InventoryTransferCommand _command(DateTime now, {required int quantity}) {
  return InventoryTransferCommand(
    productId: 'product-1',
    sourceBranchId: 'branch-source',
    destinationBranchId: 'branch-destination',
    quantity: quantity,
    actorId: 'manager-1',
    occurredAt: now,
  );
}

Future<int> _stock(AppDatabase database, String branchId) async {
  final row = await (database.select(database.branchInventories)
        ..where((entry) => entry.branchId.equals(branchId)))
      .getSingle();
  return row.stockOnHand;
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  for (final branch in [
    ('branch-source', '001', 'Source Branch'),
    ('branch-destination', '002', 'Destination Branch'),
  ]) {
    await database.into(database.branches).insert(
          BranchesCompanion.insert(
            id: branch.$1,
            code: branch.$2,
            name: branch.$3,
            createdAt: now,
          ),
        );
  }
  await database.into(database.products).insert(
        ProductsCompanion.insert(
          id: 'product-1',
          sku: 'SKU-001',
          name: 'Transfer Product',
          taxCategory: 'vat12',
          unitPriceCentavos: 10000,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database.into(database.branchInventories).insert(
        BranchInventoriesCompanion.insert(
          branchId: 'branch-source',
          productId: 'product-1',
          stockOnHand: const Value(10),
          updatedAt: now,
        ),
      );
  await database.into(database.branchInventories).insert(
        BranchInventoriesCompanion.insert(
          branchId: 'branch-destination',
          productId: 'product-1',
          stockOnHand: const Value(3),
          updatedAt: now,
        ),
      );
}
