import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/providers/display_preferences.dart';

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final seedColor = ref.watch(colorSeedProvider);

    return MaterialApp.router(
      title: 'Xantara POS',
      theme: AppTheme.light(seedColor),
      darkTheme: AppTheme.dark(seedColor),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => DeviceAppViewport(
        device: ref.watch(displayPreferencesProvider).device,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
