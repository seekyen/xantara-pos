import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

bool get supportsFloatingWindow =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

final displayPreferencesStoreProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Display preferences have not been initialized'),
);

final displayPreferencesProvider =
    StateNotifierProvider<DisplayPreferencesController, DisplayPreferences>(
  (ref) =>
      DisplayPreferencesController(ref.watch(displayPreferencesStoreProvider)),
);

enum DisplayDevice {
  automatic('Auto', Icons.devices, double.infinity),
  phone('Phone', Icons.smartphone, 480),
  tablet('Tablet', Icons.tablet_mac, 960),
  desktop('Desktop', Icons.desktop_windows, 1280);

  const DisplayDevice(this.label, this.icon, this.maxWidth);
  final String label;
  final IconData icon;
  final double maxWidth;
}

class DisplayPreferences {
  const DisplayPreferences(
      {this.device = DisplayDevice.automatic,
      this.floating = false,
      this.onTop = false});

  factory DisplayPreferences.read(SharedPreferences store) =>
      DisplayPreferences(
        device: DisplayDevice.values.firstWhere(
          (device) => device.name == store.getString('display.device'),
          orElse: () => store.getBool('display.mobile') == true
              ? DisplayDevice.phone
              : DisplayDevice.automatic,
        ),
        floating: store.getBool('display.floating') ?? false,
        onTop: store.getBool('display.onTop') ?? false,
      );

  final DisplayDevice device;
  bool get mobile => device == DisplayDevice.phone;
  final bool floating;
  final bool onTop;
}

class DisplayPreferencesController extends StateNotifier<DisplayPreferences> {
  DisplayPreferencesController(this.store)
      : super(DisplayPreferences.read(store));
  final SharedPreferences store;
  Rect? _previousBounds;
  bool _wasMaximized = false;

  Future<void> setMobile(bool value) async {
    await setDevice(value ? DisplayDevice.phone : DisplayDevice.automatic);
  }

  Future<void> setDevice(DisplayDevice device) async {
    if (!await store.setString('display.device', device.name)) {
      throw StateError('Could not save the device layout preference');
    }
    state = DisplayPreferences(
        device: device, floating: state.floating, onTop: state.onTop);
    final value = device == DisplayDevice.phone;
    if (!await store.setBool('display.mobile', value)) {
      throw StateError('Could not save the mobile layout preference');
    }
  }

  Future<void> setFloating(bool value) async {
    if (!supportsFloatingWindow) return;
    if (value) {
      _wasMaximized = await windowManager.isMaximized();
      _previousBounds = await windowManager.getBounds();
      await windowManager.setFullScreen(false);
      await windowManager.unmaximize();
      await windowManager.setSize(const Size(480, 760));
      await windowManager.center();
    } else {
      await windowManager.setBounds(
          _previousBounds ?? const Rect.fromLTWH(100, 100, 1280, 720));
      if (_wasMaximized) await windowManager.maximize();
    }
    await windowManager.show();
    await windowManager.focus();
    await store.setBool('display.floating', value);
    state = DisplayPreferences(
        device: state.device, floating: value, onTop: state.onTop);
  }

  Future<void> setOnTop(bool value) async {
    if (!supportsFloatingWindow) return;
    await windowManager.setAlwaysOnTop(value);
    await store.setBool('display.onTop', value);
    state = DisplayPreferences(
        device: state.device, floating: state.floating, onTop: value);
  }
}

/// Apply a real narrow viewport to every route, including dialogs and settings.
class MobileAppViewport extends StatelessWidget {
  const MobileAppViewport(
      {super.key, required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => DeviceAppViewport(
      device: enabled ? DisplayDevice.phone : DisplayDevice.automatic,
      child: child);
}

class DeviceAppViewport extends StatelessWidget {
  const DeviceAppViewport(
      {super.key, required this.device, required this.child});
  final DisplayDevice device;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: device.maxWidth),
          child: LayoutBuilder(builder: (context, constraints) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(size: constraints.biggest),
              child: child,
            );
          }),
        ),
      ),
    );
  }
}
