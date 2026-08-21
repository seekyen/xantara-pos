import 'dart:convert';

import 'package:dio/dio.dart';

import '../../local/database.dart';
import '../../local/local_pos_store.dart';
import '../../local/repositories/premium_sync_processor.dart';
import '../network/api_client.dart';
import 'premium_sync.dart';

class CloudSyncController {
  CloudSyncController({
    required this.database,
    required this.store,
    Dio? dio,
  }) : dio = dio ?? Dio(BaseOptions(baseUrl: 'https://xantarapos.com'));

  static const _sessionKey = 'xantara.cloud-sync-session.v1';
  static const _businessId = 'xantara';

  final AppDatabase database;
  final LocalPosStore store;
  final Dio dio;

  static const identities =
      <String, ({String installationId, String terminalId})>{
    'branch-main': (
      installationId: 'xantara-web-main',
      terminalId: 'branch-main-pos01',
    ),
    'branch-br002': (
      installationId: 'xantara-web-bgc',
      terminalId: 'branch-br002-pos01',
    ),
    'branch-br003': (
      installationId: 'xantara-web-makati',
      terminalId: 'branch-br003-pos01',
    ),
  };

  Future<bool> get isConfigured async =>
      (await store.read(_sessionKey))?.trim().isNotEmpty == true;

  Future<void> connect(
      {required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const CloudSyncException('Cloud email and password are required.');
    }
    try {
      final response = await dio.post<Object?>(
        '/api/v1/auth/login/',
        data: {'email': normalizedEmail, 'password': password},
      );
      final data = response.data;
      if (data is! Map) {
        throw const CloudSyncException('Invalid cloud login response.');
      }
      final access = data['access'];
      final refresh = data['refresh'];
      final role = data['user'] is Map ? (data['user'] as Map)['role'] : null;
      if (access is! String ||
          access.isEmpty ||
          refresh is! String ||
          refresh.isEmpty) {
        throw const CloudSyncException(
            'Cloud login did not return credentials.');
      }
      if (role != 'admin') {
        throw const CloudSyncException(
            'A cloud administrator account is required.');
      }
      await _writeSession(access: access, refresh: refresh);
    } on DioException catch (error) {
      throw CloudSyncException(
        error.response?.statusCode == 401
            ? 'Cloud email or password is incorrect.'
            : 'Unable to connect to Xantara Cloud.',
      );
    }
  }

  Future<int> syncNow() async {
    if (!await isConfigured) {
      throw const CloudSyncException('Connect a cloud administrator first.');
    }
    final transport = _BranchRoutingTransport(
      dio: dio,
      tokenProvider: _accessToken,
    );
    final processor =
        PremiumSyncProcessor(database: database, transport: transport);
    var uploaded = 0;
    for (var guard = 0; guard < 500; guard++) {
      final result = await processor.processNext(
        entitlement: const SyncEntitlement(
          businessId: _businessId,
          plan: AccountPlan.premium,
          syncEnabled: true,
        ),
        now: DateTime.now(),
      );
      if (!result.processed) return uploaded;
      if (!result.succeeded) {
        throw CloudSyncException(result.error ?? 'Cloud sync failed.');
      }
      uploaded++;
    }
    throw const CloudSyncException('Cloud sync stopped at its safety limit.');
  }

  Future<String?> _accessToken() async {
    final session = await _readSession();
    if (session == null) return null;
    if (!_expiresSoon(session.access)) return session.access;
    try {
      final response = await dio.post<Object?>(
        '/api/v1/auth/refresh/',
        data: {'refresh': session.refresh},
      );
      final data = response.data;
      if (data is! Map || data['access'] is! String) return null;
      final access = data['access'] as String;
      final refresh = data['refresh'] is String
          ? data['refresh'] as String
          : session.refresh;
      await _writeSession(access: access, refresh: refresh);
      return access;
    } on DioException {
      await store.remove(_sessionKey);
      return null;
    }
  }

  bool _expiresSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final expiry = payload is Map ? payload['exp'] : null;
      if (expiry is! int) return true;
      return DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc: true)
          .isBefore(DateTime.now().toUtc().add(const Duration(minutes: 1)));
    } catch (_) {
      return true;
    }
  }

  Future<_CloudSession?> _readSession() async {
    final raw = await store.read(_sessionKey);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value is! Map ||
          value['access'] is! String ||
          value['refresh'] is! String) {
        return null;
      }
      return _CloudSession(
          value['access'] as String, value['refresh'] as String);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSession(
          {required String access, required String refresh}) =>
      store.write(
          _sessionKey, jsonEncode({'access': access, 'refresh': refresh}));
}

class _CloudSession {
  const _CloudSession(this.access, this.refresh);
  final String access;
  final String refresh;
}

class _BranchRoutingTransport implements PremiumSyncTransport {
  const _BranchRoutingTransport(
      {required this.dio, required this.tokenProvider});
  final Dio dio;
  final AccessTokenProvider tokenProvider;

  @override
  Future<SyncAcknowledgement> upload(SyncEnvelope envelope) {
    final identity = CloudSyncController.identities[envelope.branchId];
    if (identity == null) {
      throw const CloudSyncException(
          'The event branch is not mapped to Xantara Cloud.');
    }
    return DioPremiumSyncTransport(
      dio: dio,
      accessTokenProvider: tokenProvider,
      installationId: identity.installationId,
      terminalId: identity.terminalId,
    ).upload(envelope);
  }
}

class CloudSyncException implements Exception {
  const CloudSyncException(this.message);
  final String message;
  @override
  String toString() => message;
}
