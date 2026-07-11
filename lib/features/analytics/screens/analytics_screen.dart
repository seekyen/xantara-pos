import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/providers/orders_provider.dart';
import '../../checkout/providers/checkout_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/bottom_tab_bar.dart';

// ── Derived providers ─────────────────────────────────────────────────────────

final _netSalesProvider = Provider<double>((ref) {
  return ref
      .watch(ordersProvider)
      .where((r) => !r.isVoided)
      .fold(0.0, (sum, r) => sum + r.order.total);
});

final _transactionCountProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider).where((r) => !r.isVoided).length;
});

final _topProductsProvider =
    Provider<List<({String name, double revenue})>>((ref) {
  final orders = ref.watch(ordersProvider);
  final Map<String, double> rev = {};
  for (final rec in orders) {
    if (rec.isVoided) continue;
    for (final item in rec.order.items) {
      rev.update(
        item.name,
        (v) => v + item.subtotal,
        ifAbsent: () => item.subtotal,
      );
    }
  }
  final sorted = rev.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(5).map((e) => (name: e.key, revenue: e.value)).toList();
});

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

// ── Screen ────────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _period = 'Today';

  @override
  Widget build(BuildContext context) {
    final netSales = ref.watch(_netSalesProvider);
    final txnCount = ref.watch(_transactionCountProvider);
    final topProducts = ref.watch(_topProductsProvider);
    final paymentBreakdown = ref.watch(_paymentBreakdownProvider);

    // Scale displayed values based on period (mock multipliers for Week/Month)
    final multiplier = _period == 'Today'
        ? 1.0
        : _period == 'Week'
            ? 7.0
            : 30.0;
    final displayedSales =
        netSales > 0 ? netSales * multiplier : 38450.0 * multiplier / 7;
    final displayedTxn = txnCount > 0 ? (txnCount * multiplier).round() : 47;
    final displayedAvg =
        displayedTxn > 0 ? (displayedSales / displayedTxn) : 817.0;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      bottomNavigationBar: const BottomTabBar(currentIndex: 1, isDark: true),
      body: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          _AnalyticsHeader(
            period: _period,
            onPeriodChanged: (p) => setState(() => _period = p),
            netSales: displayedSales,
            netSalesRef: netSales,
          ),

          // ── Light body ───────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.screenH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.sm),

                    // Stat cards
                    _StatCardsRow(
                      txnCount: displayedTxn,
                      avgBasket: displayedAvg,
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Top products
                    _WhiteCard(
                      child: _TopProducts(products: topProducts),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Payment breakdown
                    _WhiteCard(
                      child: _PaymentBreakdown(
                        breakdown: paymentBreakdown,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Analytics header ──────────────────────────────────────────────────────────

class _AnalyticsHeader extends ConsumerWidget {
  const _AnalyticsHeader({
    required this.period,
    required this.onPeriodChanged,
    required this.netSales,
    required this.netSalesRef,
  });

  final String period;
  final ValueChanged<String> onPeriodChanged;
  final double netSales;
  final double netSalesRef;

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '₱${(value / 1000).toStringAsFixed(1)}k';
    }
    return '₱${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.darkBg,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Analytics" pill — centered top
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Analytics',
                style: AppTextStyles.labelMd
                    .copyWith(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // "Reports" + period pills
          Row(
            children: [
              Text('Reports',
                  style: AppTextStyles.statNumber.copyWith(color: Colors.white)),
              const Spacer(),
              _PeriodPill(
                label: 'Today',
                active: period == 'Today',
                onTap: () => onPeriodChanged('Today'),
              ),
              _PeriodPill(
                label: 'Week',
                active: period == 'Week',
                onTap: () => onPeriodChanged('Week'),
              ),
              _PeriodPill(
                label: 'Month',
                active: period == 'Month',
                onTap: () => onPeriodChanged('Month'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hero number
          Text(_formatCurrency(netSales), style: AppTextStyles.heroNumber),
          const SizedBox(height: 2),
          Text(
            'Net sales · ${netSalesRef > 0 ? '+${netSalesRef.toStringAsFixed(0)}' : '+12%'} vs yesterday',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.whiteOverlay60),
          ),
          const SizedBox(height: 16),

          // Bar chart
          _RevenueBarChart(height: 70, todaySales: netSalesRef),
        ],
      ),
    );
  }
}

// ── Period pill ───────────────────────────────────────────────────────────────

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            fontSize: 10,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

// ── Revenue bar chart ─────────────────────────────────────────────────────────

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({required this.height, required this.todaySales});

  final double height;
  final double todaySales;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon, 6=Sun

    final mockValues = [
      32000.0,
      28500.0,
      41200.0,
      35800.0,
      29400.0,
      44100.0,
      38450.0
    ];
    if (todaySales > 0) mockValues[todayIndex] = todaySales;
    final maxY = mockValues.reduce(math.max) * 1.25;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          maxY: maxY,
          titlesData: FlTitlesData(
            show: true,
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 18,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = i == todayIndex;
                  return Text(
                    days[i],
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
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
                  color: isToday
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.2),
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
    );
  }
}

// ── Stat cards row ────────────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.txnCount,
    required this.avgBasket,
  });

  final int txnCount;
  final double avgBasket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: '$txnCount',
            sub: '+8 vs yesterday',
            subColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Avg. basket',
            value: '₱${avgBasket.toStringAsFixed(0)}',
            sub: '−₱42 vs yesterday',
            subColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  final String label;
  final String value;
  final String sub;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.statNumber),
          const SizedBox(height: 2),
          Text(sub, style: AppTextStyles.caption.copyWith(color: subColor)),
        ],
      ),
    );
  }
}

// ── White card wrapper ────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        border: Border.all(color: AppColors.gray100),
      ),
      child: child,
    );
  }
}

// ── Top products ──────────────────────────────────────────────────────────────

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products});

  final List<({String name, double revenue})> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Products',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (products.isEmpty)
          Text('No orders yet',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray400))
        else
          ...products.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(p.name, style: AppTextStyles.body)),
                  Text(
                    '₱${p.revenue.toStringAsFixed(2)}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Payment breakdown ─────────────────────────────────────────────────────────

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.breakdown});

  final Map<PaymentMethod, double> breakdown;

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    final cashTotal = breakdown[PaymentMethod.cash] ?? 0;
    final digitalTotal = breakdown.entries
        .where((entry) => entry.key != PaymentMethod.cash)
        .fold(0.0, (sum, entry) => sum + entry.value);

    final cashPct = total > 0 ? (cashTotal / total * 100).round() : 50;
    final digitalPct = total > 0 ? (digitalTotal / total * 100).round() : 50;
    final cashFlex =
        total > 0 ? (cashTotal / total * 10).round().clamp(1, 9) : 5;
    final digitalFlex = 10 - cashFlex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Breakdown',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: cashFlex,
                  child: Container(color: AppColors.success),
                ),
                Expanded(
                  flex: digitalFlex,
                  child: Container(color: AppColors.gcash),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendItem(color: AppColors.success, label: 'Cash $cashPct%'),
            const SizedBox(width: 14),
            _LegendItem(color: AppColors.gcash, label: 'Digital $digitalPct%'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
