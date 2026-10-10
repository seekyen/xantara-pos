import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/staff_directory_provider.dart';

/// Read-only staff + branch roster sourced from the connected Xantara Cloud
/// session — mirrors the admin web dashboard's Staff page. This device's own
/// cashier login is unaffected; see staff_directory_provider.dart.
class StaffDirectoryScreen extends ConsumerWidget {
  const StaffDirectoryScreen({super.key});

  static const _roleColors = <String, Color>{
    'admin': AppColors.primary,
    'manager': AppColors.success,
    'cashier': AppColors.gray600,
    'stock_clerk': AppColors.warning,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffDirectoryProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Staff Directory'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.loading
                ? null
                : () => ref.read(staffDirectoryProvider.notifier).load(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, StaffDirectoryState state) {
    if (!state.connected) {
      return _message(
        icon: Icons.cloud_off_outlined,
        text: 'Connect Xantara Cloud in Settings to browse the shared staff '
            'directory.',
      );
    }
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _message(
        icon: Icons.error_outline,
        text: state.error!,
        color: AppColors.error,
        action: TextButton(
          onPressed: () => ref.read(staffDirectoryProvider.notifier).load(),
          child: const Text('Retry'),
        ),
      );
    }
    if (state.staff.isEmpty) {
      return _message(icon: Icons.people_outline, text: 'No staff members yet.');
    }

    final unassigned =
        state.staff.where((s) => s.branchId == null).toList();
    final byBranch = <BranchInfo, List<StaffDirectoryEntry>>{
      for (final branch in state.branches)
        branch: state.staff.where((s) => s.branchId == branch.id).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        for (final entry in byBranch.entries)
          if (entry.value.isNotEmpty) _branchSection(entry.key.name, entry.value),
        if (unassigned.isNotEmpty) _branchSection('Unassigned', unassigned),
      ],
    );
  }

  Widget _branchSection(String branchName, List<StaffDirectoryEntry> members) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(branchName,
                  style: AppTextStyles.labelMd.copyWith(
                      fontSize: 13, color: AppColors.gray600)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppSizes.rPill),
                ),
                child: Text('${members.length}',
                    style: AppTextStyles.labelMd
                        .copyWith(fontSize: 11, color: AppColors.gray600)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.rCard),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < members.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.gray100, indent: AppSizes.lg),
                  _staffTile(members[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffTile(StaffDirectoryEntry s) {
    final roleColor = _roleColors[s.role] ?? AppColors.gray600;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Text(s.initials,
            style: AppTextStyles.labelMd
                .copyWith(color: AppColors.primary, fontSize: 12)),
      ),
      title: Text(s.name,
          style: AppTextStyles.bodyMd
              .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(s.email,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.gray400)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.rPill),
            ),
            child: Text(s.roleDisplay,
                style: AppTextStyles.labelMd.copyWith(fontSize: 11, color: roleColor)),
          ),
          const SizedBox(height: 4),
          Text(
            s.status == 'active' ? 'Active' : s.statusDisplay,
            style: AppTextStyles.caption.copyWith(
              color: s.status == 'active' ? AppColors.success : AppColors.gray400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String text,
    Color color = AppColors.gray400,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: AppSizes.md),
            Text(text, textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: color)),
            if (action != null) ...[const SizedBox(height: AppSizes.sm), action],
          ],
        ),
      ),
    );
  }
}
