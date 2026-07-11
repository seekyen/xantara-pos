enum InventoryTransferStatus { inTransit, received, cancelled }

class InventoryTransferCommand {
  const InventoryTransferCommand({
    required this.productId,
    required this.sourceBranchId,
    required this.destinationBranchId,
    required this.quantity,
    required this.actorId,
    required this.occurredAt,
  });

  final String productId;
  final String sourceBranchId;
  final String destinationBranchId;
  final int quantity;
  final String actorId;
  final DateTime occurredAt;
}
