import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/settings/providers/display_preferences.dart';
import 'features/customer_display/customer_display_window.dart';
import 'local/database.dart';
import 'local/database_connection.dart';
import 'local/database_providers.dart';
import 'local/database_seed.dart';
import 'local/local_pos_store.dart';
import 'features/pos/fnb/providers/pos_provider.dart';
import 'features/setup/company_setup_screen.dart';
import 'local/repositories/company_registration_repository.dart';
import 'shared/services/biometric_service.dart';
import 'core/theme/app_theme.dart';
import 'features/business_profiles/business_profile.dart';
import 'features/business_profiles/business_profile_providers.dart';
import 'local/repositories/business_profile_repository.dart';
import 'shared/providers/biometric_provider.dart';

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
    final display =
        DisplayPreferences.read(await SharedPreferences.getInstance());
    final WindowOptions windowOptions = WindowOptions(
      minimumSize: const Size(360, 480),
      size: supportsFloatingWindow && display.floating
          ? const Size(480, 760)
          : const Size(1280, 720),
      center: true,
      title: 'Xantara POS',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      if (supportsFloatingWindow) {
        await windowManager.setAlwaysOnTop(display.onTop);
      }
      await windowManager.focus();
    });
  }

  runApp(const _BootstrapApp());
}

class _AppDependencies {
  const _AppDependencies(this.localStore, this.database, this.preferences,
      this.company, this.demo, this.profile, this.type);
  final BusinessProfile profile;
  final BusinessCheckoutType? type;

  final SharedPreferences preferences;

  final LocalPosStore localStore;
  final AppDatabase database;
  final CompanyRegistration? company;
  final bool demo;
}

Future<_AppDependencies> _initializeApp({String? profileId}) async {
  final preferences = await SharedPreferences.getInstance();
  final localStore = SharedPreferencesPosStore(preferences);
  final catalog = BusinessProfileCatalog(preferences);
  final selected = profileId ?? catalog.activeId;
  var profile =
      catalog.profiles.firstWhere((p) => p.id == (selected ?? 'company'));
  var database = AppDatabase(
      await openAppDatabaseExecutor(name: profile.databaseName),
      requireRegistration: !profile.demo,
      requireBusinessProfile: true);

  try {
    var company = await CompanyRegistrationRepository(database).read();
    // A saved registration always wins over the demo preference.
    if (selected == null &&
        company == null &&
        (preferences.getBool('xantara.use-demo') ?? false)) {
      await database.close();
      profile = catalog.profiles.firstWhere((p) => p.id == 'demo');
      database = AppDatabase(await openAppDatabaseExecutor(),
          requireBusinessProfile: true);
      company = null;
    }
    if (profile.demo) await seedDatabaseIfEmpty(database);
    final type = await BusinessProfileRepository(database).readType();
    await catalog.select(profile.id);
    return _AppDependencies(
        profile.storeScope.isEmpty
            ? localStore
            : ScopedPosStore(localStore, profile.storeScope),
        database,
        preferences,
        company,
        profile.demo,
        profile,
        type);
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
  late Future<_AppDependencies> _dependencies = _initializeApp();
  int _generation = 0;
  bool _switching = false;

  Future<void> _switchBusiness(String id) async {
    if (_switching) {
      throw StateError('A business switch is already in progress.');
    }
    _switching = true;
    final previous = await _dependencies;
    try {
      // Prepare and validate the destination before disposing the current scope.
      final prepared = await _initializeApp(profileId: id);
      if (!mounted) {
        await prepared.database.close();
        return;
      }
      setState(() {
        _generation++;
        _dependencies = Future.value(prepared);
      });
      await WidgetsBinding.instance.endOfFrame;
      await previous.database.close();
    } finally {
      _switching = false;
    }
  }

  Future<void> _switchInstallation(bool demo) async {
    final previous = await _dependencies;
    if (previous.company != null && demo) {
      throw StateError(
          'A registered installation cannot switch into demo mode.');
    }
    if (demo) {
      await _switchBusiness('demo');
      return;
    }
    if (previous.profile.demo) {
      await _switchBusiness('company');
      return;
    }
    await previous.preferences.setBool('xantara.use-demo', false);
    await BiometricService().disable();
    if (!mounted) return;
    final next = Completer<_AppDependencies>();
    setState(() {
      _generation++;
      _dependencies = next.future;
    });
    // Dispose the old ProviderScope before closing its database.
    await WidgetsBinding.instance.endOfFrame;
    await previous.database.close();
    try {
      next.complete(await _initializeApp(profileId: previous.profile.id));
    } catch (error, stack) {
      next.completeError(error, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      key: ValueKey(_generation),
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
          key: ValueKey(_generation),
          overrides: [
            activeBusinessProfileProvider
                .overrideWithValue(dependencies.profile),
            businessProfileCatalogProvider.overrideWithValue(
                BusinessProfileCatalog(dependencies.preferences)),
            businessCheckoutTypeProvider
                .overrideWith((ref) => dependencies.type),
            switchBusinessHostProvider.overrideWithValue(_switchBusiness),
            biometricServiceProvider.overrideWithValue(
                BiometricService(scope: dependencies.profile.id)),
            companyRegistrationProvider
                .overrideWith((ref) => dependencies.company),
            isDemoInstallationProvider.overrideWithValue(dependencies.demo),
            switchInstallationProvider.overrideWith((ref) => (demo) async {
              ref.read(ensureBusinessSwitchAllowedProvider)();
              await _switchInstallation(demo);
            }),
            displayPreferencesStoreProvider
                .overrideWithValue(dependencies.preferences),
            localPosStoreProvider.overrideWithValue(dependencies.localStore),
            appDatabaseProvider.overrideWithValue(dependencies.database),
          ],
          child: !dependencies.demo && dependencies.company == null
              ? MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(const Color(0xFF6F4E37)),
                  home: const CompanySetupScreen())
              : const PosApp(),
        );
      },
    );
  }
}
