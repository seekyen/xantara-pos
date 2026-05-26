import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'features/customer_display/customer_display_window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // CUSTOMER_DISPLAY — secondary window spawned by desktop_multi_window
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    if (argument['type'] == 'customer_display') {
      runApp(ProviderScope(child: CustomerDisplayApp(windowId: windowId)));
      return;
    }
  }

  // Main POS window — apply window_manager only on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(800, 600),
      size: Size(1280, 720),
      center: true,
      title: 'Xantara POS',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ProviderScope(child: PosApp()));
}
