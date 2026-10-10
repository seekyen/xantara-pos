import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/fnb/providers/cart_provider.dart';
import '../../cashier/providers/shift_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/store_settings_provider.dart';
import '../providers/staff_directory_provider.dart';
import '../providers/display_preferences.dart';
import 'staff_directory_screen.dart';
import 'statutory_settings_screen.dart';
import '../../setup/company_setup_screen.dart';
import '../../reports/terminal_readings_screen.dart';
import '../../business_profiles/business_profiles_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/providers/sync_target_provider.dart';
import '../../../shared/providers/biometric_provider.dart';
import '../../../shared/widgets/device_layout_selector.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = isAdminRole(ref.watch(authProvider).user?.role);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Settings',
            style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        leading: const BackButton(color: AppColors.gray800),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenH),
        children: [
          const _ProfileCard(),
          const BusinessProfilesTile(),
          const SizedBox(height: AppSizes.md),
          const CompanyRegistrationTile(),
          const TerminalReadingsTile(),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Senior / PWD settings'),
                  subtitle: const Text(
                      'Product eligibility and beneficiary sales register'),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const StatutorySettingsScreen())))),
          const SizedBox(height: AppSizes.md),
          const _StoreSection(),
          const SizedBox(height: AppSizes.md),
          const _PreferencesSection(),
          const SizedBox(height: AppSizes.md),
          const _DisplaySection(),
          const SizedBox(height: AppSizes.md),
          if (isAdmin) ...[
            const _AppearanceSection(),
            const SizedBox(height: AppSizes.md),
            const _StaffDirectoryTile(),
            const SizedBox(height: AppSizes.md),
          ],
          const _CloudSyncTile(),
          const SizedBox(height: AppSizes.md),
          const _AppVersionTile(),
          const SizedBox(height: AppSizes.md),
          const _SignOutTile(),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _DisplaySection extends ConsumerStatefulWidget {
  const _DisplaySection();

  @override
  ConsumerState<_DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends ConsumerState<_DisplaySection> {
  bool _busy = false;

  Future<void> _update(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not update display settings. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);
    return _SectionCard(
      title: 'App display',
      icon: Icons.devices,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: DeviceLayoutSelector(),
        ),
        if (supportsFloatingWindow) ...[
          SwitchListTile(
            title: const Text('Floating window'),
            subtitle: const Text(
                'Open the POS in a compact, movable Windows window.'),
            value: display.floating,
            onChanged: _busy
                ? null
                : (value) => _update(() => controller.setFloating(value)),
          ),
          SwitchListTile(
            title: const Text('Always on top'),
            subtitle: const Text('Keep the POS above other windows.'),
            value: display.onTop,
            onChanged: _busy
                ? null
                : (value) => _update(() => controller.setOnTop(value)),
          ),
        ],
      ],
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final initials = user.name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final roleLabel = roleLabelFor(user.role);

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.titleLg
                    .copyWith(fontSize: 16, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text('$roleLabel · ${user.email}',
                    style:
                        AppTextStyles.bodySm.copyWith(color: AppColors.gray400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray200, size: 20),
        ],
      ),
    );
  }
}

// ── Sign out ───────────────────────────────────────────────────────────────────

class _SignOutTile extends ConsumerWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(authProvider.notifier).logout();
        ref.read(cartProvider.notifier).clear();
        ref.read(shiftProvider.notifier).reset();
        context.go('/login');
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: AppSizes.md),
            Text('Sign Out',
                style: AppTextStyles.labelMd
                    .copyWith(fontSize: 14, color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

// ── Store section ─────────────────────────────────────────────────────────────

class _StoreSection extends ConsumerWidget {
  const _StoreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);

    if (!settings.connected) {
      return _SectionCard(
        title: 'Store',
        icon: Icons.store_outlined,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg, vertical: AppSizes.md),
            child: Text(
              'Connect Xantara Cloud below to manage the store name, receipt '
              'header, and currency shared with the admin dashboard.',
              style: AppTextStyles.labelMd
                  .copyWith(fontSize: 13, color: AppColors.gray400),
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'Store',
      icon: Icons.store_outlined,
      children: [
        if (settings.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.lg, AppSizes.sm, AppSizes.lg, 0),
            child: Text(settings.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
        _NavTile(
          label: 'Store Name',
          value: settings.loading ? 'Loading…' : settings.storeName,
          onTap: settings.loading
              ? null
              : () => _editTextField(
                    context: context,
                    title: 'Store Name',
                    current: settings.storeName,
                    onSave: (v) => ref
                        .read(storeSettingsProvider.notifier)
                        .updateStoreName(v),
                  ),
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _NavTile(
          label: 'Receipt Header',
          value: 'Edit',
          onTap: settings.loading
              ? null
              : () => _editTextField(
                    context: context,
                    title: 'Receipt Header',
                    current: settings.receiptHeader,
                    onSave: (v) => ref
                        .read(storeSettingsProvider.notifier)
                        .updateReceiptHeader(v),
                  ),
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _NavTile(
          label: 'Currency',
          value: settings.loading ? 'Loading…' : settings.currency,
          onTap: settings.loading
              ? null
              : () => _pickCurrency(context, ref, settings.currency),
        ),
      ],
    );
  }

  void _editTextField({
    required BuildContext context,
    required String title,
    required String current,
    required Future<void> Function(String) onSave,
  }) {
    final ctrl = TextEditingController(text: current);
    var busy = false;
    String? error;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title,
                style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  enabled: !busy,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(error!, style: const TextStyle(color: AppColors.error)),
                ],
              ],
            ),
            actions: [
              TextButton(
                  onPressed: busy ? null : () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (ctrl.text.trim().isEmpty) return;
                        setState(() {
                          busy = true;
                          error = null;
                        });
                        try {
                          await onSave(ctrl.text.trim());
                          if (context.mounted) Navigator.pop(context);
                        } catch (err) {
                          setState(() {
                            busy = false;
                            error = err.toString();
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rButton)),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickCurrency(BuildContext context, WidgetRef ref, String current) {
    // Restricted to PHP: it's the only currency the rest of the app (receipts,
    // reports, the web dashboard) actually formats — this field is now shared
    // with the web dashboard, so it shouldn't be set to a value nothing renders.
    const options = ['PHP'];
    var busy = false;
    String? error;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Currency',
                style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...options.map((opt) => ListTile(
                      title: Text(opt),
                      trailing: opt == current
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      enabled: !busy,
                      onTap: () async {
                        setState(() {
                          busy = true;
                          error = null;
                        });
                        try {
                          await ref
                              .read(storeSettingsProvider.notifier)
                              .updateCurrency(opt);
                          if (context.mounted) Navigator.pop(context);
                        } catch (err) {
                          setState(() {
                            busy = false;
                            error = err.toString();
                          });
                        }
                      },
                    )),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Text(error!,
                        style: const TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Nav tile ──────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label,
          style: AppTextStyles.bodyMd.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray400)),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
        ],
      ),
    );
  }
}

// ── Preferences section ───────────────────────────────────────────────────────

class _PreferencesSection extends ConsumerWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printOn = ref.watch(printOnCheckoutProvider);
    final sound = ref.watch(soundEffectsProvider);
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bioAvailable = ref.watch(biometricAvailableProvider).value ?? false;
    final bioEnabled = ref.watch(biometricEnabledProvider);
    final userEmail = ref.watch(authProvider).user?.email ?? '';

    return _SectionCard(
      title: 'Preferences',
      icon: Icons.tune_rounded,
      children: [
        _PrefSwitch(
          label: 'Print on checkout',
          value: printOn,
          onChanged: (v) =>
              ref.read(printOnCheckoutProvider.notifier).state = v,
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _PrefSwitch(
          label: 'Sound effects',
          value: sound,
          onChanged: (v) => ref.read(soundEffectsProvider.notifier).state = v,
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _PrefSwitch(
          label: 'Dark mode',
          value: dark,
          onChanged: (v) => ref.read(themeModeProvider.notifier).state =
              v ? ThemeMode.dark : ThemeMode.light,
        ),
        if (bioAvailable) ...[
          const Divider(
              height: 1, color: AppColors.gray100, indent: AppSizes.lg),
          _PrefSwitch(
            label: 'Biometric login',
            value: bioEnabled,
            onChanged: (v) {
              if (v) {
                _promptEnableBiometric(context, ref, userEmail);
              } else {
                ref.read(biometricEnabledProvider.notifier).disable();
              }
            },
          ),
        ],
      ],
    );
  }

  void _promptEnableBiometric(
      BuildContext context, WidgetRef ref, String email) {
    final ctrl = TextEditingController();
    bool obscure = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg),
          ),
          title: Text('Enable Biometric Login',
              style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
          content: TextField(
            controller: ctrl,
            obscureText: obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Confirm your password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.gray400,
                ),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.isEmpty) return;
                await ref
                    .read(biometricEnabledProvider.notifier)
                    .enable(email, ctrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rButton),
                ),
                elevation: 0,
              ),
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrefSwitch extends StatelessWidget {
  const _PrefSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label,
          style: AppTextStyles.bodyMd
              .copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ── Staff directory tile ──────────────────────────────────────────────────────

class _StaffDirectoryTile extends ConsumerWidget {
  const _StaffDirectoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Just watched to keep this tile in sync once Cloud connects — the
    // screen itself re-fetches via its own provider watch.
    ref.watch(staffDirectoryProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.rCard),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StaffDirectoryScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.rInput),
            ),
            child: const Icon(Icons.badge_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text('Staff directory',
                style: AppTextStyles.labelMd.copyWith(fontSize: 14)),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
        ]),
      ),
    );
  }
}

// ── Cloud sync tile ───────────────────────────────────────────────────────────

class _CloudSyncTile extends ConsumerWidget {
  const _CloudSyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);

    final (label, color) = switch (sync.status) {
      SyncStatus.synced => ('Active', AppColors.success),
      SyncStatus.syncing => ('Syncing…', AppColors.warning),
      SyncStatus.offline => ('Offline', AppColors.gray400),
      SyncStatus.complete => ('Synced', AppColors.success),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.rCard),
      onTap: sync.status == SyncStatus.syncing
          ? null
          : () => showDialog<void>(
                context: context,
                builder: (_) => const _CloudSyncDialog(),
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.rInput),
            ),
            child: const Icon(Icons.cloud_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text('Cloud sync',
                style: AppTextStyles.labelMd.copyWith(fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.rPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(label,
                    style: AppTextStyles.labelMd
                        .copyWith(fontSize: 12, color: color)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
        ]),
      ),
    );
  }
}

class _CloudSyncDialog extends ConsumerStatefulWidget {
  const _CloudSyncDialog();

  @override
  ConsumerState<_CloudSyncDialog> createState() => _CloudSyncDialogState();
}

class _CloudSyncDialogState extends ConsumerState<_CloudSyncDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(syncProvider.notifier).connectAndSync(
            email: _email.text,
            password: _password.text,
          );
      // Store settings and the staff directory couldn't be fetched before a
      // session existed — load them now that connectAndSync has established one.
      await ref.read(storeSettingsProvider.notifier).load();
      await ref.read(staffDirectoryProvider.notifier).load();
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(syncTargetProvider);
    return AlertDialog(
      title: const Text('Connect Xantara Cloud'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<SyncTarget>(
              segments: const [
                ButtonSegment(
                  value: SyncTarget.local,
                  label: Text('Local'),
                  icon: Icon(Icons.computer, size: 16),
                ),
                ButtonSegment(
                  value: SyncTarget.cloud,
                  label: Text('VPS Cloud'),
                  icon: Icon(Icons.cloud_outlined, size: 16),
                ),
              ],
              selected: {target},
              onSelectionChanged: _busy
                  ? null
                  : (selection) => ref
                      .read(syncTargetProvider.notifier)
                      .select(selection.first),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Use an administrator account for this backend: '
              '${target.baseUrl}. '
              'Your password is not saved on this device.',
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(labelText: 'Cloud email'),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _password,
              enabled: !_busy,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _busy ? null : _connect(),
              decoration: const InputDecoration(labelText: 'Cloud password'),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _connect,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect & sync'),
        ),
      ],
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: AppSizes.sm),
          child: Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: AppSizes.xs),
              Text(
                title.toUpperCase(),
                style:
                    AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCard),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Appearance ────────────────────────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedColor = ref.watch(colorSeedProvider);

    return _SectionCard(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Color',
                  style: AppTextStyles.labelMd.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Text('Changes the primary color across the app',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.gray400)),
              const SizedBox(height: AppSizes.md),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: themeColorOptions.map((option) {
                  final isSelected =
                      option.color.toARGB32() == seedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => ref.read(colorSeedProvider.notifier).state =
                        option.color,
                    child: Tooltip(
                      message: option.label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white,
                                  width: 3,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: option.color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Version tile ──────────────────────────────────────────────────────────────

class _AppVersionTile extends ConsumerWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(_packageInfoProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.rInput),
            ),
            child: const Icon(Icons.info_outline,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('App Version',
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
                info.when(
                  data: (i) => Text('v${i.version} (build ${i.buildNumber})',
                      style: AppTextStyles.caption),
                  loading: () =>
                      const Text('...', style: AppTextStyles.caption),
                  error: (_, __) =>
                      const Text('N/A', style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
