import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/network/connectivity.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectivityProvider);
    final isOffline = conn.when(
      data: (online) => !online,
      loading: () => false,
      error: (_, __) => true,
    );
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.sm),
      color: AppColors.warningLight,
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 15, color: AppColors.warning),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Text(
              'No internet · Working offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
