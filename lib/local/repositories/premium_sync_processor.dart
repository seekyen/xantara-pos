import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/sync/premium_sync.dart';
import '../database.dart';

class PremiumSyncProcessor {
  PremiumSyncProcessor({
    required this.database,
    required this.transport,
    this.leaseDuration = const Duration(minutes: 2),
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  final AppDatabase database;
  final PremiumSyncTransport transport;
  final Duration leaseDuration;
  final Uuid _uuid;

  Future<PremiumSyncResult> processNext({
    required SyncEntitlement entitlement,
    required DateTime now,
  }) async {
    if (!entitlement.isActiveAt(now)) {
      return const PremiumSyncResult(processed: false, succeeded: false);
    }
    if (leaseDuration <= Duration.zero) {
      throw StateError('Sync lease duration must be positive.');
    }

    final claim = await database.transaction(() async {
      final candidates = await (database.select(database.syncOutboxEvents)
            ..where((row) => row.syncedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();
      final event = candidates
          .where(
            (candidate) =>
                (candidate.nextAttemptAt == null ||
                    !candidate.nextAttemptAt!.isAfter(now)) &&
                (candidate.leaseId == null ||
                    candidate.leaseExpiresAt == null ||
                    !candidate.leaseExpiresAt!.isAfter(now)),
          )
          .firstOrNull;
      if (event == null) return null;

      final leaseId = _uuid.v4();
      await (database.update(database.syncOutboxEvents)
            ..where((row) => row.id.equals(event.id)))
          .write(
        SyncOutboxEventsCompanion(
          leaseId: Value(leaseId),
          leaseExpiresAt: Value(now.add(leaseDuration)),
          attemptCount: Value(event.attemptCount + 1),
          lastError: const Value(null),
        ),
      );
      return (event: event, leaseId: leaseId);
    });
    if (claim == null) {
      return const PremiumSyncResult(processed: false, succeeded: false);
    }

    final event = claim.event;
    try {
      final acknowledgement = await transport.upload(
        SyncEnvelope(
          localEventId: event.id,
          businessId: entitlement.businessId,
          branchId: event.branchId,
          aggregateType: event.aggregateType,
          aggregateId: event.aggregateId,
          eventType: event.eventType,
          idempotencyKey: event.idempotencyKey,
          payloadJson: event.payloadJson,
          createdAt: event.createdAt,
        ),
      );
      if (acknowledgement.serverEventId.trim().isEmpty) {
        throw StateError('Sync server returned an empty acknowledgement ID.');
      }
      final updated = await (database.update(database.syncOutboxEvents)
            ..where(
              (row) =>
                  row.id.equals(event.id) & row.leaseId.equals(claim.leaseId),
            ))
          .write(
        SyncOutboxEventsCompanion(
          syncedAt: Value(acknowledgement.acceptedAt),
          serverEventId: Value(acknowledgement.serverEventId),
          leaseId: const Value(null),
          leaseExpiresAt: const Value(null),
          nextAttemptAt: const Value(null),
          lastError: const Value(null),
        ),
      );
      if (updated != 1) {
        throw StateError('Sync event lease was lost before acknowledgement.');
      }
      return PremiumSyncResult(
        processed: true,
        succeeded: true,
        eventId: event.id,
      );
    } catch (error) {
      final attempts = event.attemptCount + 1;
      final delaySeconds = min(900, 1 << min(attempts, 9));
      await (database.update(database.syncOutboxEvents)
            ..where(
              (row) =>
                  row.id.equals(event.id) & row.leaseId.equals(claim.leaseId),
            ))
          .write(
        SyncOutboxEventsCompanion(
          leaseId: const Value(null),
          leaseExpiresAt: const Value(null),
          nextAttemptAt: Value(now.add(Duration(seconds: delaySeconds))),
          lastError: Value(error.toString()),
        ),
      );
      return PremiumSyncResult(
        processed: true,
        succeeded: false,
        eventId: event.id,
        error: error.toString(),
      );
    }
  }
}
