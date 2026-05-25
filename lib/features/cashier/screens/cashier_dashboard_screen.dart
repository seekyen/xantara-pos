import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/providers/cart_provider.dart';
import '../providers/shift_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/offline_banner.dart';

class CashierDashboardScreen extends ConsumerWidget {
  const CashierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final shift = ref.watch(shiftProvider);
    final shiftOrders = ref.watch(shiftOrdersProvider);
    final shiftSales = ref.watch(shiftSalesProvider);
    final validOrders = shiftOrders.where((r) => !r.isVoided).length;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Gradient header ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  surfaceTintColor: Colors.transparent,
                  leading: const SizedBox.shrink(),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                      tooltip: 'Settings',
                      onPressed: () => context.push('/settings'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                        ref.read(cartProvider.notifier).clear();
                        ref.read(shiftProvider.notifier).reset();
                        context.go('/login');
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.screenH, 56, AppSizes.screenH, AppSizes.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Cashier',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy')
                                .format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.screenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Shift card ─────────────────────────────────
                        _ShiftCard(shift: shift),
                        const SizedBox(height: AppSizes.lg),

                        // ── Stats ──────────────────────────────────────
                        if (shift.isClockedIn) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Total Sales',
                                  value:
                                      '₱${NumberFormat('#,##0.00').format(shiftSales)}',
                                  icon: Icons.payments_outlined,
                                  iconColor: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: _StatCard(
                                  label: 'Orders',
                                  value: '$validOrders',
                                  icon: Icons.receipt_long_outlined,
                                  iconColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: _StatCard(
                                  label: 'Avg Order',
                                  value: validOrders > 0
                                      ? '₱${NumberFormat('#,##0').format(shiftSales / validOrders)}'
                                      : '₱0',
                                  icon: Icons.trending_up,
                                  iconColor: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],

                        // ── Quick actions label ─────────────────────────
                        const Text(
                          'QUICK ACTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),

                        _ActionButton(
                          icon: Icons.point_of_sale_rounded,
                          label: 'Open POS',
                          subtitle: 'Start processing orders',
                          iconColor: AppColors.primary,
                          enabled: shift.isClockedIn,
                          disabledReason:
                              'Clock in first to use the POS',
                          onTap: () => context.push('/pos'),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _ActionButton(
                          icon: Icons.history_rounded,
                          label: 'Order History',
                          subtitle:
                              '${shiftOrders.length} order${shiftOrders.length != 1 ? 's' : ''} this shift',
                          iconColor: AppColors.gray600,
                          enabled: true,
                          onTap: () => context.push('/orders'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shift card ─────────────────────────────────────────────────────────────────

class _ShiftCard extends ConsumerWidget {
  const _ShiftCard({required this.shift});
  final ShiftState shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: AppSizes.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppSizes.rPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: shift.isClockedIn
                        ? const Color(0xFF4ADE80)
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  shift.isClockedIn ? 'ON SHIFT' : 'OFF SHIFT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          if (shift.isClockedIn && shift.clockInTime != null) ...[
            Text('Clocked in at',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              DateFormat('hh:mm a').format(shift.clockInTime!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Duration: ${shift.formattedDuration}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12),
            ),
          ] else ...[
            const Text(
              'You are not clocked in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Clock in to start your shift',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12),
            ),
          ],

          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () => shift.isClockedIn
                  ? _confirmClockOut(context, ref)
                  : ref.read(shiftProvider.notifier).clockIn(),
              icon: Icon(
                  shift.isClockedIn ? Icons.logout : Icons.login,
                  size: 18),
              label: Text(
                  shift.isClockedIn ? 'Clock Out' : 'Clock In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.rButton)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClockOut(BuildContext context, WidgetRef ref) {
    final sales = ref.read(shiftSalesProvider);
    final orders =
        ref.read(shiftOrdersProvider).where((r) => !r.isVoided).length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clock Out'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shift Summary',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: AppSizes.md),
            _SummaryRow('Orders Processed', '$orders'),
            _SummaryRow('Total Sales',
                '₱${NumberFormat('#,##0.00').format(sales)}'),
            _SummaryRow('Duration',
                ref.read(shiftProvider).formattedDuration),
            const SizedBox(height: AppSizes.md),
            const Text('Are you sure you want to clock out?',
                style:
                    TextStyle(color: AppColors.gray600, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(shiftProvider.notifier).clockOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rButton)),
            ),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.gray600, fontSize: 13)),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.gray400)),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.enabled,
    required this.onTap,
    this.disabledReason,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final bool enabled;
  final VoidCallback onTap;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled
            ? onTap
            : () {
                if (disabledReason != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(disabledReason!),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.rCard)),
                  ));
                }
              },
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCardLg),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.rCard),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.gray200, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
