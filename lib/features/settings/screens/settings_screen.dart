import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/fnb/providers/cart_provider.dart';
import '../../cashier/providers/shift_provider.dart';
import '../providers/settings_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/providers/biometric_provider.dart';

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
        title: Text('Settings', style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        leading: const BackButton(color: AppColors.gray800),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenH),
        children: [
          const _ProfileCard(),
          const SizedBox(height: AppSizes.md),
          const _StoreSection(),
          const SizedBox(height: AppSizes.md),
          const _PreferencesSection(),
          const SizedBox(height: AppSizes.md),
          if (isAdmin) ...[
            const _AppearanceSection(),
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

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final initials = user.name.trim().split(' ')
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
              color: Color(0x0A000000),
              blurRadius: 3,
              offset: Offset(0, 1)),
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
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.gray400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.gray200, size: 20),
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
                color: Color(0x0A000000),
                blurRadius: 3,
                offset: Offset(0, 1)),
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
    final branch = ref.watch(branchProvider);
    final currency = ref.watch(currencyProvider);

    return _SectionCard(
      title: 'Store',
      icon: Icons.store_outlined,
      children: [
        _NavTile(
          label: 'Branch',
          value: branch,
          onTap: () => _editTextField(
            context: context,
            title: 'Branch',
            current: branch,
            onSave: (v) =>
                ref.read(branchProvider.notifier).state = v,
          ),
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _NavTile(
          label: 'Receipt Header',
          value: 'Edit',
          onTap: () {
            final current = ref.read(receiptHeaderProvider);
            _editTextField(
              context: context,
              title: 'Receipt Header',
              current: current,
              onSave: (v) =>
                  ref.read(receiptHeaderProvider.notifier).state = v,
            );
          },
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _NavTile(
          label: 'Currency',
          value: currency,
          onTap: () => _pickCurrency(context, ref, currency),
        ),
      ],
    );
  }

  void _editTextField({
    required BuildContext context,
    required String title,
    required String current,
    required ValueChanged<String> onSave,
  }) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSave(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.rButton)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickCurrency(
      BuildContext context, WidgetRef ref, String current) {
    const options = ['PHP', 'USD', 'EUR', 'SGD', 'JPY'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Currency', style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((opt) => ListTile(
                    title: Text(opt),
                    trailing: opt == current
                        ? const Icon(Icons.check,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(currencyProvider.notifier).state =
                          opt;
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
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
  final VoidCallback onTap;

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
          const Icon(Icons.chevron_right,
              size: 16, color: AppColors.gray400),
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
          onChanged: (v) =>
              ref.read(soundEffectsProvider.notifier).state = v,
        ),
        const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
        _PrefSwitch(
          label: 'Dark mode',
          value: dark,
          onChanged: (v) => ref.read(themeModeProvider.notifier).state =
              v ? ThemeMode.dark : ThemeMode.light,
        ),
        if (bioAvailable) ...[
          const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
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

// ── Cloud sync tile ───────────────────────────────────────────────────────────

class _CloudSyncTile extends ConsumerWidget {
  const _CloudSyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);

    final (label, color) = switch (sync.status) {
      SyncStatus.synced   => ('Active', AppColors.success),
      SyncStatus.syncing  => ('Syncing…', AppColors.warning),
      SyncStatus.offline  => ('Offline', AppColors.gray400),
      SyncStatus.complete => ('Synced', AppColors.success),
    };

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
              offset: Offset(0, 1)),
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
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(label,
                    style: AppTextStyles.labelMd
                        .copyWith(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
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
                style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
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
              Text('Theme Color', style: AppTextStyles.labelMd.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Text('Changes the primary color across the app',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.gray400)),
              const SizedBox(height: AppSizes.md),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: themeColorOptions.map((option) {
                  final isSelected =
                      option.color.toARGB32() == seedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => ref
                        .read(colorSeedProvider.notifier)
                        .state = option.color,
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
                                  strokeAlign:
                                      BorderSide.strokeAlignOutside,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: option.color
                                        .withValues(alpha: 0.5),
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
                  data: (i) => Text(
                      'v${i.version} (build ${i.buildNumber})',
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
