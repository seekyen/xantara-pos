import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/pricing/statutory_discount.dart';
import 'package:pos_app/features/auth/providers/auth_provider.dart';
import 'package:pos_app/features/checkout/providers/loyalty_provider.dart';
import 'package:pos_app/features/checkout/screens/checkout_screen.dart';
import 'package:pos_app/features/setup/company_setup_screen.dart';
import 'package:pos_app/features/pos/fnb/providers/cart_provider.dart';
import 'package:pos_app/features/pos/fnb/providers/pos_provider.dart' as fnb;
import 'package:pos_app/features/pos/retail/providers/grocery_cart_provider.dart'
    as retail;
import 'package:pos_app/features/pos/retail/widgets/grocery_payment_dialog.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/statutory_discount_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  for (final grocery in [false, true]) {
    testWidgets(
        '${grocery ? 'Grocery phone' : 'F&B'} captures beneficiary and commits the displayed discounted cash total',
        (tester) async {
      tester.view.physicalSize =
          grocery ? const Size(430, 932) : const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db =
          AppDatabase(NativeDatabase.memory(), requireRegistration: true);
      CompanyRegistration? profile;
      addTearDown(db.close);
      await tester.runAsync(() async {
        final staff = StaffAuthRepository(db,
            passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
        final reg = CompanyRegistrationRepository(db, staff: staff);
        profile = await reg.register(fixture.setup());
        await reg.activate(
            email: 'owner@example.test', password: fixture.password);
        await fixture.stock(db);
        await StatutoryDiscountRepository(db, staff: staff).configure(
            email: 'owner@example.test',
            password: fixture.password,
            branchId: CompanyRegistration.branchId,
            schemes: {
              grocery ? StatutoryScheme.bnpc : StatutoryScheme.foodService
            },
            classes: {
              'p': grocery
                  ? BenefitProductKind.bread
                  : BenefitProductKind.preparedFood
            });
      });
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        companyRegistrationProvider.overrideWith((ref) => profile),
        fnb.localPosStoreProvider.overrideWithValue(MemoryPosStore()),
        loyaltyRulesProvider.overrideWith((ref) => Stream.value([])),
      ]);
      addTearDown(container.dispose);
      await tester.runAsync(() => container
          .read(authProvider.notifier)
          .login('owner@example.test', fixture.password));
      if (grocery) {
        container.read(retail.groceryDiscountKindProvider.notifier).state =
            retail.GroceryDiscountKind.seniorPwd;
        container.read(retail.groceryCartProvider.notifier).scan(
            const retail.Product(
                id: 'p',
                name: 'Bread',
                price: 112,
                categoryId: 'food',
                color: Colors.blue));
      } else {
        container.read(cartProvider.notifier).addItem(const fnb.Product(
            id: 'p',
            name: 'Meal',
            price: 112,
            categoryId: 'food',
            color: Colors.blue));
      }
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
              home: Scaffold(
                  body: grocery
                      ? Builder(
                          builder: (context) => TextButton(
                              onPressed: () => showGroceryPaymentDialog(context,
                                  amountDue: 112),
                              child: const Text('Pay')))
                      : Builder(
                          builder: (context) => TextButton(
                              onPressed: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const CheckoutScreen()),
                              child: const Text('Checkout')))))));
      await tester.pumpAndSettle();
      if (!grocery) {
        await tester.tap(find.text('Checkout'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(grocery ? 'Pay' : 'Proceed to Payment'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Senior / PWD benefit'));
      await tester.tap(find.text('Senior / PWD benefit'));
      await tester.pumpAndSettle();
      Future<void> fill(String label, String value) async {
        final field = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == label);
        await tester.ensureVisible(field);
        await tester.enterText(field, value);
        await tester.pump();
      }

      // Incomplete proof cannot be applied or issue a sale.
      await tester.tap(find.text('Apply benefit'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsAtLeastNWidgets(1));
      await fill('Beneficiary full name', 'Sample Senior');
      await fill('Proof of entitlement / ID type', 'OSCA ID');
      await fill('ID number', 'SC-001');
      if (grocery) {
        await fill('Prior eligible purchases this week — PHP', '0');
        await fill('Prior BNPC discounts this week — PHP', '0');
      }
      final count = grocery ? 5 : 3;
      for (var i = 0; i < count; i++) {
        final check = find.byType(CheckboxListTile).at(i);
        await tester.ensureVisible(check);
        await tester.tap(check);
        await tester.pump();
      }
      await tester.tap(find.text('Apply benefit'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('SENIOR: Sample Senior'), findsOneWidget);
      final cash = find.byKey(
          ValueKey(grocery ? 'grocery-cash-received' : 'fnb-cash-received'));
      await tester.ensureVisible(cash);
      await tester.enterText(cash, '112');
      await tester.pump();
      final confirm = grocery
          ? find.text('Confirm')
          : find.text('Confirm Payment · ₱80.00');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final invoice = await db.select(db.invoices).getSingle();
        expect(invoice.totalCentavos, grocery ? 10640 : 8000);
        final payment = await db.select(db.payments).getSingle();
        expect(payment.changeCentavos, grocery ? 560 : 3200);
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
