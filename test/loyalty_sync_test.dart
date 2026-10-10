import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/sync/cloud_sync_controller.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_seed.dart';
import 'package:pos_app/local/local_pos_store.dart';

void main() {
  Future<({CloudSyncController controller, AppDatabase database})> connected(
    void Function(RequestOptions, RequestInterceptorHandler) loyaltyRoute,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await seedDatabaseIfEmpty(database);
    final dio = Dio(BaseOptions(baseUrl: 'https://xantarapos.com'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      Object? data;
      switch (options.uri.path) {
        case '/api/v1/auth/login/':
          data = {
            'access': _token(DateTime.now().add(const Duration(hours: 1))),
            'refresh': 'refresh-token',
            'user': {'role': 'admin'},
          };
        case '/api/v1/setup/status/':
          data = {
            'setup_required': false,
            'setup_completed': true,
            'business_id': 'north-star-1234abcd',
          };
        case '/api/v1/inventory-items/':
          data = <Object?>[];
        case '/api/v1/loyalty/pos-sync/':
          return loyaltyRoute(options, handler);
        default:
          data = <String, Object?>{};
      }
      handler.resolve(
          Response<Object?>(requestOptions: options, statusCode: 200, data: data));
    }));
    final controller = CloudSyncController(
        database: database, store: MemoryPosStore(), dio: dio);
    await controller.connect(email: 'owner@example.com', password: 'secret');
    return (controller: controller, database: database);
  }

  test('sync downloads the customers and promos after the catalog', () async {
    final (:controller, :database) = await connected((options, handler) {
      handler.resolve(Response<Object?>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'customers': [
            {'id': 7, 'name': 'Maria Santos', 'phone': '0917', 'email': null, 'loyalty_points': 12},
          ],
          'promos': [
            {'id': 1, 'name': 'July Points', 'start_date': '2026-07-01', 'end_date': '2026-07-31', 'spend_per_point': '20.00', 'is_active': true, 'status': 'running'},
          ],
        },
      ));
    });

    final result = await controller.syncNow();
    expect(result.downloadedCustomers, 1);
    final customer = await database.select(database.loyaltyCustomers).getSingle();
    expect((customer.id, customer.name, customer.points), ('7', 'Maria Santos', 12));
    final promo = await database.select(database.loyaltyPromos).getSingle();
    expect((promo.name, promo.spendPerPointCentavos), ('July Points', 2000));
  });

  test('the sales sync still succeeds and keeps the old cache when customers cannot be downloaded', () async {
    final (:controller, :database) = await connected((options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<Object?>(requestOptions: options, statusCode: 404),
      ));
    });
    await database.into(database.loyaltyCustomers).insert(
        LoyaltyCustomersCompanion.insert(
            id: '1', name: 'Kept', syncedAt: DateTime(2026, 7, 1)));

    final result = await controller.syncNow();
    expect(result.downloadedCustomers, 0);
    expect((await database.select(database.loyaltyCustomers).getSingle()).name, 'Kept');
  });
}

String _token(DateTime expiry) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({
        'exp': expiry.millisecondsSinceEpoch ~/ 1000
      })}.';
}
