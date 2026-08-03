import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

enum StatTrend { up, down, neutral }

/// Shared stat-card component ("Refined Material" pass) — replaces the
/// per-screen re-implementations of boxed metrics. `icon`/`iconColor` are
/// an addition beyond the design preview so screens with an existing icon
/// identity per metric (e.g. the admin dashboard) don't lose it.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trendLabel,
    this.trend = StatTrend.neutral,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final String? trendLabel;
  final StatTrend trend;
  final IconData? icon;
  final Color? iconColor;

  Color get _trendColor => switch (trend) {
        StatTrend.up => AppColors.success,
        StatTrend.down => AppColors.error,
        StatTrend.neutral => AppColors.gray400,
      };

  String get _trendGlyph => switch (trend) {
        StatTrend.up => '▲',
        StatTrend.down => '▼',
        StatTrend.neutral => '',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.rInput),
              ),
              child: Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
          Text(label.toUpperCase(), style: AppTextStyles.labelCaps),
          const SizedBox(height: AppSizes.sm),
          Text(value, style: AppTextStyles.statNumber),
          if (trendLabel != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              '$_trendGlyph $trendLabel',
              style: AppTextStyles.labelMd.copyWith(color: _trendColor),
            ),
          ],
        ],
      ),
    );
  }
}
