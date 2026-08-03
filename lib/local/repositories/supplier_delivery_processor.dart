import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/suppliers/supplier_integration.dart';
import '../database.dart';

class SupplierDeliveryProcessor {
  SupplierDeliveryProcessor({
    required this.database,
    required Iterable<SupplierConnectorAdapter> adapters,
    this.leaseDuration = const Duration(minutes: 2),
    Uuid uuid = const Uuid(),
  })  : _adapters = {
          for (final adapter in adapters) adapter.connectorType: adapter,
        },
        _uuid = uuid;

  final AppDatabase database;
  final Map<String, SupplierConnectorAdapter> _adapters;
  final Duration leaseDuration;
  final Uuid _uuid;

  Future<SupplierDeliveryResult> processNext(DateTime now) async {
    if (leaseDuration <= Duration.zero) {
      throw StateError('Supplier delivery lease duration must be positive.');
    }
    final claim = await database.transaction(() async {
      final candidates = await (database.select(database.supplierDeliveryJobs)
            ..where(
              (row) => row.status.isIn([
                SupplierDeliveryStatus.queued.name,
                SupplierDeliveryStatus.failed.name,
              ]),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();
      for (final candidate in candidates) {
        if ((candidate.nextAttemptAt != null &&
                candidate.nextAttemptAt!.isAfter(now)) ||
            (candidate.leaseId != null &&
                candidate.leaseExpiresAt != null &&
                candidate.leaseExpiresAt!.isAfter(now))) {
          continue;
        }
        final connector = await (database.select(database.supplierConnectors)
              ..where((row) => row.id.equals(candidate.connectorId)))
            .getSingleOrNull();
        if (connector == null || !connector.isEnabled) continue;

        final leaseId = _uuid.v4();
        await (database.update(database.supplierDeliveryJobs)
              ..where((row) => row.id.equals(candidate.id)))
            .write(
          SupplierDeliveryJobsCompanion(
            status: Value(SupplierDeliveryStatus.processing.name),
            attemptCount: Value(candidate.attemptCount + 1),
            leaseId: Value(leaseId),
            leaseExpiresAt: Value(now.add(leaseDuration)),
            lastError: const Value(null),
          ),
        );
        return (job: candidate, connector: connector, leaseId: leaseId);
      }
      return null;
    });
    if (claim == null) {
      return const SupplierDeliveryResult(
        processed: false,
        succeeded: false,
      );
    }

    final job = claim.job;
    try {
      final adapter = _adapters[claim.connector.connectorType];
      if (adapter == null) {
        throw StateError(
          'No adapter is installed for ${claim.connector.connectorType}.',
        );
      }
      final decoded = jsonDecode(job.payloadJson) as Map<String, dynamic>;
      final acknowledgement = await adapter.deliver(
        SupplierAlertEnvelope(
          deliveryId: job.id,
          connectorId: job.connectorId,
          idempotencyKey: job.idempotencyKey,
          occurredAt: job.createdAt,
          authorizedData: Map<String, Object?>.unmodifiable(decoded),
        ),
      );
      if (acknowledgement.externalReference.trim().isEmpty) {
        throw StateError('Supplier returned an empty acknowledgement.');
      }
      await (database.update(database.supplierDeliveryJobs)
            ..where(
              (row) =>
                  row.id.equals(job.id) & row.leaseId.equals(claim.leaseId),
            ))
          .write(
        SupplierDeliveryJobsCompanion(
          status: Value(SupplierDeliveryStatus.completed.name),
          leaseId: const Value(null),
          leaseExpiresAt: const Value(null),
          nextAttemptAt: const Value(null),
          completedAt: Value(acknowledgement.acceptedAt),
          externalReference: Value(acknowledgement.externalReference),
          lastError: const Value(null),
        ),
      );
      return SupplierDeliveryResult(
        processed: true,
        succeeded: true,
        deliveryId: job.id,
      );
    } catch (error) {
      final attempts = job.attemptCount + 1;
      final delaySeconds = min(900, 1 << min(attempts, 9));
      await (database.update(database.supplierDeliveryJobs)
            ..where(
              (row) =>
                  row.id.equals(job.id) & row.leaseId.equals(claim.leaseId),
            ))
          .write(
        SupplierDeliveryJobsCompanion(
          status: Value(SupplierDeliveryStatus.failed.name),
          leaseId: const Value(null),
          leaseExpiresAt: const Value(null),
          nextAttemptAt: Value(now.add(Duration(seconds: delaySeconds))),
          lastError: Value(error.toString()),
        ),
      );
      return SupplierDeliveryResult(
        processed: true,
        succeeded: false,
        deliveryId: job.id,
        error: error.toString(),
      );
    }
  }
}
