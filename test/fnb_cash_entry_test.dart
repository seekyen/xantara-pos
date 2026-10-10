import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/features/checkout/providers/loyalty_provider.dart';
import 'package:pos_app/features/checkout/screens/checkout_screen.dart';
import 'package:pos_app/features/pos/fnb/providers/cart_provider.dart';
import 'package:pos_app/features/pos/fnb/providers/pos_provider.dart';
import 'package:pos_app/local/local_pos_store.dart';

void main() {
  testWidgets(
      'restaurant accepts typed cash, validates it and syncs quick amounts',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(overrides: [
      localPosStoreProvider.overrideWithValue(MemoryPosStore()),
      loyaltyRulesProvider.overrideWith((ref) => Stream.value([])),
    ]);
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).addItem(const Product(
          id: 'test',
          name: 'Meal',
          price: 112.25,
          categoryId: 'food',
          color: Colors.blue,
        ));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: CheckoutScreen())),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed to Payment'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('fnb-cash-received'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    ElevatedButton confirm() => tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm Payment · ₱112.25'));
    expect(confirm().onPressed, isNull);
    await tester.enterText(field, '100');
    await tester.pump();
    expect(confirm().onPressed, isNull);
    expect(find.text('Still due: ₱12.25'), findsOneWidget);
    await tester.enterText(field, '200.50');
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
    expect(find.text('₱88.25'), findsOneWidget);
    await tester.enterText(field, '200.501');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, '200.50');
    await tester.ensureVisible(find.text('Exact'));
    await tester.tap(find.text('Exact'));
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, '112.25');
    expect(find.text('₱0.00'), findsOneWidget);
    await tester.enterText(field, '');
    await tester.pump();
    expect(confirm().onPressed, isNull);
    await tester.enterText(field, '-10');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(confirm().onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
