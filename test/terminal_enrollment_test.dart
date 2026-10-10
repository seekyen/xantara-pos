import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/sync/terminal_enrollment.dart';
import 'package:pos_app/core/sync/cloud_sync_controller.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';

void main() {
  late AppDatabase db;
  late CompanyRegistrationRepository repo;
  late MemoryPosStore store;
  late Dio dio;
  final claims = <Map<String, dynamic>>[];
  const serverTerminal = '432621da-07da-4e99-8d09-39d386a8a2a3';
  const secret = 'Local owner password 12345';
  var failClaim = false;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), requireRegistration: true);
    repo = CompanyRegistrationRepository(db,
        staff: StaffAuthRepository(db,
            passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
    store = MemoryPosStore();
    claims.clear();
    failClaim = false;
    dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8086'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (r, h) {
      if (r.path.endsWith('/login/')) {
        h.resolve(
            Response(requestOptions: r, data: {'access': 'access-token'}));
      } else {
        final d = Map<String, dynamic>.from(r.data as Map);
        claims.add(d);
        if (failClaim) {
          h.reject(DioException(
              requestOptions: r, type: DioExceptionType.connectionError));
          return;
        }
        h.resolve(Response(requestOptions: r, data: {
          'companyId': d['installation_id'],
          'terminalId': d['local_terminal_id'],
          'serverTerminalId': serverTerminal,
          'cloudBusinessId': 'acme',
          'cloudBranchCode': 'SHOP02',
          'registeredName': 'Acme Retail',
          'tin': '123456789',
          'address': 'Shop Two address',
          'branchCode': '00002',
          'rdo': '039',
          'registrationType': 'vat',
          'terminalCode': 'POS02',
          'machineSerial': 'SERIAL-02',
          'min': 'MIN-02',
          'ptu': 'PTU-02',
          'ptuIssuedOn': '2026-01-01',
          'startingSerial': 77,
          'activatedAt': '2026-01-02T00:00:00Z',
        }));
      }
    }));
  });
  tearDown(() async {
    dio.close();
    await db.close();
  });
  Future<CompanyRegistration> enroll({String password = secret}) =>
      TerminalEnrollment(repository: repo, store: store, dio: dio).enroll(
          terminalId: serverTerminal,
          code: 'one-time-code',
          adminEmail: 'admin@acme.test',
          adminPassword: 'server password',
          ownerName: 'Local Owner',
          ownerEmail: 'owner@acme.test',
          ownerPassword: password);

  test('imports server identity, assigned branch and exact sequence atomically',
      () async {
    final p = await enroll();
    expect(p.isActive, true);
    expect(p.companyId, claims.single['installation_id']);
    expect(p.terminalId, claims.single['local_terminal_id']);
    expect(p.cloudBranchCode, 'SHOP02');
    expect(p.address, 'Shop Two address');
    expect((await repo.read())!.serverTerminalId, serverTerminal);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 77);
    expect((await db.select(db.terminals).getSingle()).id, p.terminalId);
    final events = await db.select(db.auditEvents).get();
    expect(jsonEncode(events.map((e) => e.payloadJson).toList()),
        isNot(contains(secret)));
    expect(jsonEncode(events.map((e) => e.payloadJson).toList()),
        isNot(contains('one-time-code')));
    await expectLater(
        repo.updateDraft(CompanySetupRequest(
            registeredName: 'Changed',
            tin: p.tin,
            address: p.address,
            branchCode: p.branchCode,
            rdo: p.rdo,
            registrationType: p.registrationType,
            terminalCode: p.terminalCode,
            machineSerial: p.machineSerial,
            min: p.min,
            ptu: p.ptu,
            ptuIssuedOn: p.ptuIssuedOn,
            startingSerial: 1,
            ownerName: 'Local Owner',
            ownerEmail: 'owner@acme.test',
            ownerPassword: secret)),
        throwsStateError);
  });

  test(
      'network retry retains installation identity without storing credentials',
      () async {
    failClaim = true;
    await expectLater(enroll(), throwsStateError);
    expect(await repo.read(), isNull);
    failClaim = false;
    await enroll();
    expect(claims[1]['installation_id'], claims[0]['installation_id']);
    expect(claims[1]['local_terminal_id'], claims[0]['local_terminal_id']);
    final pending =
        await store.read('enrollment:http://127.0.0.1:8086:$serverTerminal');
    expect(pending, isNot(contains('one-time-code')));
    expect(pending, isNot(contains('password')));
    expect(jsonDecode(pending!)['completed'], true);
    expect(pending, isNot(contains('installation_id')));
  });

  test('existing registration never claims again or resets invoice sequence',
      () async {
    await enroll();
    await expectLater(enroll(), throwsStateError);
    expect(claims, hasLength(1));
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 77);
  });

  test('invalid local owner credentials rejected before server claim',
      () async {
    await expectLater(enroll(password: 'short'), throwsArgumentError);
    expect(claims, isEmpty);
  });

  test('enrolled POS downloads its assigned branch rather than MAIN', () async {
    await enroll();
    final payload = base64Url
        .encode(utf8.encode(jsonEncode({
          'exp': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000,
        })))
        .replaceAll('=', '');
    await store.write(
        'xantara.cloud-sync-session.v1:http://127.0.0.1:8086',
        jsonEncode({
          'access': 'header.$payload.signature',
          'refresh': 'refresh',
          'businessId': 'acme',
        }));
    final requests = <RequestOptions>[];
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (r, h) {
      requests.add(r);
      h.resolve(Response(requestOptions: r, data: <dynamic>[]));
    }));
    final controller =
        CloudSyncController(database: db, store: store, dio: dio);
    await controller.syncNow();
    await controller.inventoryRequest('?branch=MAIN');
    final catalog =
        requests.where((r) => r.uri.path == '/api/v1/inventory-items/');
    expect(catalog, hasLength(2));
    expect(catalog.every((r) => r.uri.queryParameters['branch'] == 'SHOP02'),
        true);
  });
}
