import 'package:flutter/material.dart';
import '../theme/xantara_theme.dart';
import '../widgets/stat_card.dart';

/// Admin dashboard — option 1a ("Refined Material"). Same information
/// architecture as today (net sales / orders / avg order, 7-day trend,
/// payment mix) rebuilt on the shared StatCard/StatusBanner components and
/// the named type scale instead of inline font sizes.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XantaraColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: XantaraSpacing.xl,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: XantaraColors.primary, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: const Text('X', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: XantaraSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xantara POS', style: XantaraType.titleMd),
                Text('Main Branch · Admin', style: XantaraType.labelSm),
              ],
            ),
          ],
        ),
        actions: [
          const StatusBanner(text: 'Premium — sync offline', tone: BannerTone.info),
          const SizedBox(width: XantaraSpacing.xl),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(XantaraSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's overview", style: XantaraType.displayMd),
                    const SizedBox(height: 2),
                    Text('Tue, Jul 7 · updated 2 min ago', style: XantaraType.bodySm.copyWith(color: XantaraColors.gray400)),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)), child: const Text('Export')),
                    const SizedBox(width: XantaraSpacing.sm),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)), child: const Text('+ New sale')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: XantaraSpacing.xl),

            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 700;
              final cards = const [
                StatCard(label: 'Net sales', value: '₱18,420', trendLabel: '12.4% vs yesterday', trend: StatTrend.up),
                StatCard(label: 'Orders', value: '142', trendLabel: '6 vs yesterday', trend: StatTrend.up),
                StatCard(label: 'Avg order', value: '₱129.70', trendLabel: '2.1% vs yesterday', trend: StatTrend.down),
              ];
              return wide
                  ? Row(children: [for (final c in cards) Expanded(child: Padding(padding: const EdgeInsets.only(right: XantaraSpacing.md), child: c))])
                  : Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: XantaraSpacing.md), child: c)]);
            }),
            const SizedBox(height: XantaraSpacing.md),

            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 700;
              final trend = _SalesTrendCard();
              final payments = _PaymentMixCard();
              return wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 3, child: trend),
                      const SizedBox(width: XantaraSpacing.md),
                      Expanded(flex: 2, child: payments),
                    ])
                  : Column(children: [trend, const SizedBox(height: XantaraSpacing.md), payments]);
            }),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
        ],
      ),
    );
  }
}

class _SalesTrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(XantaraSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(XantaraRadius.card),
        border: Border.all(color: XantaraColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales — last 7 days', style: XantaraType.titleSm),
          const SizedBox(height: XantaraSpacing.md),
          SizedBox(
            height: 140,
            child: CustomPaint(painter: _SparklinePainter(), size: const Size(double.infinity, 140)),
          ),
          const SizedBox(height: XantaraSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
              Text(d, style: XantaraType.labelSm)],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = const [0.78, 0.64, 0.71, 0.43, 0.54, 0.29, 0.39, 0.14];
    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = XantaraColors.primary.withValues(alpha: 0.08));
    canvas.drawPath(
      path,
      Paint()
        ..color = XantaraColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentMixCard extends StatelessWidget {
  Widget _row(String label, int pct, {bool live = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: XantaraSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: XantaraType.bodyMd.copyWith(color: XantaraColors.gray600)),
              Text(
                live ? '$pct%' : '$pct% · not live',
                style: XantaraType.labelMd.copyWith(color: live ? XantaraColors.gray900 : XantaraColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: XantaraColors.gray100,
              valueColor: AlwaysStoppedAnimation(live ? XantaraColors.primary : XantaraColors.gray400.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(XantaraSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(XantaraRadius.card),
        border: Border.all(color: XantaraColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment mix', style: XantaraType.titleSm),
          const SizedBox(height: XantaraSpacing.md),
          _row('Cash', 78),
          _row('GCash', 18, live: false),
          _row('Card', 4, live: false),
          const SizedBox(height: XantaraSpacing.xs),
          const StatusBanner(text: 'Requires a configured payment gateway', tone: BannerTone.warning),
        ],
      ),
    );
  }
}
