import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../providers/sync_provider.dart';

class SyncStatusPill extends StatefulWidget {
  const SyncStatusPill({super.key, required this.state});
  final SyncState state;

  @override
  State<SyncStatusPill> createState() => _SyncStatusPillState();
}

class _SyncStatusPillState extends State<SyncStatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.status;

    final bg = switch (s) {
      SyncStatus.synced   => AppColors.successLight,
      SyncStatus.complete => AppColors.successLight,
      SyncStatus.syncing  => AppColors.warningLight,
      SyncStatus.offline  => AppColors.errorLight,
    };
    final dotColor = switch (s) {
      SyncStatus.synced   => AppColors.success,
      SyncStatus.complete => AppColors.success,
      SyncStatus.syncing  => AppColors.warning,
      SyncStatus.offline  => AppColors.error,
    };
    final label = switch (s) {
      SyncStatus.synced   => 'Synced',
      SyncStatus.complete =>
        'Sync complete · ${widget.state.queued} uploaded',
      SyncStatus.syncing  => 'Syncing…',
      SyncStatus.offline  =>
        'Offline · ${widget.state.queued} queued',
    };

    final isBlinking =
        s == SyncStatus.syncing || s == SyncStatus.offline;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isBlinking
              ? FadeTransition(
                  opacity: _blink,
                  child: _Dot(color: dotColor),
                )
              : _Dot(color: dotColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
