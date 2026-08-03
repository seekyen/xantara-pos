enum SupplierAlertField {
  branchCode,
  sku,
  productName,
  stockOnHand,
  reorderPoint,
  suggestedOrderQuantity,
}

enum SupplierDeliveryStatus { queued, processing, completed, failed }

class SupplierAlertEnvelope {
  const SupplierAlertEnvelope({
    required this.deliveryId,
    required this.connectorId,
    required this.idempotencyKey,
    required this.occurredAt,
    required this.authorizedData,
  });

  final String deliveryId;
  final String connectorId;
  final String idempotencyKey;
  final DateTime occurredAt;
  final Map<String, Object?> authorizedData;
}

class SupplierDeliveryAcknowledgement {
  const SupplierDeliveryAcknowledgement({
    required this.externalReference,
    required this.acceptedAt,
  });

  final String externalReference;
  final DateTime acceptedAt;
}

abstract interface class SupplierConnectorAdapter {
  String get connectorType;

  Future<SupplierDeliveryAcknowledgement> deliver(
    SupplierAlertEnvelope alert,
  );
}

class SupplierDeliveryResult {
  const SupplierDeliveryResult({
    required this.processed,
    required this.succeeded,
    this.deliveryId,
    this.error,
  });

  final bool processed;
  final bool succeeded;
  final String? deliveryId;
  final String? error;
}
