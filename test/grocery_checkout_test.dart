import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/features/pos/retail/providers/grocery_cart_provider.dart';
import 'package:pos_app/features/pos/retail/providers/grocery_checkout_provider.dart';
import 'package:pos_app/local/database.dart' hide Product;
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/local_pos_store.dart';
import 'package:pos_app/features/auth/providers/auth_provider.dart';
import 'package:pos_app/features/pos/fnb/providers/pos_provider.dart'
    show localPosStoreProvider;
import 'package:pos_app/features/pos/retail/widgets/grocery_payment_dialog.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  late AppDatabase db;
  late Directory dir;
  late CompanyRegistration profile;
  late GroceryCheckout checkout;
  List<GroceryCartItem> basket({int quantity = 2, double price = 112}) => [
        GroceryCartItem(
            product: Product(
                id: 'p',
                name: 'Product',
                price: price,
                categoryId: 'test',
                color: Colors.blue),
            quantity: quantity)
      ];
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('grocery-sale-');
    db = AppDatabase(NativeDatabase(File('${dir.path}/sale.sqlite')),
        requireRegistration: true);
    final repo = CompanyRegistrationRepository(db,
        staff: StaffAuthRepository(db,
            passwordHasher: Pbkdf2PasswordHasher(iterations: 2)));
    profile = await repo.register(fixture.setup());
    await repo.activate(
        email: 'owner@example.test', password: fixture.password);
    await fixture.stock(db);
    checkout = GroceryCheckout(OfflineSaleRepository(db));
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  Future<ReceiptPrintData> pay(
          {int cash = 30000,
          int quantity = 2,
          double price = 112,
          GroceryPaymentMethod method = GroceryPaymentMethod.cash,
          GroceryDiscountKind? kind,
          String discount = '',
          GroceryCoupon? coupon,
          GroceryDiscountUnit unit = GroceryDiscountUnit.percent}) =>
      checkout.submit(
          items: basket(quantity: quantity, price: price),
          branchCode: 'MAIN',
          actorId: profile.ownerId,
          tenderedCentavos: cash,
          method: method,
          discountKind: kind,
          customDiscount: discount,
          coupon: coupon,
          unit: unit);

  test(
      'cash sale survives restart with invoice, payment, stock, audit and queues',
      () async {
    final result = await pay();
    expect(result.invoice.invoiceNumber, '00000-POSA1234567-00000042');
    expect(result.invoice.seller.registeredName, 'Example Company');
    expect(result.payment.amountCentavos, 22400);
    expect(result.payment.changeCentavos, 7600);
    expect(const BirReceiptFormatter().format(result),
        contains('Invoice No: 00000-POSA1234567-00000042'));
    await db.close();
    db = AppDatabase(NativeDatabase(File('${dir.path}/sale.sqlite')),
        requireRegistration: true);
    expect((await db.select(db.invoices).getSingle()).id, result.invoice.id);
    expect((await db.select(db.payments).getSingle()).amountCentavos, 22400);
    expect((await db.select(db.branchInventories).getSingle()).stockOnHand, 8);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    expect(
        (await db.select(db.inventoryMovements).getSingle()).quantityDelta, -2);
    expect(
        (await db.select(db.auditEvents).get())
            .any((e) => e.eventType == 'invoice.issued'),
        true);
    expect(await db.select(db.syncOutboxEvents).get(), isNotEmpty);
    expect(await db.select(db.hardwareJobs).get(), hasLength(2));
    final history = await OfflineSaleRepository(db)
        .watchSales(branchId: CompanyRegistration.branchId)
        .first;
    expect(history.single.invoice.id, result.invoice.id);
  });

  test('concurrent submit records only one invoice', () async {
    final results = await Future.wait([pay(), pay()]);
    expect(results.first.invoice.id, results.last.invoice.id);
    expect(await db.select(db.invoices).get(), hasLength(1));
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
  });

  test(
      'insufficient cash, stock, stale price and invalid discounts leave no sale',
      () async {
    for (final attempt in [
      () => pay(cash: 100),
      () => pay(quantity: 11, cash: 999999),
      () => pay(price: 111),
      () => pay(kind: GroceryDiscountKind.custom, discount: '101'),
      () => pay(kind: GroceryDiscountKind.custom, discount: 'NaN'),
    ]) {
      await expectLater(attempt(), throwsA(anything));
      expect(await db.select(db.invoices).get(), isEmpty);
      expect(await db.select(db.payments).get(), isEmpty);
      expect(await db.select(db.hardwareJobs).get(), isEmpty);
      expect(
          (await db.select(db.branchInventories).getSingle()).stockOnHand, 10);
      expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 42);
    }
    expect((await pay()).invoice.totalCentavos, 22400);
  });

  test(
      'electronic references, senior discount and demo coupon cannot authorize a live sale',
      () async {
    await expectLater(pay(method: GroceryPaymentMethod.card), throwsStateError);
    await expectLater(
        pay(kind: GroceryDiscountKind.seniorPwd), throwsStateError);
    await expectLater(
        pay(coupon: const GroceryCoupon(code: 'DISC200', amountOff: 200)),
        throwsStateError);
    expect(await db.select(db.invoices).get(), isEmpty);
  });

  test('custom discount rounds once and persists in invoice lines', () async {
    final result =
        await pay(kind: GroceryDiscountKind.custom, discount: '12.345');
    expect(result.invoice.totalCentavos, 19635);
    expect(result.invoice.lines.single.discountCentavos, 2765);
    expect(
        (await db.select(db.invoiceLines).getSingle()).discountCentavos, 2765);
    expect(result.payment.changeCentavos, 10365);
  });

  test('mixed-tax discount allocation preserves every centavo', () async {
    await db.into(db.products).insert(ProductsCompanion.insert(
        id: 'q',
        sku: 'Q',
        name: 'Exempt item',
        taxCategory: 'vat_exempt',
        unitPriceCentavos: 10001,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    await db.into(db.branchInventories).insert(
        BranchInventoriesCompanion.insert(
            branchId: CompanyRegistration.branchId,
            productId: 'q',
            stockOnHand: const Value(5),
            updatedAt: DateTime.now()));
    final result = await checkout.submit(
        items: [
          ...basket(quantity: 1),
          const GroceryCartItem(
              product: Product(
                  id: 'q',
                  name: 'Exempt item',
                  price: 100.01,
                  categoryId: 'test',
                  color: Colors.blue),
              quantity: 1)
        ],
        branchCode: 'MAIN',
        actorId: profile.ownerId,
        tenderedCentavos: 30000,
        method: GroceryPaymentMethod.cash,
        discountKind: GroceryDiscountKind.custom,
        customDiscount: '0.01',
        unit: GroceryDiscountUnit.peso);
    expect(result.invoice.totalCentavos, 21200);
    expect(
        result.invoice.lines
            .fold<int>(0, (v, line) => v + line.discountCentavos),
        1);
    expect(result.invoice.taxSummary.vatExemptSalesCentavos, 10001);
  });

  testWidgets('failed checkout keeps cart and successful retry clears it once',
      (tester) async {
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      localPosStoreProvider.overrideWithValue(MemoryPosStore()),
    ]);
    addTearDown(container.dispose);
    await tester.runAsync(() => container
        .read(authProvider.notifier)
        .login('owner@example.test', fixture.password));
    container
        .read(groceryCartProvider.notifier)
        .scan(basket().first.product, quantity: 11);
    ReceiptPrintData? receipt;
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Scaffold(
                body: Builder(
                    builder: (context) => TextButton(
                        onPressed: () async {
                          receipt = await showGroceryPaymentDialog(context,
                              amountDue: 1232);
                        },
                        child: const Text('Pay')))))));
    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    for (final entry in {
      'name': 'Grocery Business',
      'tin': '123456789',
      'address': 'Grocery buyer address'
    }.entries) {
      final field = find.byKey(ValueKey('invoice-buyer-${entry.key}'));
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }
    await tester.enterText(
        find.byKey(const ValueKey('grocery-cash-received')), '2000');
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('Sale was not recorded'), findsOneWidget);
    expect(container.read(groceryCartProvider).single.quantity, 11);
    await tester.runAsync(() async {
      await (db.update(db.branchInventories)
            ..where((row) => row.productId.equals('p')))
          .write(const BranchInventoriesCompanion(stockOnHand: Value(20)));
    });
    await tester.tap(find.text('Confirm'));
    await tester.tap(find.text('Confirm'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(receipt, isNotNull);
    expect(receipt!.invoice.buyer!.registeredName, 'Grocery Business');
    expect(receipt!.invoice.buyer!.isBusiness, true);
    expect(container.read(groceryCartProvider), isEmpty);
    await tester.runAsync(() async {
      expect(await db.select(db.invoices).get(), hasLength(1));
    });
  });
}
