import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum _BtnVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _BtnVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _BtnVariant.secondary;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _BtnVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final _BtnVariant _variant;

  @override
  Widget build(BuildContext context) {
    final bg = switch (_variant) {
      _BtnVariant.primary   => AppColors.primary,
      _BtnVariant.secondary => Colors.white,
      _BtnVariant.danger    => AppColors.error,
    };
    final fg = switch (_variant) {
      _BtnVariant.primary   => Colors.white,
      _BtnVariant.secondary => AppColors.primary,
      _BtnVariant.danger    => Colors.white,
    };
    final side = _variant == _BtnVariant.secondary
        ? const BorderSide(color: AppColors.primary)
        : BorderSide.none;

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rButton),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: fg),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: AppSizes.sm),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ],
                  )
                : Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
