import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/providers/checkout_provider.dart';
import '../../pos/fnb/providers/pos_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../pos/pos_mode_selector.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/widgets/bottom_tab_bar.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/status_banner.dart';

// ── Derived providers ─────────────────────────────────────────────────────────

final _paymentBreakdownProvider = Provider<Map<PaymentMethod, double>>((ref) {
  final orders = ref.watch(ordersProvider);
  final Map<PaymentMethod, double> breakdown = {};
  for (final rec in orders) {
    if (rec.isVoided) continue;
    breakdown.update(
      rec.order.paymentMethod,
      (v) => v + rec.order.total,
      ifAbsent: () => rec.order.total,
    );
  }
  return breakdown;
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productsProvider);
    final sync = ref.watch(syncProvider);
    final branch = retailBranchFor(ref.watch(activeBranchProvider));
    final paymentBreakdown = ref.watch(_paymentBreakdownProvider);

    final validOrders = orders.where((r) => !r.isVoided).toList();
    final netSales = validOrders.fold(0.0, (sum, r) => sum + r.order.total);
    final avgOrder =
        validOrders.isNotEmpty ? netSales / validOrders.length : 0.0;
    final lowStock = products.where((p) => p.stock <= 10).toList();

    final (syncLabel, syncTone) = switch (sync.status) {
      SyncStatus.synced => ('Synced', BannerTone.info),
      SyncStatus.complete => ('Synced', BannerTone.info),
      SyncStatus.syncing => ('Syncing…', BannerTone.warning),
      SyncStatus.offline => ('Offline — ${sync.queued} queued', BannerTone.warning),
    };

    return Scaffold(
      backgroundColor: AppColors.gray50,
      bottomNavigationBar: const BottomTabBar(currentIndex: 0),
      body: Column(
        children: [
          const OfflineBanner(),
          // ── Flat header ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                AppSizes.screenH,
                MediaQuery.of(context).padding.top + AppSizes.sm,
                AppSizes.screenH,
                AppSizes.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('X',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Xantara POS', style: AppTextStyles.titleMd),
                      Text('${branch.name} · ${roleLabelFor(user?.role)}',
                          style: AppTextStyles.labelSm),
                    ],
                  ),
                ),
                _SyncPill(text: syncLabel, tone: syncTone),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.gray600),
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.gray600),
                  tooltip: 'Logout',
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.gray100),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── "Today's overview" + actions ────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's overview",
                                style: AppTextStyles.displayMd),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEE, MMM d').format(DateTime.now()),
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.gray400),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Export — coming soon')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40)),
                        child: const Text('Export'),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => context.push('/pos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('+ New sale'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // ── Stat cards ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Net Sales',
                          value: '₱${NumberFormat('#,##0').format(netSales)}',
                          icon: Icons.payments_outlined,
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: StatCard(
                          label: 'Orders',
                          value: '${validOrders.length}',
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: StatCard(
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
                  const SizedBox(height: AppSizes.md),

                  // ── Sales trend + payment mix ───────────────────────
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth > 700;
                    final trend = _SalesTrendCard(todaySales: netSales);
                    final payments =
                        _PaymentMixCard(breakdown: paymentBreakdown);
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: trend),
                              const SizedBox(width: AppSizes.md),
                              Expanded(flex: 2, child: payments),
                            ],
                          )
                        : Column(children: [
                            trend,
                            const SizedBox(height: AppSizes.md),
                            payments,
                          ]);
                  }),
                  const SizedBox(height: AppSizes.lg),

                  // ── Quick actions ─────────────────────────────────
                  const Text('QUICK ACTIONS', style: AppTextStyles.labelCaps),
                  const SizedBox(height: AppSizes.sm),
                  _ActionButton(
                    icon: Icons.point_of_sale_rounded,
                    label: 'Open POS',
                    subtitle: 'Start processing orders',
                    iconColor: AppColors.primary,
                    onTap: () => openPos(context),
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
                  const SizedBox(height: AppSizes.sm),
                  _ActionButton(
                    icon: Icons.verified_user_outlined,
                    label: 'Test Improvements',
                    subtitle: 'Offline, BIR, branches, sync and hardware',
                    iconColor: AppColors.success,
                    onTap: () => context.push('/improvements'),
                  ),

                  // ── Low stock ─────────────────────────────────────
                  if (lowStock.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        const Text('LOW STOCK', style: AppTextStyles.labelCaps),
                        const SizedBox(width: AppSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(AppSizes.rPill),
                          ),
                          child: Text(
                            '${lowStock.length}',
                            style: AppTextStyles.labelSm.copyWith(
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
                        borderRadius: BorderRadius.circular(AppSizes.rCard),
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
                                    color: p.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.inventory_2_outlined,
                                      size: 16, color: p.color),
                                ),
                                title: Text(p.name,
                                    style: AppTextStyles.bodyMd
                                        .copyWith(fontWeight: FontWeight.w600)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: p.stock <= 5
                                        ? AppColors.errorLight
                                        : AppColors.warningLight,
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.rPill),
                                  ),
                                  child: Text(
                                    '${p.stock} left',
                                    style: AppTextStyles.labelSm.copyWith(
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
    );
  }
}

// ── Sync status pill ──────────────────────────────────────────────────────────
// Compact version of StatusBanner for use inside a Row — StatusBanner sets
// width: double.infinity internally, which crashes layout when placed
// directly in a Row (unbounded width constraint).

class _SyncPill extends StatelessWidget {
  const _SyncPill({required this.text, required this.tone});
  final String text;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BannerTone.warning => (AppColors.warningLight, AppColors.warning),
      BannerTone.info => (AppColors.primaryLight, AppColors.primary),
    };
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSizes.rPill)),
      child: Text(text, style: AppTextStyles.labelMd.copyWith(color: fg)),
    );
  }
}

// ── Sales trend card ──────────────────────────────────────────────────────────

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard({required this.todaySales});
  final double todaySales;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1;

    // Mock trend shape for days without real session data — same convention
    // used by AnalyticsScreen's _RevenueBarChart (today's real total always
    // wins where we have it).
    final mockValues = [
      32000.0,
      28500.0,
      41200.0,
      35800.0,
      29400.0,
      44100.0,
      38450.0,
    ];
    if (todaySales > 0) mockValues[todayIndex] = todaySales;
    final maxY = mockValues.reduce(math.max) * 1.25;

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
          const Text('Sales — last 7 days', style: AppTextStyles.titleSm),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                maxY: maxY,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = i == todayIndex;
                        return Text(
                          days[i],
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? AppColors.gray800
                                : AppColors.gray400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final isToday = i == todayIndex;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: mockValues[i],
                        color: isToday ? AppColors.primary : AppColors.gray200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        width: 22,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment mix card ──────────────────────────────────────────────────────────

class _PaymentMixCard extends StatelessWidget {
  const _PaymentMixCard({required this.breakdown});
  final Map<PaymentMethod, double> breakdown;

  Widget _row(String label, double value, double total, {bool live = true}) {
    final pct = total > 0 ? (value / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
              Text(
                live ? '$pct%' : '$pct% · not live',
                style: AppTextStyles.labelMd.copyWith(
                    color: live ? AppColors.gray800 : AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation(
                  live ? AppColors.primary : AppColors.gray400.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    final cash = breakdown[PaymentMethod.cash] ?? 0;
    final gcash = breakdown[PaymentMethod.gcash] ?? 0;
    final card = breakdown[PaymentMethod.card] ?? 0;

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
          const Text('Payment mix', style: AppTextStyles.titleSm),
          const SizedBox(height: AppSizes.md),
          _row('Cash', cash, total),
          _row('GCash', gcash, total, live: false),
          _row('Card', card, total, live: false),
          const SizedBox(height: AppSizes.xs),
          const StatusBanner(
            text: 'Requires a configured payment gateway',
            tone: BannerTone.warning,
          ),
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
                      style: AppTextStyles.titleSm.copyWith(fontSize: 14)),
                  Text(subtitle,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.gray400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray200, size: 20),
          ],
        ),
      ),
    );
  }
}
