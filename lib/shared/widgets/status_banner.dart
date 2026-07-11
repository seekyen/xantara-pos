import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

enum BannerTone { warning, info }

/// Shared status/compliance banner ("Refined Material" pass) — replaces ad
/// hoc `Container`s used for the training-invoice notice, credential
/// hints, etc. `info` reuses the brand primary color; there's no dedicated
/// "info" pair in [AppColors] and one isn't worth adding for a single tone.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.text,
    this.tone = BannerTone.info,
  });

  final String text;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BannerTone.warning => (AppColors.warningLight, AppColors.warning),
      BannerTone.info => (AppColors.primaryLight, AppColors.primary),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.rInput),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelMd.copyWith(color: fg),
      ),
    );
  }
}
