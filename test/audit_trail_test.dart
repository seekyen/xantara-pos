import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/audit_trail_repository.dart';

void main() {
  late AppDatabase database;
  late AuditTrailRepository audit;
  final now = DateTime(2026, 7, 11, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    audit = AuditTrailRepository(database);
    for (final branch in [('branch-1', '001'), ('branch-2', '002')]) {
      await database.into(database.branches).insert(
            BranchesCompanion.insert(
              id: branch.$1,
              code: branch.$2,
              name: 'Branch ${branch.$2}',
              createdAt: now,
            ),
          );
    }
  });

  tearDown(() => database.close());

  test('builds and verifies a contiguous per-branch hash chain', () async {
    await _append(audit, branchId: 'branch-1', entityId: 'invoice-1', at: now);
    await _append(
      audit,
      branchId: 'branch-1',
      entityId: 'invoice-2',
      at: now.add(const Duration(minutes: 1)),
    );

    final events = await (database.select(database.auditEvents)
          ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
        .get();
    final result = await audit.verifyBranch('branch-1');

    expect(events.map((event) => event.sequence), [1, 2]);
    expect(events.first.previousHash, AuditTrailRepository.genesisHash);
    expect(events.last.previousHash, events.first.eventHash);
    expect(events.every((event) => event.eventHash.length == 64), isTrue);
    expect(result.isValid, isTrue);
    expect(result.eventsChecked, 2);
  });

  test('detects content tampering', () async {
    await _append(audit, branchId: 'branch-1', entityId: 'invoice-1', at: now);
    await (database.update(database.auditEvents)).write(
      const AuditEventsCompanion(payloadJson: Value('{"total":1}')),
    );

    final result = await audit.verifyBranch('branch-1');

    expect(result.isValid, isFalse);
    expect(result.brokenSequence, 1);
    expect(result.reason, contains('content hash'));
  });

  test('detects a deleted event in the middle of the chain', () async {
    await _append(audit, branchId: 'branch-1', entityId: 'invoice-1', at: now);
    await _append(
      audit,
      branchId: 'branch-1',
      entityId: 'invoice-2',
      at: now.add(const Duration(minutes: 1)),
    );
    await (database.delete(database.auditEvents)
          ..where((row) => row.sequence.equals(1)))
        .go();

    final result = await audit.verifyBranch('branch-1');

    expect(result.isValid, isFalse);
    expect(result.brokenSequence, 1);
    expect(result.reason, contains('missing'));
  });

  test('keeps independent sequence and genesis hash for each branch', () async {
    await _append(audit, branchId: 'branch-1', entityId: 'invoice-1', at: now);
    await _append(audit, branchId: 'branch-2', entityId: 'invoice-2', at: now);

    final events = await database.select(database.auditEvents).get();

    expect(events, hasLength(2));
    expect(events.every((event) => event.sequence == 1), isTrue);
    expect(
      events.every(
        (event) => event.previousHash == AuditTrailRepository.genesisHash,
      ),
      isTrue,
    );
    expect((await audit.verifyBranch('branch-1')).isValid, isTrue);
    expect((await audit.verifyBranch('branch-2')).isValid, isTrue);
  });
}

Future<String> _append(
  AuditTrailRepository audit, {
  required String branchId,
  required String entityId,
  required DateTime at,
}) {
  return audit.append(
    branchId: branchId,
    actorId: 'cashier-1',
    eventType: 'invoice.issued',
    entityType: 'invoice',
    entityId: entityId,
    payloadJson: '{"total":10000}',
    occurredAt: at,
  );
}
