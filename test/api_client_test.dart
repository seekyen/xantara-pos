import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/sync/premium_sync.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 21, 10, 30);

  test('uploads a versioned event with auth and device identities', () async {
    late RequestOptions request;
    final dio = Dio(BaseOptions(baseUrl: 'https://xantarapos.com'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          request = options;
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 202,
              data: <String, Object?>{
                'serverEventId': 'server-event-1',
                'acceptedAt': '2026-08-21T10:30:01Z',
              },
            ),
          );
        },
      ),
    );
    final transport = DioPremiumSyncTransport(
      dio: dio,
      accessTokenProvider: () async => 'access-token',
      installationId: 'installation-1',
      terminalId: 'terminal-1',
    );

    final acknowledgement = await transport.upload(_envelope(createdAt));

    expect(request.path, '/api/v1/sync/events/');
    expect(request.headers['Authorization'], 'Bearer access-token');
    expect(request.headers['Idempotency-Key'], 'inventory.adjusted:event-1');
    expect(request.headers['X-Xantara-Installation-Id'], 'installation-1');
    expect(request.headers['X-Xantara-Terminal-Id'], 'terminal-1');
    expect(
      request.data,
      <String, Object?>{
        'schemaVersion': 1,
        'localEventId': 'event-1',
        'businessId': 'business-1',
        'branchId': 'branch-1',
        'aggregateType': 'inventory',
        'aggregateId': 'product-1',
        'eventType': 'inventory.adjusted',
        'idempotencyKey': 'inventory.adjusted:event-1',
        'payload': <String, Object?>{
          'productId': 'product-1',
          'quantityDelta': -2,
        },
        'createdAt': '2026-08-21T10:30:00.000Z',
      },
    );
    expect(acknowledgement.serverEventId, 'server-event-1');
    expect(acknowledgement.acceptedAt, DateTime.utc(2026, 8, 21, 10, 30, 1));
  });

  test('does not contact the server without an access token', () async {
    var contacted = false;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          contacted = true;
          handler.next(options);
        },
      ),
    );
    final transport = DioPremiumSyncTransport(
      dio: dio,
      accessTokenProvider: () async => null,
      installationId: 'installation-1',
      terminalId: 'terminal-1',
    );

    await expectLater(
      transport.upload(_envelope(createdAt)),
      throwsA(
        isA<SyncTransportException>().having(
          (error) => error.message,
          'message',
          'Cloud authentication is required.',
        ),
      ),
    );
    expect(contacted, isFalse);
  });

  test('rejects malformed acknowledgements', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<Object?>(
            requestOptions: options,
            statusCode: 200,
            data: <String, Object?>{'serverEventId': 'server-event-1'},
          ),
        ),
      ),
    );
    final transport = DioPremiumSyncTransport(
      dio: dio,
      accessTokenProvider: () async => 'access-token',
      installationId: 'installation-1',
      terminalId: 'terminal-1',
    );

    await expectLater(
      transport.upload(_envelope(createdAt)),
      throwsA(
        isA<SyncTransportException>().having(
          (error) => error.message,
          'message',
          'Cloud acknowledgement is missing its acceptance time.',
        ),
      ),
    );
  });

  test('reports HTTP failures without leaking response content', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            response: Response<Object?>(
              requestOptions: options,
              statusCode: 403,
              data: <String, Object?>{'detail': 'sensitive server detail'},
            ),
          ),
        ),
      ),
    );
    final transport = DioPremiumSyncTransport(
      dio: dio,
      accessTokenProvider: () async => 'access-token',
      installationId: 'installation-1',
      terminalId: 'terminal-1',
    );

    await expectLater(
      transport.upload(_envelope(createdAt)),
      throwsA(
        isA<SyncTransportException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having(
              (error) => error.toString(),
              'message',
              isNot(contains('sensitive server detail')),
            ),
      ),
    );
  });
}

SyncEnvelope _envelope(DateTime createdAt) => SyncEnvelope(
      localEventId: 'event-1',
      businessId: 'business-1',
      branchId: 'branch-1',
      aggregateType: 'inventory',
      aggregateId: 'product-1',
      eventType: 'inventory.adjusted',
      idempotencyKey: 'inventory.adjusted:event-1',
      payloadJson: '{"productId":"product-1","quantityDelta":-2}',
      createdAt: createdAt,
    );
