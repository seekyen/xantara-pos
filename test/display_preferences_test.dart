import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/features/pos/retail/screens/grocery_pos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_app/features/settings/providers/display_preferences.dart';

void main() {
  test('Device choices persist and migrate the existing mobile preference',
      () async {
    SharedPreferences.setMockInitialValues({'display.mobile': true});
    final store = await SharedPreferences.getInstance();
    final controller = DisplayPreferencesController(store);
    expect(controller.state.device, DisplayDevice.phone);
    for (final device in DisplayDevice.values) {
      await controller.setDevice(device);
      final restored = DisplayPreferencesController(store);
      expect(restored.state.device, device);
      restored.dispose();
    }
    controller.dispose();
  });

  testWidgets(
      'Device viewport resizes without losing form state or exceeding the screen',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = TextEditingController(text: 'staff@example.com');
    addTearDown(input.dispose);
    for (final width in [1600.0, 360.0]) {
      tester.view.physicalSize = Size(width, 900);
      for (final device in DisplayDevice.values) {
        late double actualWidth;
        await tester.pumpWidget(MaterialApp(
          builder: (context, child) =>
              DeviceAppViewport(device: device, child: child!),
          home: Builder(builder: (context) {
            actualWidth = MediaQuery.sizeOf(context).width;
            return Scaffold(body: TextField(controller: input));
          }),
        ));
        expect(actualWidth, width < device.maxWidth ? width : device.maxWidth);
        expect(find.text('staff@example.com'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Phone grocery register can switch from items to payment',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: GroceryPosScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Scan an item to begin'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Options'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Mobile preference survives controller recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferences.getInstance();
    final controller = DisplayPreferencesController(store);
    await controller.setMobile(true);
    controller.dispose();
    final restored = DisplayPreferencesController(store);
    expect(restored.state.mobile, isTrue);
    await restored.setMobile(false);
    expect(store.getBool('display.mobile'), isFalse);
    restored.dispose();
  });

  testWidgets('Mobile viewport constrains routes without enlarging phones',
      (tester) async {
    for (final width in [1200.0, 360.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final enabled in [true, false]) {
        late double viewportWidth;
        await tester.pumpWidget(MaterialApp(
          builder: (context, child) =>
              MobileAppViewport(enabled: enabled, child: child!),
          home: Builder(builder: (context) {
            viewportWidth = MediaQuery.sizeOf(context).width;
            return const Scaffold(body: SizedBox.expand());
          }),
        ));
        expect(viewportWidth, enabled && width > 480 ? 480 : width);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
