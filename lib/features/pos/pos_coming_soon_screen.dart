import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import 'pos_mode_selector.dart';

/// Placeholder shown when a POS business mode is selected but its dedicated
/// UI hasn't been built yet (Retail, Restaurant).
class PosComingSoonScreen extends StatelessWidget {
  const PosComingSoonScreen({super.key, required this.mode});

  final PosBusinessMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(mode.label),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(mode.icon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('${mode.label} mode', style: AppTextStyles.titleMd),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Coming soon',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
