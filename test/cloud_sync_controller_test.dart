import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/sync/cloud_sync_controller.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_seed.dart';
import 'package:pos_app/local/local_pos_store.dart';

void main() {
  test(
      'stores tokens without storing the cloud password and routes main branch',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await seedDatabaseIfEmpty(database);
    final store = MemoryPosStore();
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://xantarapos.com'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      if (options.path == '/api/v1/auth/login/') {
        handler.resolve(Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access': _token(DateTime.now().add(const Duration(hours: 1))),
            'refresh': 'refresh-token',
            'user': {'role': 'admin'},
          },
        ));
        return;
      }
      handler.resolve(Response<Object?>(
        requestOptions: options,
        statusCode: 202,
        data: {
          'serverEventId': 'server-1',
          'acceptedAt': '2026-08-21T12:00:01Z',
        },
      ));
    }));
    final controller = CloudSyncController(
      database: database,
      store: store,
      dio: dio,
    );

    await controller.connect(email: ' RIX@example.com ', password: 'secret');
    await database.into(database.syncOutboxEvents).insert(
          SyncOutboxEventsCompanion.insert(
            id: 'event-1',
            branchId: 'branch-main',
            aggregateType: 'inventory',
            aggregateId: 'SAMPLE-001',
            eventType: 'inventory.low_stock',
            idempotencyKey: 'inventory.low_stock:event-1',
            payloadJson: '{"productId":"SAMPLE-001"}',
            createdAt: DateTime.utc(2026, 8, 21, 12),
          ),
        );

    expect(await controller.syncNow(), 1);
    expect(store.decode('xantara.cloud-sync-session.v1'), {
      'access': isA<String>(),
      'refresh': 'refresh-token',
    });
    expect(store.decode('xantara.cloud-sync-session.v1').toString(),
        isNot(contains('secret')));
    final upload = requests.last;
    expect(upload.headers['X-Xantara-Installation-Id'], 'xantara-web-main');
    expect(upload.headers['X-Xantara-Terminal-Id'], 'branch-main-pos01');
  });
}

String _token(DateTime expiry) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({
        'exp': expiry.millisecondsSinceEpoch ~/ 1000
      })}.';
}
