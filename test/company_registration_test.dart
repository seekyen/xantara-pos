import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/core/sync/cloud_sync_controller.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';

const password = 'A unique owner passphrase 2026';

CompanySetupRequest setup(
        {String tin = '123456789',
        String branch = '00000',
        String terminal = 'POSA1234567',
        int serial = 42,
        String secret = password}) =>
    CompanySetupRequest(
      registeredName: 'Example Company',
      tin: tin,
      address: 'Quezon City',
      branchCode: branch,
      rdo: '039',
      registrationType: TaxRegistrationType.vat,
      terminalCode: terminal,
      machineSerial: 'DEVICE-001',
      min: 'MIN-2026-001',
      ptu: 'PTU-2026-001',
      ptuIssuedOn: '2026-09-01',
      startingSerial: serial,
      ownerName: 'Company Owner',
      ownerEmail: 'owner@example.test',
      ownerPassword: secret,
      cloudBusinessId: 'example-company',
    );

void main() {
  late AppDatabase db;
  late CompanyRegistrationRepository registration;
  late StaffAuthRepository auth;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), requireRegistration: true);
    auth = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    registration = CompanyRegistrationRepository(db, staff: auth);
  });
  tearDown(() => db.close());

  test(
      'registers one owner, unique device identity and exact starting series without demo data',
      () async {
    final profile = await registration.register(setup());
    expect(profile.isActive, isFalse);
    expect((await registration.read())!.companyId, profile.companyId);
    expect(profile.terminalId, isNot('branch-main-pos01'));
    expect((await db.select(db.staffUsers).getSingle()).role, 'owner');
    expect((await db.select(db.staffUsers).getSingle()).passwordHash,
        isNot(password));
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    expect(await db.select(db.products).get(), isEmpty);
    expect(await db.select(db.invoices).get(), isEmpty);
    final audit = await db.select(db.auditEvents).get();
    expect(audit.last.eventType, 'company.registered');
    expect(audit.any((e) => e.payloadJson.contains(password)), isFalse);
  });

  test('rejects invalid registration and rolls back owner failure completely',
      () async {
    for (final invalid in [
      setup(tin: '000000000'),
      setup(branch: 'MAIN'),
      setup(terminal: 'bad code'),
      setup(serial: 0)
    ]) {
      await expectLater(registration.register(invalid), throwsArgumentError);
    }
    await expectLater(registration.register(setup(secret: 'short')),
        throwsA(isA<PasswordPolicyException>()));
    expect(await registration.read(), isNull);
    expect(await db.select(db.branches).get(), isEmpty);
    expect(await db.select(db.terminals).get(), isEmpty);
    expect(await db.select(db.staffUsers).get(), isEmpty);
  });

  test('rejects duplicate registration without changing the series or owner',
      () async {
    final original = await registration.register(setup());
    await expectLater(
        registration.register(setup(serial: 1)), throwsStateError);
    expect((await registration.read())!.companyId, original.companyId);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    expect(await db.select(db.staffUsers).get(), hasLength(1));
  });

  test(
      'owner can correct draft but cannot change registration after activation',
      () async {
    final original = await registration.register(setup());
    final updated =
        await registration.updateDraft(setup(serial: 77, branch: '00001'));
    expect(updated.companyId, original.companyId);
    expect(updated.terminalId, original.terminalId);
    expect(updated.branchCode, '00001');
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 77);
    await registration.activate(
        email: 'owner@example.test', password: password);
    await expectLater(
        registration.updateDraft(setup(serial: 1)), throwsStateError);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 77);
  });

  test('refuses to convert an existing database in place', () async {
    await db.into(db.branches).insert(BranchesCompanion.insert(
        id: 'legacy',
        code: 'LEGACY',
        name: 'Preserved',
        createdAt: DateTime.now()));
    await expectLater(registration.register(setup()), throwsStateError);
    expect((await db.select(db.branches).getSingle()).name, 'Preserved');
  });

  test(
      'activation requires the registered owner and records only one transition',
      () async {
    await registration.register(setup());
    await auth.createStaff(CreateStaffRequest(
        displayName: 'Other',
        email: 'other@example.test',
        role: StaffRole.manager,
        password: password,
        branchIds: {CompanyRegistration.branchId},
        createdBy: 'test',
        createdAt: DateTime.now()));
    await expectLater(
        registration.activate(email: 'other@example.test', password: password),
        throwsA(isA<AuthorizationException>()));
    await expectLater(
        registration.activate(email: 'owner@example.test', password: 'wrong'),
        throwsA(isA<AuthenticationException>()));
    expect((await registration.read())!.isActive, isFalse);
    expect(
        (await (db.select(db.staffUsers)
                  ..where(
                      (u) => u.emailNormalized.equals('owner@example.test')))
                .getSingle())
            .failedLoginAttempts,
        1);
    final activated = await registration.activate(
        email: 'owner@example.test', password: password);
    expect(activated.isActive, isTrue);
    await registration.activate(
        email: 'owner@example.test', password: password);
    expect(
        (await db.select(db.auditEvents).get())
            .where((e) => e.eventType == 'company.activated'),
        hasLength(1));
  });

  test(
      'sale requires setup, activation and authorized actor; seller comes from saved registration',
      () async {
    final sales = OfflineSaleRepository(db);
    await expectLater(sales.issueSale(sale(terminal: 'unset', actor: 'unset')),
        throwsStateError);
    final profile = await registration.register(setup());
    await stock(db);
    await expectLater(
        sales.issueSale(
            sale(terminal: profile.terminalId, actor: profile.ownerId)),
        throwsStateError);
    await registration.activate(
        email: 'owner@example.test', password: password);
    await expectLater(
        sales.issueSale(sale(terminal: 'wrong', actor: profile.ownerId)),
        throwsStateError);
    await expectLater(
        sales.issueSale(sale(terminal: profile.terminalId, actor: 'unknown')),
        throwsA(isA<AuthorizationException>()));
    final invoice = await sales
        .issueSale(sale(terminal: profile.terminalId, actor: profile.ownerId));
    expect(invoice.seller.registeredName, 'Example Company');
    expect(invoice.seller.tin, '123456789');
    expect(invoice.seller.branchCode, '00000');
    expect(invoice.invoiceNumber, '00000-POSA1234567-00000042');
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
  });

  test('synced exempt category works for a registered VAT company', () async {
    final p = await registration.register(setup());
    await registration.activate(
        email: 'owner@example.test', password: password);
    await stock(db, tax: 'vat_exempt');
    final invoice = await OfflineSaleRepository(db)
        .issueSale(sale(terminal: p.terminalId, actor: p.ownerId));
    expect(invoice.taxSummary.vatExemptSalesCentavos, 11200);
    expect(invoice.taxSummary.vatAmountCentavos, 0);
  });

  test(
      'registered cloud connection rejects a different business before saving session',
      () async {
    await registration.register(setup());
    final store = MemoryPosStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: options.path.contains('login')
              ? {
                  'access': 'a',
                  'refresh': 'b',
                  'user': {'role': 'admin'}
                }
              : {'setup_required': false, 'business_id': 'wrong-company'}));
    }));
    final cloud = CloudSyncController(database: db, store: store, dio: dio);
    await expectLater(
        cloud.connect(email: 'cloud@example.test', password: password),
        throwsA(isA<CloudSyncException>()));
    expect(await cloud.isConfigured, isFalse);
  });

  test('scoped local store does not inherit or overwrite demo sessions',
      () async {
    final base = MemoryPosStore({'session': 'demo'});
    final company = ScopedPosStore(base, 'company');
    expect(await company.read('session'), isNull);
    await company.write('session', 'live');
    expect(await base.read('session'), 'demo');
    expect(await company.read('session'), 'live');
    await company.remove('session');
    expect(await base.read('session'), 'demo');
  });

  test(
      'v5 migration preserves existing rows and registration survives reopening',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('company-registration-test-');
    final file = File('${directory.path}/pos.sqlite');
    var persistent =
        AppDatabase(NativeDatabase(file), requireRegistration: true);
    try {
      // Build a v5-shaped DB without the new singleton table.
      await persistent.customSelect('SELECT 1').get();
      await persistent.customStatement('DROP TABLE company_registration');
      await persistent.customStatement('PRAGMA user_version = 5');
      await persistent.close();
      persistent = AppDatabase(NativeDatabase(file), requireRegistration: true);
      final r = CompanyRegistrationRepository(persistent,
          staff: StaffAuthRepository(persistent,
              passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
      final p = await r.register(setup());
      await r.activate(email: 'owner@example.test', password: password);
      await persistent.close();
      persistent = AppDatabase(NativeDatabase(file), requireRegistration: true);
      final restored = await CompanyRegistrationRepository(persistent).read();
      expect(restored!.companyId, p.companyId);
      expect(restored.isActive, isTrue);
      expect(
          (await persistent.select(persistent.invoiceSequences).getSingle())
              .nextValue,
          42);
    } finally {
      await persistent.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<void> stock(AppDatabase db, {String tax = 'vat12'}) async {
  await db.into(db.products).insert(ProductsCompanion.insert(
      id: 'p',
      sku: 'P',
      name: 'Product',
      taxCategory: tax,
      unitPriceCentavos: 11200,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now()));
  await db.into(db.branchInventories).insert(BranchInventoriesCompanion.insert(
      branchId: CompanyRegistration.branchId,
      productId: 'p',
      stockOnHand: const Value(10),
      updatedAt: DateTime.now()));
}

OfflineSaleRequest sale(
        {required String terminal,
        required String actor,
        BirBuyerDetails? buyer,
        String? checkoutType,
        String? demoPromotionCode,
        DateTime? issuedAt,
        String paymentId = 'pay'}) =>
    OfflineSaleRequest(
      branchId: CompanyRegistration.branchId,
      terminalId: terminal,
      actorId: actor,
      issuedAt: issuedAt ?? DateTime.now(),
      payment: PaymentEvidence(
          id: paymentId,
          provider: PaymentProvider.cash,
          status: PaymentStatus.captured,
          amountCentavos: 11200,
          reference: 'cash',
          authorizedAt: DateTime.now(),
          isOffline: true,
          cashTenderedCentavos: 11200,
          changeCentavos: 0),
      sellerName: 'Forged seller',
      sellerTin: '999999999',
      sellerAddress: 'Wrong',
      registrationType: TaxRegistrationType.nonVat,
      softwareName: 'Xantara POS',
      softwareVersion: '1.0.0',
      lines: const [OfflineSaleLineRequest(productId: 'p', quantity: 1)],
      buyer: buyer,
      checkoutType: checkoutType,
      demoPromotionCode: demoPromotionCode,
    );
