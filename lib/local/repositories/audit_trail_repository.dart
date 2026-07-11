import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class AuditVerificationResult {
  const AuditVerificationResult({
    required this.isValid,
    required this.eventsChecked,
    this.brokenSequence,
    this.reason,
  });

  final bool isValid;
  final int eventsChecked;
  final int? brokenSequence;
  final String? reason;
}

class AuditTrailRepository {
  AuditTrailRepository(this.database, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  static const genesisHash =
      '0000000000000000000000000000000000000000000000000000000000000000';

  final AppDatabase database;
  final Uuid _uuid;

  /// Call inside the same database transaction as the business operation.
  Future<String> append({
    required String branchId,
    required String actorId,
    required String eventType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required DateTime occurredAt,
    String? terminalId,
  }) async {
    if (branchId.trim().isEmpty ||
        actorId.trim().isEmpty ||
        eventType.trim().isEmpty ||
        entityType.trim().isEmpty ||
        entityId.trim().isEmpty) {
      throw ArgumentError('Audit identity fields cannot be empty.');
    }
    // Reject invalid JSON so equivalent readers can safely preserve the payload.
    jsonDecode(payloadJson);

    final previous = await (database.select(database.auditEvents)
          ..where((row) => row.branchId.equals(branchId))
          ..orderBy([(row) => OrderingTerm.desc(row.sequence)])
          ..limit(1))
        .getSingleOrNull();
    final sequence = (previous?.sequence ?? 0) + 1;
    final previousHash = previous?.eventHash ?? genesisHash;
    final normalizedTime = occurredAt.toUtc().toIso8601String();
    final hash = _hash(
      branchId: branchId,
      sequence: sequence,
      previousHash: previousHash,
      terminalId: terminalId,
      actorId: actorId.trim(),
      eventType: eventType,
      entityType: entityType,
      entityId: entityId,
      payloadJson: payloadJson,
      normalizedTime: normalizedTime,
    );
    final id = _uuid.v4();
    await database.into(database.auditEvents).insert(
          AuditEventsCompanion.insert(
            id: id,
            branchId: branchId,
            sequence: sequence,
            previousHash: previousHash,
            eventHash: hash,
            terminalId: Value(terminalId),
            actorId: actorId.trim(),
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            payloadJson: payloadJson,
            occurredAt: occurredAt,
          ),
        );
    return id;
  }

  Future<AuditVerificationResult> verifyBranch(String branchId) async {
    final events = await (database.select(database.auditEvents)
          ..where((row) => row.branchId.equals(branchId))
          ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
        .get();
    var expectedSequence = 1;
    var expectedPreviousHash = genesisHash;
    for (final event in events) {
      if (event.sequence != expectedSequence) {
        return AuditVerificationResult(
          isValid: false,
          eventsChecked: expectedSequence - 1,
          brokenSequence: expectedSequence,
          reason: 'Audit sequence is missing or out of order.',
        );
      }
      if (event.previousHash != expectedPreviousHash) {
        return AuditVerificationResult(
          isValid: false,
          eventsChecked: expectedSequence - 1,
          brokenSequence: event.sequence,
          reason: 'Previous audit hash does not match.',
        );
      }
      final calculated = _hash(
        branchId: event.branchId,
        sequence: event.sequence,
        previousHash: event.previousHash,
        terminalId: event.terminalId,
        actorId: event.actorId,
        eventType: event.eventType,
        entityType: event.entityType,
        entityId: event.entityId,
        payloadJson: event.payloadJson,
        normalizedTime: event.occurredAt.toUtc().toIso8601String(),
      );
      if (calculated != event.eventHash) {
        return AuditVerificationResult(
          isValid: false,
          eventsChecked: expectedSequence - 1,
          brokenSequence: event.sequence,
          reason: 'Audit event content hash does not match.',
        );
      }
      expectedPreviousHash = event.eventHash;
      expectedSequence++;
    }
    return AuditVerificationResult(
      isValid: true,
      eventsChecked: events.length,
    );
  }

  String _hash({
    required String branchId,
    required int sequence,
    required String previousHash,
    required String? terminalId,
    required String actorId,
    required String eventType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required String normalizedTime,
  }) {
    final canonical = [
      branchId,
      sequence.toString(),
      previousHash,
      terminalId ?? '',
      actorId,
      eventType,
      entityType,
      entityId,
      normalizedTime,
      payloadJson,
    ].map((value) => '${utf8.encode(value).length}:$value').join('|');
    return sha256.convert(utf8.encode(canonical)).toString();
  }
}
