import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/sync/premium_sync.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/premium_sync_processor.dart';

void main() {
  late AppDatabase database;
  late _FakeSyncTransport transport;
  late PremiumSyncProcessor processor;
  final createdAt = DateTime(2026, 7, 11, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    transport = _FakeSyncTransport();
    processor = PremiumSyncProcessor(
      database: database,
      transport: transport,
    );
    await database.into(database.branches).insert(
          BranchesCompanion.insert(
            id: 'branch-main',
            code: '001',
            name: 'Main Branch',
            createdAt: createdAt,
          ),
        );
    await database.into(database.syncOutboxEvents).insert(
          SyncOutboxEventsCompanion.insert(
            id: 'event-1',
            branchId: 'branch-main',
            aggregateType: 'invoice',
            aggregateId: 'invoice-1',
            eventType: 'invoice.issued',
            idempotencyKey: 'invoice.issued:invoice-1',
            payloadJson: '{"invoiceId":"invoice-1"}',
            createdAt: createdAt,
          ),
        );
  });

  tearDown(() => database.close());

  test('standard account keeps events local and does not contact cloud',
      () async {
    final result = await processor.processNext(
      entitlement: const SyncEntitlement(
        businessId: 'business-1',
        plan: AccountPlan.standard,
        syncEnabled: false,
      ),
      now: createdAt,
    );

    expect(result.processed, isFalse);
    expect(transport.envelopes, isEmpty);
    final event = await database.select(database.syncOutboxEvents).getSingle();
    expect(event.attemptCount, 0);
    expect(event.syncedAt, isNull);
  });

  test('premium account uploads with idempotency and stores acknowledgement',
      () async {
    final result = await processor.processNext(
      entitlement: _premium(),
      now: createdAt,
    );

    expect(result.succeeded, isTrue);
    expect(transport.envelopes, hasLength(1));
    expect(transport.envelopes.single.businessId, 'business-1');
    expect(
      transport.envelopes.single.idempotencyKey,
      'invoice.issued:invoice-1',
    );
    final event = await database.select(database.syncOutboxEvents).getSingle();
    expect(event.syncedAt, createdAt.add(const Duration(seconds: 1)));
    expect(event.serverEventId, 'server-event-1');
    expect(event.attemptCount, 1);
    expect(event.leaseId, isNull);
  });

  test('failed upload backs off and later retries the same event', () async {
    transport.failuresRemaining = 1;

    final failed = await processor.processNext(
      entitlement: _premium(),
      now: createdAt,
    );
    final tooEarly = await processor.processNext(
      entitlement: _premium(),
      now: createdAt,
    );
    final retried = await processor.processNext(
      entitlement: _premium(),
      now: createdAt.add(const Duration(seconds: 3)),
    );

    expect(failed.succeeded, isFalse);
    expect(tooEarly.processed, isFalse);
    expect(retried.succeeded, isTrue);
    expect(transport.envelopes, hasLength(2));
    expect(
      transport.envelopes.map((event) => event.idempotencyKey).toSet(),
      {'invoice.issued:invoice-1'},
    );
    final event = await database.select(database.syncOutboxEvents).getSingle();
    expect(event.attemptCount, 2);
    expect(event.syncedAt, isNotNull);
  });

  test('active lease prevents duplicate workers until it expires', () async {
    await (database.update(database.syncOutboxEvents)).write(
      SyncOutboxEventsCompanion(
        leaseId: const Value('other-worker'),
        leaseExpiresAt: Value(createdAt.add(const Duration(minutes: 1))),
      ),
    );

    final leased = await processor.processNext(
      entitlement: _premium(),
      now: createdAt,
    );
    final recovered = await processor.processNext(
      entitlement: _premium(),
      now: createdAt.add(const Duration(minutes: 2)),
    );

    expect(leased.processed, isFalse);
    expect(recovered.succeeded, isTrue);
    expect(transport.envelopes, hasLength(1));
  });
}

SyncEntitlement _premium() => const SyncEntitlement(
      businessId: 'business-1',
      plan: AccountPlan.premium,
      syncEnabled: true,
    );

class _FakeSyncTransport implements PremiumSyncTransport {
  final envelopes = <SyncEnvelope>[];
  var failuresRemaining = 0;

  @override
  Future<SyncAcknowledgement> upload(SyncEnvelope envelope) async {
    envelopes.add(envelope);
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('Cloud unavailable.');
    }
    return SyncAcknowledgement(
      serverEventId: 'server-event-${envelopes.length}',
      acceptedAt: envelope.createdAt.add(const Duration(seconds: 1)),
    );
  }
}
