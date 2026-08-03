import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/inventory/inventory_transfer.dart';
import '../database.dart';
import 'audit_trail_repository.dart';

class InventoryTransferRepository {
  InventoryTransferRepository(this.database, {Uuid uuid = const Uuid()})
      : _uuid = uuid,
        _audit = AuditTrailRepository(database, uuid: uuid);

  final AppDatabase database;
  final Uuid _uuid;
  final AuditTrailRepository _audit;

  Future<String> dispatch(InventoryTransferCommand command) {
    return database.transaction(() async {
      _validateCommand(command);
      final source = await _activeBranch(command.sourceBranchId);
      final destination = await _activeBranch(command.destinationBranchId);
      final product = await (database.select(database.products)
            ..where((row) => row.id.equals(command.productId)))
          .getSingleOrNull();
      if (product == null || !product.isActive) {
        throw StateError('Product is missing or inactive.');
      }
      final sourceInventory = await _inventory(
        source.id,
        product.id,
      );
      if (sourceInventory == null) {
        throw StateError('Product is not configured at the source branch.');
      }
      final destinationInventory = await _inventory(
        destination.id,
        product.id,
      );
      if (destinationInventory == null) {
        throw StateError(
            'Product is not configured at the destination branch.');
      }
      if (sourceInventory.stockOnHand < command.quantity) {
        throw StateError('Insufficient source-branch stock.');
      }

      final transferId = _uuid.v4();
      final sourceBalance = sourceInventory.stockOnHand - command.quantity;
      await (database.update(database.branchInventories)
            ..where(
              (row) =>
                  row.branchId.equals(source.id) &
                  row.productId.equals(product.id),
            ))
          .write(
        BranchInventoriesCompanion(
          stockOnHand: Value(sourceBalance),
          version: Value(sourceInventory.version + 1),
          updatedAt: Value(command.occurredAt),
        ),
      );
      await database.into(database.inventoryTransfers).insert(
            InventoryTransfersCompanion.insert(
              id: transferId,
              productId: product.id,
              sourceBranchId: source.id,
              destinationBranchId: destination.id,
              quantity: command.quantity,
              status: InventoryTransferStatus.inTransit.name,
              createdBy: command.actorId.trim(),
              createdAt: command.occurredAt,
              dispatchedAt: command.occurredAt,
            ),
          );
      await database.into(database.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              id: _uuid.v4(),
              branchId: source.id,
              productId: product.id,
              type: 'transfer_out',
              quantityDelta: -command.quantity,
              balanceAfter: sourceBalance,
              referenceType: 'inventory_transfer',
              referenceId: transferId,
              occurredAt: command.occurredAt,
            ),
          );
      await _recordTransition(
        transferId: transferId,
        branchId: source.id,
        actorId: command.actorId,
        eventType: 'inventory.transfer_dispatched',
        occurredAt: command.occurredAt,
        payload: {
          'transferId': transferId,
          'productId': product.id,
          'sku': product.sku,
          'sourceBranchId': source.id,
          'destinationBranchId': destination.id,
          'quantity': command.quantity,
          'status': InventoryTransferStatus.inTransit.name,
        },
      );
      return transferId;
    });
  }

  Future<void> receive({
    required String transferId,
    required String destinationBranchId,
    required String actorId,
    required DateTime receivedAt,
  }) {
    return database.transaction(() async {
      if (actorId.trim().isEmpty) throw ArgumentError.value(actorId, 'actorId');
      final transfer = await (database.select(database.inventoryTransfers)
            ..where((row) => row.id.equals(transferId)))
          .getSingleOrNull();
      if (transfer == null) throw StateError('Transfer was not found.');
      if (transfer.destinationBranchId != destinationBranchId) {
        throw StateError(
            'Only the destination branch may receive this transfer.');
      }
      if (transfer.status == InventoryTransferStatus.received.name) {
        throw StateError('Transfer is already received.');
      }
      if (transfer.status != InventoryTransferStatus.inTransit.name) {
        throw StateError('Only an in-transit transfer may be received.');
      }
      await _activeBranch(destinationBranchId);
      final inventory = await _inventory(
        destinationBranchId,
        transfer.productId,
      );
      if (inventory == null) {
        throw StateError(
            'Product is not configured at the destination branch.');
      }
      final destinationBalance = inventory.stockOnHand + transfer.quantity;
      await (database.update(database.branchInventories)
            ..where(
              (row) =>
                  row.branchId.equals(destinationBranchId) &
                  row.productId.equals(transfer.productId),
            ))
          .write(
        BranchInventoriesCompanion(
          stockOnHand: Value(destinationBalance),
          version: Value(inventory.version + 1),
          updatedAt: Value(receivedAt),
        ),
      );
      await (database.update(database.inventoryTransfers)
            ..where((row) => row.id.equals(transfer.id)))
          .write(
        InventoryTransfersCompanion(
          status: Value(InventoryTransferStatus.received.name),
          receivedBy: Value(actorId.trim()),
          receivedAt: Value(receivedAt),
          version: Value(transfer.version + 1),
        ),
      );
      await database.into(database.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              id: _uuid.v4(),
              branchId: destinationBranchId,
              productId: transfer.productId,
              type: 'transfer_in',
              quantityDelta: transfer.quantity,
              balanceAfter: destinationBalance,
              referenceType: 'inventory_transfer',
              referenceId: transfer.id,
              occurredAt: receivedAt,
            ),
          );
      await _recordTransition(
        transferId: transfer.id,
        branchId: destinationBranchId,
        actorId: actorId,
        eventType: 'inventory.transfer_received',
        occurredAt: receivedAt,
        payload: {
          'transferId': transfer.id,
          'productId': transfer.productId,
          'sourceBranchId': transfer.sourceBranchId,
          'destinationBranchId': destinationBranchId,
          'quantity': transfer.quantity,
          'status': InventoryTransferStatus.received.name,
        },
      );
    });
  }

  Future<void> cancel({
    required String transferId,
    required String sourceBranchId,
    required String actorId,
    required String reason,
    required DateTime cancelledAt,
  }) {
    return database.transaction(() async {
      if (actorId.trim().isEmpty) throw ArgumentError.value(actorId, 'actorId');
      if (reason.trim().isEmpty) throw ArgumentError.value(reason, 'reason');
      final transfer = await (database.select(database.inventoryTransfers)
            ..where((row) => row.id.equals(transferId)))
          .getSingleOrNull();
      if (transfer == null) throw StateError('Transfer was not found.');
      if (transfer.sourceBranchId != sourceBranchId) {
        throw StateError('Only the source branch may cancel this transfer.');
      }
      if (transfer.status != InventoryTransferStatus.inTransit.name) {
        throw StateError('Only an in-transit transfer may be cancelled.');
      }
      final inventory = await _inventory(sourceBranchId, transfer.productId);
      if (inventory == null) {
        throw StateError('Product is not configured at the source branch.');
      }
      final restoredBalance = inventory.stockOnHand + transfer.quantity;
      await (database.update(database.branchInventories)
            ..where(
              (row) =>
                  row.branchId.equals(sourceBranchId) &
                  row.productId.equals(transfer.productId),
            ))
          .write(
        BranchInventoriesCompanion(
          stockOnHand: Value(restoredBalance),
          version: Value(inventory.version + 1),
          updatedAt: Value(cancelledAt),
        ),
      );
      await (database.update(database.inventoryTransfers)
            ..where((row) => row.id.equals(transfer.id)))
          .write(
        InventoryTransfersCompanion(
          status: Value(InventoryTransferStatus.cancelled.name),
          cancelledBy: Value(actorId.trim()),
          cancelledAt: Value(cancelledAt),
          cancellationReason: Value(reason.trim()),
          version: Value(transfer.version + 1),
        ),
      );
      await database.into(database.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              id: _uuid.v4(),
              branchId: sourceBranchId,
              productId: transfer.productId,
              type: 'transfer_cancelled',
              quantityDelta: transfer.quantity,
              balanceAfter: restoredBalance,
              referenceType: 'inventory_transfer',
              referenceId: transfer.id,
              occurredAt: cancelledAt,
            ),
          );
      await _recordTransition(
        transferId: transfer.id,
        branchId: sourceBranchId,
        actorId: actorId,
        eventType: 'inventory.transfer_cancelled',
        occurredAt: cancelledAt,
        payload: {
          'transferId': transfer.id,
          'productId': transfer.productId,
          'sourceBranchId': sourceBranchId,
          'destinationBranchId': transfer.destinationBranchId,
          'quantity': transfer.quantity,
          'status': InventoryTransferStatus.cancelled.name,
          'reason': reason.trim(),
        },
      );
    });
  }

  void _validateCommand(InventoryTransferCommand command) {
    if (command.productId.trim().isEmpty) {
      throw ArgumentError.value(command.productId, 'productId');
    }
    if (command.actorId.trim().isEmpty) {
      throw ArgumentError.value(command.actorId, 'actorId');
    }
    if (command.quantity <= 0) {
      throw ArgumentError.value(command.quantity, 'quantity');
    }
    if (command.sourceBranchId == command.destinationBranchId) {
      throw ArgumentError('Source and destination branches must differ.');
    }
  }

  Future<Branche> _activeBranch(String id) async {
    final branch = await (database.select(database.branches)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (branch == null || !branch.isActive) {
      throw StateError('Branch is missing or inactive.');
    }
    return branch;
  }

  Future<BranchInventory?> _inventory(String branchId, String productId) {
    return (database.select(database.branchInventories)
          ..where(
            (row) =>
                row.branchId.equals(branchId) & row.productId.equals(productId),
          ))
        .getSingleOrNull();
  }

  Future<void> _recordTransition({
    required String transferId,
    required String branchId,
    required String actorId,
    required String eventType,
    required DateTime occurredAt,
    required Map<String, Object?> payload,
  }) async {
    final payloadJson = jsonEncode(payload);
    await _audit.append(
      branchId: branchId,
      actorId: actorId.trim(),
      eventType: eventType,
      entityType: 'inventory_transfer',
      entityId: transferId,
      payloadJson: payloadJson,
      occurredAt: occurredAt,
    );
    await database.into(database.syncOutboxEvents).insert(
          SyncOutboxEventsCompanion.insert(
            id: _uuid.v4(),
            branchId: branchId,
            aggregateType: 'inventory_transfer',
            aggregateId: transferId,
            eventType: eventType,
            idempotencyKey: '$eventType:$transferId',
            payloadJson: payloadJson,
            createdAt: occurredAt,
          ),
        );
  }
}
