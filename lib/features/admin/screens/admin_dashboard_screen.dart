import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/providers/pos_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/bottom_tab_bar.dart';
import '../../../shared/widgets/offline_banner.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productsProvider);

    final validOrders = orders.where((r) => !r.isVoided).toList();
    final netSales =
        validOrders.fold(0.0, (sum, r) => sum + r.order.total);
    final avgOrder =
        validOrders.isNotEmpty ? netSales / validOrders.length : 0.0;
    final lowStock = products.where((p) => p.stock <= 10).toList();

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.gray50,
      bottomNavigationBar: const BottomTabBar(currentIndex: 0),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Gradient header ────────────────────────────────────
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
                      icon:
                          const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
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
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.screenH,
                          56,
                          AppSizes.screenH,
                          AppSizes.lg),
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
                            user?.name ?? 'Admin',
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
                        // ── Today's stats ─────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Net Sales',
                                value:
                                    '₱${NumberFormat('#,##0').format(netSales)}',
                                icon: Icons.payments_outlined,
                                iconColor: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: _StatCard(
                                label: 'Orders',
                                value: '${validOrders.length}',
                                icon: Icons.receipt_long_outlined,
                                iconColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: _StatCard(
                                label: 'Avg Order',
                                value: validOrders.isNotEmpty
                                    ? '₱${NumberFormat('#,##0').format(avgOrder)}'
                                    : '₱0',
                                icon: Icons.trending_up,
                                iconColor: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // ── Quick actions ─────────────────────────────
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
                          onTap: () => context.push('/pos'),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _ActionButton(
                          icon: Icons.history_rounded,
                          label: 'Order History',
                          subtitle:
                              '${validOrders.length} order${validOrders.length != 1 ? 's' : ''} today',
                          iconColor: AppColors.gray600,
                          onTap: () => context.push('/orders'),
                        ),

                        // ── Low stock ─────────────────────────────────
                        if (lowStock.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.lg),
                          Row(
                            children: [
                              const Text(
                                'LOW STOCK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.gray400,
                                ),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.rPill),
                                ),
                                child: Text(
                                  '${lowStock.length}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.rCard),
                              boxShadow: AppShadows.sm,
                            ),
                            child: Column(
                              children: lowStock.asMap().entries.map((e) {
                                final p = e.value;
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: p.color
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 16,
                                            color: p.color),
                                      ),
                                      title: Text(p.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.gray800)),
                                      trailing: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: p.stock <= 5
                                              ? AppColors.errorLight
                                              : AppColors.warningLight,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppSizes.rPill),
                                        ),
                                        child: Text(
                                          '${p.stock} left',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: p.stock <= 5
                                                ? AppColors.error
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (e.key < lowStock.length - 1)
                                      const Divider(
                                          height: 1,
                                          color: AppColors.gray100,
                                          indent: AppSizes.lg),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSizes.xl),
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

// ── Stat card ──────────────────────────────────────────────────────────────────

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

// ── Action button ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.gray400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.gray200, size: 20),
          ],
        ),
      ),
    );
  }
}
