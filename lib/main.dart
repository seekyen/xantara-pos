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
import 'features/pos/fnb/providers/pos_provider.dart';

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

  runApp(const _BootstrapApp());
}

class _AppDependencies {
  const _AppDependencies(this.localStore, this.database);

  final SharedPreferencesPosStore localStore;
  final AppDatabase database;
}

Future<_AppDependencies> _initializeApp() async {
  final preferences = await SharedPreferences.getInstance();
  final localStore = SharedPreferencesPosStore(preferences);
  final database = AppDatabase(await openAppDatabaseExecutor());

  try {
    await seedDatabaseIfEmpty(database);
    return _AppDependencies(localStore, database);
  } catch (_) {
    await database.close();
    rethrow;
  }
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<_AppDependencies> _dependencies = _initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      future: _dependencies,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 16),
                      const Text(
                        'Xantara POS could not start.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final dependencies = snapshot.data;
        if (dependencies == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return ProviderScope(
          overrides: [
            localPosStoreProvider.overrideWithValue(dependencies.localStore),
            appDatabaseProvider.overrideWithValue(dependencies.database),
          ],
          child: const PosApp(),
        );
      },
    );
  }
}
