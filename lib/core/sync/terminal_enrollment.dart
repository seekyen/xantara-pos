import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../local/local_pos_store.dart';
import '../../local/repositories/company_registration_repository.dart';

class TerminalEnrollment {
  TerminalEnrollment({required this.repository, required this.store, Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
                baseUrl: const String.fromEnvironment('API_BASE_URL',
                    defaultValue: 'https://xantarapos.com')));
  final CompanyRegistrationRepository repository;
  final LocalPosStore store;
  final Dio dio;

  Future<CompanyRegistration> enroll(
      {required String terminalId,
      required String code,
      required String adminEmail,
      required String adminPassword,
      required String ownerName,
      required String ownerEmail,
      required String ownerPassword}) async {
    final db = repository.database;
    if (await repository.read() != null ||
        (await db.select(db.branches).get()).isNotEmpty ||
        (await db.select(db.staffUsers).get()).isNotEmpty ||
        (await db.select(db.invoices).get()).isNotEmpty) {
      throw StateError(
          'Enrollment requires an empty company workspace. Existing records are preserved.');
    }
    if (ownerPassword.length < 15 ||
        ownerName.trim().isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(ownerEmail.trim())) {
      throw ArgumentError(
          'Enter a local owner name, valid email and password of at least 15 characters.');
    }
    final key =
        'enrollment:${Uri.parse(dio.options.baseUrl).origin}:${terminalId.trim()}';
    final saved = await store.read(key);
    final identity = saved == null
        ? {
            'installation_id': const Uuid().v4(),
            'local_terminal_id': const Uuid().v4(),
          }
        : Map<String, dynamic>.from(jsonDecode(saved) as Map);
    if (identity['completed'] == true) {
      throw StateError(
          'This terminal was already enrolled here. Restore the existing POS database; its invoice series must not restart.');
    }
    // Save only identifiers before claiming, so a network/local-save failure can
    // retry the same claim without enrolling a second installation.
    await store.write(key, jsonEncode(identity));
    try {
      final login = await dio.post<dynamic>('/api/v1/auth/login/', data: {
        'email': adminEmail.trim(),
        'password': adminPassword,
      });
      final access = login.data['access'] as String;
      final result = await dio.post<dynamic>('/api/v1/settings/fiscal/enroll/',
          data: {
            ...identity,
            'terminal_id': terminalId.trim(),
            'enrollment_code': code.trim()
          },
          options: Options(headers: {'Authorization': 'Bearer $access'}));
      final config = Map<String, dynamic>.from(result.data as Map);
      if (config['companyId'] != identity['installation_id'] ||
          config['terminalId'] != identity['local_terminal_id'] ||
          config['serverTerminalId'] != terminalId.trim()) {
        throw const FormatException(
            'Enrollment response does not match this installation.');
      }
      final profile = await repository.registerEnrolled(config,
          ownerName: ownerName,
          ownerEmail: ownerEmail,
          ownerPassword: ownerPassword);
      // A completed setup must not retain the retry identity: recreating a lost
      // database must require recovery, never restart this terminal's series.
      await store.write(key, jsonEncode({'completed': true}));
      return profile;
    } on DioException catch (e) {
      throw StateError(e.response?.data == null
          ? 'Enrollment server unavailable. Retry on this installation when connected.'
          : 'Enrollment failed: ${e.response!.data}');
    }
  }
}
