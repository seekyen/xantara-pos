enum AccountPlan { standard, premium }

class SyncEntitlement {
  const SyncEntitlement({
    required this.businessId,
    required this.plan,
    required this.syncEnabled,
    this.validUntil,
  });

  final String businessId;
  final AccountPlan plan;
  final bool syncEnabled;
  final DateTime? validUntil;

  bool isActiveAt(DateTime now) {
    if (businessId.trim().isEmpty ||
        plan != AccountPlan.premium ||
        !syncEnabled) {
      return false;
    }
    final expiry = validUntil;
    return expiry == null || expiry.isAfter(now);
  }
}

class SyncEnvelope {
  const SyncEnvelope({
    required this.localEventId,
    required this.businessId,
    required this.branchId,
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.idempotencyKey,
    required this.payloadJson,
    required this.createdAt,
  });

  final String localEventId;
  final String businessId;
  final String branchId;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final String idempotencyKey;
  final String payloadJson;
  final DateTime createdAt;
}

class SyncAcknowledgement {
  const SyncAcknowledgement({
    required this.serverEventId,
    required this.acceptedAt,
  });

  final String serverEventId;
  final DateTime acceptedAt;
}

abstract interface class PremiumSyncTransport {
  Future<SyncAcknowledgement> upload(SyncEnvelope envelope);
}

class PremiumSyncResult {
  const PremiumSyncResult({
    required this.processed,
    required this.succeeded,
    this.eventId,
    this.error,
  });

  final bool processed;
  final bool succeeded;
  final String? eventId;
  final String? error;
}
