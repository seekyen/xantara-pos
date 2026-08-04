import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

enum PosBusinessMode {
  fnb('Food & Beverage', 'Current POS design', Icons.restaurant_rounded),
  retail('Retail', 'Grocery / barcode scan', Icons.storefront_rounded),
  restaurant('Restaurant', 'Coming soon', Icons.table_bar_rounded);

  const PosBusinessMode(this.label, this.subtitle, this.icon);

  final String label;
  final String subtitle;
  final IconData icon;
}

/// Lets the user pick which business-type POS to open. Returns the chosen
/// mode, or null if dismissed.
Future<PosBusinessMode?> showPosModeSelectorDialog(BuildContext context) {
  return showDialog<PosBusinessMode>(
    context: context,
    builder: (_) => const _PosModeSelectorDialog(),
  );
}

/// Shows the mode selector and navigates to the matching POS screen (or the
/// coming-soon placeholder for modes without a dedicated UI yet).
Future<void> openPos(BuildContext context) async {
  final mode = await showPosModeSelectorDialog(context);
  if (mode == null || !context.mounted) return;
  switch (mode) {
    case PosBusinessMode.fnb:
      context.push('/pos');
    case PosBusinessMode.retail:
      context.push('/pos/retail');
    case PosBusinessMode.restaurant:
      context.push('/pos/coming-soon', extra: mode);
  }
}

class _PosModeSelectorDialog extends StatelessWidget {
  const _PosModeSelectorDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose POS Mode', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Select the business type for this order.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: AppSizes.lg),
            for (final mode in PosBusinessMode.values) ...[
              _ModeOption(mode: mode),
              if (mode != PosBusinessMode.values.last)
                const SizedBox(height: AppSizes.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.mode});

  final PosBusinessMode mode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.rCard),
      onTap: () => Navigator.pop(context, mode),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.rCard),
              ),
              child: Icon(mode.icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.label, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(mode.subtitle,
                      style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }
}
