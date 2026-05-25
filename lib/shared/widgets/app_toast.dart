import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum ToastType { success, warning, error }

void showAppToast(
  BuildContext context, {
  required String title,
  String? subtitle,
  ToastType type = ToastType.success,
}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AppToast(
      title: title,
      subtitle: subtitle,
      type: type,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}

class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.title,
    this.subtitle,
    required this.type,
    required this.onDismiss,
  });
  final String title;
  final String? subtitle;
  final ToastType type;
  final VoidCallback onDismiss;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _slide = Tween<Offset>(
            begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (widget.type) {
      ToastType.success => AppColors.success,
      ToastType.warning => AppColors.warning,
      ToastType.error   => AppColors.error,
    };
    final bg = switch (widget.type) {
      ToastType.success => AppColors.successLight,
      ToastType.warning => AppColors.warningLight,
      ToastType.error   => AppColors.errorLight,
    };
    final icon = switch (widget.type) {
      ToastType.success => Icons.check_circle_outline,
      ToastType.warning => Icons.warning_amber_outlined,
      ToastType.error   => Icons.error_outline,
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizes.sm,
      left: AppSizes.screenH,
      right: AppSizes.screenH,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      BorderRadius.circular(AppSizes.rCard),
                  border: Border(
                      left: BorderSide(color: borderColor, width: 3)),
                  boxShadow: AppShadows.md,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: borderColor, size: 18),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: borderColor,
                              )),
                          if (widget.subtitle != null)
                            Text(widget.subtitle!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: borderColor
                                      .withValues(alpha: 0.8),
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
