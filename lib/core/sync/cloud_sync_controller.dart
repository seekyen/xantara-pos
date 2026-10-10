import 'dart:convert';

import 'package:dio/dio.dart';

import '../../local/database.dart';
import '../../local/local_pos_store.dart';
import '../../local/repositories/premium_sync_processor.dart';
import '../../local/repositories/cloud_catalog_repository.dart';
import '../../local/repositories/loyalty_repository.dart';
import '../../local/repositories/company_registration_repository.dart';
import '../network/api_client.dart';
import 'premium_sync.dart';

class CloudSyncController {
  CloudSyncController({
    required this.database,
    required this.store,
    Dio? dio,
    String? baseUrl,
  }) : dio = dio ??
            Dio(BaseOptions(
                baseUrl: baseUrl ??
                    const String.fromEnvironment('API_BASE_URL',
                        defaultValue: 'https://xantarapos.com')));

  /// Tiered inventory uses the same authenticated API as the admin frontend.
  Future<dynamic> inventoryRequest(String path,
      {String method = 'GET', Map<String, dynamic>? data}) async {
    final company = await CompanyRegistrationRepository(database).read();
    if (company != null && company.serverTerminalId.isNotEmpty) {
      final uri = Uri.parse(path);
      path = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'branch': company.cloudBranchCode,
      }).toString();
      if (data != null) data = {...data, 'branch': company.cloudBranchCode};
    }
    return _authorizedRequest(
      '/api/v1/inventory-items/$path',
      method: method,
      data: data,
      errorPrefix: 'Inventory could not be saved or loaded',
      offlineMessage: 'The shared inventory server is unavailable.',
    );
  }

  /// Store-wide configuration (name, receipt text, currency, VAT, payment
  /// methods, ...) shared with the admin frontend's Settings page — one
  /// singleton record at `/api/v1/settings/`, so both apps read/write the
  /// same values instead of keeping separate local copies.
  Future<dynamic> settingsRequest(
          {String method = 'GET', Map<String, dynamic>? data}) =>
      _authorizedRequest(
        '/api/v1/settings/',
        method: method,
        data: data,
        errorPrefix: 'Store settings could not be saved or loaded',
        offlineMessage: 'The shared settings server is unavailable.',
      );

  /// The same staff directory the admin frontend's Staff page manages
  /// (name, role/access level, branch assignment, status) — read-only here.
  /// This is deliberately separate from this device's own cashier login,
  /// which stays local-first via [StaffUsers]/[StaffBranchAccess]; this only
  /// lets a connected cloud administrator look up who's assigned where.
  Future<dynamic> staffRequest(String path,
          {String method = 'GET', Map<String, dynamic>? data}) =>
      _authorizedRequest(
        '/api/v1/staff/$path',
        method: method,
        data: data,
        errorPrefix: 'Staff directory could not be loaded',
        offlineMessage: 'The shared staff directory is unavailable.',
      );

  /// Branch records (name, address, contact) staff are assigned to.
  Future<dynamic> branchesRequest(String path,
          {String method = 'GET', Map<String, dynamic>? data}) =>
      _authorizedRequest(
        '/api/v1/branches/$path',
        method: method,
        data: data,
        errorPrefix: 'Branch list could not be loaded',
        offlineMessage: 'The shared branch list is unavailable.',
      );

  Future<dynamic> _authorizedRequest(
    String path, {
    required String method,
    required String errorPrefix,
    required String offlineMessage,
    Map<String, dynamic>? data,
  }) async {
    if (!await isConfigured) {
      throw const CloudSyncException(
          'Connect a cloud administrator in Settings first.');
    }
    final token = await _accessToken();
    try {
      final result = await dio.request<dynamic>(path,
          data: data,
          options: Options(
              method: method, headers: {'Authorization': 'Bearer $token'}));
      return result.data;
    } on DioException catch (error) {
      throw CloudSyncException(error.response?.data != null
          ? '$errorPrefix: ${error.response!.data}'
          : offlineMessage);
    }
  }

  // Local previews must not reuse credentials from the production backend.
  String get _sessionKey {
    const legacyKey = 'xantara.cloud-sync-session.v1';
    final origin = Uri.parse(dio.options.baseUrl).origin;
    return origin == 'https://xantarapos.com'
        ? legacyKey
        : '$legacyKey:$origin';
  }

  Iterable<String> get _sessionKeys sync* {
    yield _sessionKey;
    if (Uri.parse(dio.options.baseUrl).origin == 'http://127.0.0.1:8086') {
      yield 'xantara.cloud-sync-session.v1:http://127.0.0.1:8000';
    }
  }

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

  Future<bool> get isConfigured async => await _readSession() != null;

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
      final businessId = await _loadBusinessId(access);
      final company = await CompanyRegistrationRepository(database).read();
      if (company != null &&
          (company.cloudBusinessId.isEmpty ||
              company.cloudBusinessId != businessId)) {
        throw const CloudSyncException(
            'This cloud account does not match the business ID saved during company setup.');
      }
      await _writeSession(
          access: access, refresh: refresh, businessId: businessId);
    } on DioException catch (error) {
      throw CloudSyncException(
        error.response?.statusCode == 401
            ? 'Cloud email or password is incorrect.'
            : 'Unable to connect to Xantara Cloud.',
      );
    }
  }

  Future<CloudSyncResult> syncNow() async {
    final session = await _readSession();
    if (session == null) {
      throw const CloudSyncException('Connect a cloud administrator first.');
    }
    final company = await CompanyRegistrationRepository(database).read();
    final transport = _BranchRoutingTransport(
      dio: dio,
      tokenProvider: _accessToken,
      company: company,
    );
    final processor =
        PremiumSyncProcessor(database: database, transport: transport);
    var uploaded = 0;
    for (var guard = 0; guard < 500; guard++) {
      final result = await processor.processNext(
        entitlement: SyncEntitlement(
          businessId: session.businessId,
          plan: AccountPlan.premium,
          syncEnabled: true,
        ),
        now: DateTime.now(),
      );
      if (!result.processed) {
        final response = await _authorizedRequest(
          '/api/v1/inventory-items/?branch=${Uri.encodeQueryComponent(company?.cloudBranchCode ?? 'MAIN')}',
          method: 'GET',
          errorPrefix: 'Catalog could not be synchronized',
          offlineMessage: 'The shared catalog server is unavailable.',
        );
        final downloaded =
            await CloudCatalogRepository(database).replaceMainCatalog(response);
        return CloudSyncResult(
          uploadedEvents: uploaded,
          downloadedProducts: downloaded,
          downloadedCustomers: await _downloadLoyalty(),
        );
      }
      if (!result.succeeded) {
        throw CloudSyncException(result.error ?? 'Cloud sync failed.');
      }
      uploaded++;
    }
    throw const CloudSyncException('Cloud sync stopped at its safety limit.');
  }

  /// Refreshes the customers and promo periods used to attach a loyalty customer at the till.
  /// Never fails the sales sync: when it is unavailable (offline, or a backend without loyalty)
  /// the previous cache is kept and 0 is reported.
  Future<int> _downloadLoyalty() async {
    try {
      final response = await _authorizedRequest(
        '/api/v1/loyalty/pos-sync/',
        method: 'GET',
        errorPrefix: 'Customers could not be synchronized',
        offlineMessage: 'The shared customer list is unavailable.',
      );
      return await LoyaltyRepository(database).replaceFromCloud(response);
    } catch (_) {
      return 0;
    }
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
      await _writeSession(
          access: access, refresh: refresh, businessId: session.businessId);
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
    for (final key in _sessionKeys) {
      final raw = await store.read(key);
      if (raw == null) continue;
      try {
        final value = jsonDecode(raw);
        if (value is! Map ||
            value['access'] is! String ||
            value['refresh'] is! String) {
          continue;
        }
        if (key != _sessionKey) {
          await store.write(_sessionKey, raw);
          await store.remove(key);
        }
        final session = _CloudSession(
          value['access'] as String,
          value['refresh'] as String,
          value['businessId'] is String &&
                  (value['businessId'] as String).trim().isNotEmpty
              ? (value['businessId'] as String).trim()
              : 'xantara',
        );
        final company = await CompanyRegistrationRepository(database).read();
        if (company != null &&
            (company.cloudBusinessId.isEmpty ||
                company.cloudBusinessId != session.businessId)) {
          continue;
        }
        return session;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<void> _writeSession(
          {required String access,
          required String refresh,
          required String businessId}) =>
      store.write(
          _sessionKey,
          jsonEncode({
            'access': access,
            'refresh': refresh,
            'businessId': businessId,
          }));

  Future<String> _loadBusinessId(String access) async {
    try {
      final response = await dio.get<Object?>(
        '/api/v1/setup/status/',
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      final data = response.data;
      if (data is Map) {
        if (data['setup_required'] == true) {
          throw const CloudSyncException(
              'Complete company setup in the admin site first.');
        }
        final businessId = data['business_id'];
        if (businessId is String && businessId.trim().isNotEmpty) {
          return businessId.trim();
        }
      }
      // Compatibility with servers deployed before setup metadata existed.
      return 'xantara';
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return 'xantara';
      throw const CloudSyncException(
          'Company setup information could not be loaded.');
    }
  }
}

class CloudSyncResult {
  const CloudSyncResult({
    required this.uploadedEvents,
    required this.downloadedProducts,
    this.downloadedCustomers = 0,
  });

  final int uploadedEvents;
  final int downloadedProducts;
  final int downloadedCustomers;
}

class _CloudSession {
  const _CloudSession(this.access, this.refresh, this.businessId);
  final String access;
  final String refresh;
  final String businessId;
}

class _BranchRoutingTransport implements PremiumSyncTransport {
  const _BranchRoutingTransport(
      {required this.dio, required this.tokenProvider, this.company});
  final Dio dio;
  final AccessTokenProvider tokenProvider;
  final CompanyRegistration? company;

  @override
  Future<SyncAcknowledgement> upload(SyncEnvelope envelope) {
    final identity = company == null
        ? CloudSyncController.identities[envelope.branchId]
        : envelope.branchId == CompanyRegistration.branchId
            ? (
                installationId: company!.companyId,
                terminalId: company!.terminalId
              )
            : null;
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
