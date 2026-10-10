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
      'Local backend sessions are isolated and shared requests use the local API',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final store = MemoryPosStore();
    await store.write(
        'xantara.cloud-sync-session.v1',
        jsonEncode({
          'access': 'production-access',
          'refresh': 'production-refresh',
        }));
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8086'));
    final requests = <RequestOptions>[];
    final access = _token(DateTime.now().add(const Duration(hours: 1)));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response<Object?>(
        requestOptions: options,
        statusCode: 200,
        data: options.path == '/api/v1/auth/login/'
            ? {
                'access': access,
                'refresh': 'local-refresh',
                'user': {'role': 'admin'}
              }
            : <Object?>[],
      ));
    }));
    final controller =
        CloudSyncController(database: database, store: store, dio: dio);
    expect(await controller.isConfigured, isFalse);
    await controller.connect(
        email: 'local@example.com', password: 'local-password');
    await controller.inventoryRequest('?branch=MAIN');
    await controller.staffRequest('');
    await controller.branchesRequest('');
    await controller.settingsRequest();
    expect(await controller.isConfigured, isTrue);
    for (final request in requests.skip(1)) {
      expect(request.uri.origin, 'http://127.0.0.1:8086');
      expect(request.headers['Authorization'], 'Bearer $access');
    }
    expect(store.decode('xantara.cloud-sync-session.v1')['access'],
        'production-access');
  });

  test('migrates the former port 8000 local session to port 8086', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final store = MemoryPosStore();
    final access = _token(DateTime.now().add(const Duration(hours: 1)));
    await store.write('xantara.cloud-sync-session.v1:http://127.0.0.1:8000',
        jsonEncode({'access': access, 'refresh': 'local-refresh'}));
    final controller = CloudSyncController(
      database: database,
      store: store,
      dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8086')),
    );

    expect(await controller.isConfigured, isTrue);
    expect(store.decode('xantara.cloud-sync-session.v1:http://127.0.0.1:8086'),
        {'access': access, 'refresh': 'local-refresh'});
    expect(
        await store.read('xantara.cloud-sync-session.v1:http://127.0.0.1:8000'),
        isNull);
  });

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
      if (options.path == '/api/v1/setup/status/') {
        handler.resolve(Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'setup_required': false,
            'setup_completed': true,
            'business_id': 'north-star-1234abcd',
          },
        ));
        return;
      }
      if (options.uri.path == '/api/v1/inventory-items/') {
        handler.resolve(Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: <Object?>[],
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

    final result = await controller.syncNow();
    expect(result.uploadedEvents, 1);
    expect(result.downloadedProducts, 0);
    expect(store.decode('xantara.cloud-sync-session.v1'), {
      'access': isA<String>(),
      'refresh': 'refresh-token',
      'businessId': 'north-star-1234abcd',
    });
    expect(store.decode('xantara.cloud-sync-session.v1').toString(),
        isNot(contains('secret')));
    final upload = requests
        .firstWhere((request) => request.uri.path == '/api/v1/sync/events/');
    expect(upload.headers['X-Xantara-Installation-Id'], 'xantara-web-main');
    expect(upload.headers['X-Xantara-Terminal-Id'], 'branch-main-pos01');
    expect((upload.data as Map<String, dynamic>)['businessId'],
        'north-star-1234abcd');
  });

  test('sync downloads the MySQL MAIN catalog after uploads finish', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await seedDatabaseIfEmpty(database);
    final store = MemoryPosStore();
    final access = _token(DateTime.now().add(const Duration(hours: 1)));
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8086'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      if (options.path == '/api/v1/auth/login/') {
        handler.resolve(Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access': access,
            'refresh': 'refresh-token',
            'user': {'role': 'admin'},
          },
        ));
        return;
      }
      handler.resolve(Response<Object?>(
        requestOptions: options,
        statusCode: 200,
        data: [
          {
            'id': 7,
            'branch': 'MAIN',
            'tier': 'basic',
            'revision': 3,
            'data': {
              'sku': '4800014141081',
              'name': 'Summit 500 ML',
              'selling_price': '25.00',
              'tax_category': 'vat12',
              'category': 'beverages',
              'quantity': 12.0,
              'reorder_level': 4.0,
            },
            'stock': {'physical': 12.0},
          }
        ],
      ));
    }));
    final controller =
        CloudSyncController(database: database, store: store, dio: dio);
    await controller.connect(email: 'admin@example.com', password: 'secret');

    final result = await controller.syncNow();

    expect(result.uploadedEvents, 0);
    expect(result.downloadedProducts, 1);
    final product = await (database.select(database.products)
          ..where((row) => row.sku.equals('4800014141081')))
        .getSingle();
    expect(product.name, 'Summit 500 ML');
    expect(product.unitPriceCentavos, 2500);
    final stock = await (database.select(database.branchInventories)
          ..where((row) => row.branchId.equals('branch-main'))
          ..where((row) => row.productId.equals(product.id)))
        .getSingle();
    expect(stock.stockOnHand, 12);
    final sample = await (database.select(database.products)
          ..where((row) => row.sku.equals('SAMPLE-001')))
        .getSingle();
    expect(sample.isActive, isFalse);
    // The catalog is downloaded first; customers and promos are refreshed right after it. The
    // stub above answers that request with a product list, which is ignored (not a loyalty
    // download), so the sync still succeeds.
    expect(requests[requests.length - 2].uri.toString(),
        'http://127.0.0.1:8086/api/v1/inventory-items/?branch=MAIN');
    expect(requests.last.uri.path, '/api/v1/loyalty/pos-sync/');
    expect(result.downloadedCustomers, 0);
  });
}

String _token(DateTime expiry) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({
        'exp': expiry.millisecondsSinceEpoch ~/ 1000
      })}.';
}
