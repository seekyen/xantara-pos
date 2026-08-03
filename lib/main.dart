import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/customer_display/customer_display_window.dart';
import 'local/database.dart';
import 'local/database_connection.dart';
import 'local/database_providers.dart';
import 'local/database_seed.dart';
import 'local/local_pos_store.dart';
import 'features/pos/providers/pos_provider.dart';

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
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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

  final preferences = await SharedPreferences.getInstance();
  final localStore = SharedPreferencesPosStore(preferences);

  final database = AppDatabase(await openAppDatabaseExecutor());
  await seedDatabaseIfEmpty(database);

  runApp(
    ProviderScope(
      overrides: [
        localPosStoreProvider.overrideWithValue(localStore),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const PosApp(),
    ),
  );
}
