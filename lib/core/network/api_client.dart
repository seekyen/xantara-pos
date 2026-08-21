import 'dart:convert';

import 'package:dio/dio.dart';

import '../sync/premium_sync.dart';

typedef AccessTokenProvider = Future<String?> Function();

/// Uploads durable local outbox events to the Xantara cloud API.
///
/// Authentication credentials are provided at request time so they can be
/// rotated or revoked without rebuilding the application. They must never be
/// embedded with `--dart-define` in a web build.
class DioPremiumSyncTransport implements PremiumSyncTransport {
  DioPremiumSyncTransport({
    required this.dio,
    required this.accessTokenProvider,
    required this.installationId,
    required this.terminalId,
    this.endpoint = '/api/v1/sync/events/',
  });

  final Dio dio;
  final AccessTokenProvider accessTokenProvider;
  final String installationId;
  final String terminalId;
  final String endpoint;

  @override
  Future<SyncAcknowledgement> upload(SyncEnvelope envelope) async {
    final token = (await accessTokenProvider())?.trim();
    if (token == null || token.isEmpty) {
      throw const SyncTransportException('Cloud authentication is required.');
    }
    if (installationId.trim().isEmpty || terminalId.trim().isEmpty) {
      throw const SyncTransportException(
        'Installation and terminal identities are required.',
      );
    }

    final Object? payload;
    try {
      payload = jsonDecode(envelope.payloadJson);
    } on FormatException {
      throw const SyncTransportException(
        'The queued event contains invalid JSON.',
      );
    }

    try {
      final response = await dio.post<Object?>(
        endpoint,
        data: <String, Object?>{
          'schemaVersion': 1,
          'localEventId': envelope.localEventId,
          'businessId': envelope.businessId,
          'branchId': envelope.branchId,
          'aggregateType': envelope.aggregateType,
          'aggregateId': envelope.aggregateId,
          'eventType': envelope.eventType,
          'idempotencyKey': envelope.idempotencyKey,
          'payload': payload,
          'createdAt': envelope.createdAt.toUtc().toIso8601String(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: <String, Object>{
            'Authorization': 'Bearer $token',
            'Idempotency-Key': envelope.idempotencyKey,
            'X-Xantara-Installation-Id': installationId.trim(),
            'X-Xantara-Terminal-Id': terminalId.trim(),
          },
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      final data = response.data;
      if (data is! Map) {
        throw const SyncTransportException(
          'Cloud acknowledgement has an invalid shape.',
        );
      }
      final acknowledgement = Map<String, Object?>.from(data);
      final serverEventId = acknowledgement['serverEventId'];
      final acceptedAtValue = acknowledgement['acceptedAt'];
      if (serverEventId is! String || serverEventId.trim().isEmpty) {
        throw const SyncTransportException(
          'Cloud acknowledgement is missing its event ID.',
        );
      }
      if (acceptedAtValue is! String) {
        throw const SyncTransportException(
          'Cloud acknowledgement is missing its acceptance time.',
        );
      }
      final acceptedAt = DateTime.tryParse(acceptedAtValue);
      if (acceptedAt == null) {
        throw const SyncTransportException(
          'Cloud acknowledgement has an invalid acceptance time.',
        );
      }

      return SyncAcknowledgement(
        serverEventId: serverEventId,
        acceptedAt: acceptedAt.toUtc(),
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw SyncTransportException(
        status == null
            ? 'Cloud sync could not reach the server.'
            : 'Cloud sync was rejected with HTTP $status.',
        statusCode: status,
      );
    }
  }
}

class SyncTransportException implements Exception {
  const SyncTransportException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'SyncTransportException: $message';
}
