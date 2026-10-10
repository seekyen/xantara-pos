import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/features/business_profiles/business_profile.dart';
import 'package:pos_app/features/business_profiles/business_profile_providers.dart';
import 'package:pos_app/features/pos/fnb/providers/cart_provider.dart';
import 'package:pos_app/features/pos/retail/providers/grocery_cart_provider.dart';
import 'package:pos_app/local/database.dart' hide Product;
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/local/repositories/business_profile_repository.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'Catalog preserves legacy paths and persists independent profiles/scopes',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final catalog = BusinessProfileCatalog(prefs);
    expect(catalog.profiles.map((p) => p.databaseName),
        ['xantara_company', 'xantara_pos']);
    await catalog.select('company');
    final grocery = await catalog.add('My Grocery');
    await catalog.select(grocery.id);
    final reopened = BusinessProfileCatalog(prefs);
    expect(reopened.activeId, grocery.id);
    expect(reopened.profiles.last.databaseName, grocery.databaseName);
    await expectLater(catalog.select('unknown'), throwsStateError);
    await expectLater(catalog.add('my grocery'), throwsArgumentError);
    final memory = MemoryPosStore();
    final old = ScopedPosStore(memory, 'company'),
        next = ScopedPosStore(memory, grocery.storeScope);
    await old.write('cloud-token', 'old-business');
    expect(await next.read('cloud-token'), isNull);
    await next.write('cloud-token', 'new-business');
    expect(await old.read('cloud-token'), 'old-business');
  });

  test('Types are immutable and reject mismatched sales before any mutations',
      () async {
    final db = AppDatabase(NativeDatabase.memory(),
        requireRegistration: true, requireBusinessProfile: true);
    addTearDown(db.close);
    final types = BusinessProfileRepository(db);
    await types.initializeEmpty(BusinessCheckoutType.retail);
    final registration = CompanyRegistrationRepository(db,
        staff: StaffAuthRepository(db,
            passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
    final company = await registration.register(fixture.setup());
    await registration.activate(
        email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    final sales = OfflineSaleRepository(db);
    for (final wrong in [null, 'fnb', 'restaurant']) {
      await expectLater(
          sales.issueSale(fixture.sale(
              terminal: company.terminalId,
              actor: company.ownerId,
              checkoutType: wrong)),
          throwsStateError);
    }
    expect(await db.select(db.invoices).get(), isEmpty);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    await sales.issueSale(fixture.sale(
        terminal: company.terminalId,
        actor: company.ownerId,
        checkoutType: 'retail'));
    expect((await db.select(db.invoices).get()).length, 1);
    await expectLater(
        db.customStatement(
            "UPDATE business_profile_type SET checkout_type='fnb'"),
        throwsA(anything));
    await expectLater(db.customStatement('DELETE FROM business_profile_type'),
        throwsA(anything));
    await expectLater(
        types.initializeEmpty(BusinessCheckoutType.fnb), throwsStateError);
  });

  test(
      'Existing owner assigns once; migration/reopen preserves identity and sequence',
      () async {
    final dir = await Directory.systemTemp.createTemp('xantara-profiles-');
    final file = File('${dir.path}/existing.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final registration = CompanyRegistrationRepository(db,
        staff: StaffAuthRepository(db,
            passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
    final company = await registration.register(fixture.setup());
    await db.customStatement('DROP TABLE business_profile_type');
    await db.customStatement('PRAGMA user_version=10');
    await db.close();
    db = AppDatabase(NativeDatabase(file), requireBusinessProfile: true);
    try {
      final repository = BusinessProfileRepository(db);
      expect(await repository.readType(), isNull);
      await expectLater(repository.requireType('fnb'), throwsStateError);
      await expectLater(
          repository.assign(
              type: BusinessCheckoutType.fnb,
              email: 'owner@example.test',
              password: 'wrong'),
          throwsA(isA<AuthenticationException>()));
      await repository.assign(
          type: BusinessCheckoutType.fnb,
          email: 'owner@example.test',
          password: fixture.password);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      expect(await BusinessProfileRepository(db).readType(),
          BusinessCheckoutType.fnb);
      expect((await CompanyRegistrationRepository(db).read())!.companyId,
          company.companyId);
      expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
      final other = AppDatabase(NativeDatabase.memory());
      try {
        expect(await CompanyRegistrationRepository(other).read(), isNull);
        expect(await other.select(other.staffUsers).get(), isEmpty);
        expect(await other.select(other.invoices).get(), isEmpty);
      } finally {
        await other.close();
      }
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test(
      'Switch guard rejects both unfinished carts and delegates only when clear',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    String? selected;
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      switchBusinessHostProvider.overrideWithValue((id) async => selected = id)
    ]);
    addTearDown(container.dispose);
    const product = Product(
        id: 'p',
        name: 'Test',
        price: 100,
        categoryId: 'c',
        color: Colors.blue,
        stock: 10);
    container.read(cartProvider.notifier).addItem(product);
    await expectLater(
        container.read(switchBusinessProvider)('other'), throwsStateError);
    expect(selected, isNull);
    container.read(cartProvider.notifier).clear();
    container.read(groceryCartProvider.notifier).scan(product);
    await expectLater(
        container.read(switchBusinessProvider)('other'), throwsStateError);
    container.read(groceryCartProvider.notifier).clear();
    await container.read(switchBusinessProvider)('other');
    expect(selected, 'other');
  });
}
