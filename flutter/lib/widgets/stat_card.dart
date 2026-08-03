import 'package:flutter/material.dart';
import '../theme/xantara_theme.dart';

enum StatTrend { up, down, neutral }

/// Shared stat-card component — replaces the per-screen re-implementations
/// (_Section/_Check/_Notice variants) called out in the design review.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trendLabel,
    this.trend = StatTrend.neutral,
  });

  final String label;
  final String value;
  final String? trendLabel;
  final StatTrend trend;

  Color get _trendColor => switch (trend) {
        StatTrend.up => XantaraColors.success,
        StatTrend.down => XantaraColors.error,
        StatTrend.neutral => XantaraColors.gray400,
      };

  String get _trendGlyph => switch (trend) {
        StatTrend.up => '▲',
        StatTrend.down => '▼',
        StatTrend.neutral => '',
      };

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
          Text(label.toUpperCase(), style: XantaraType.labelCaps),
          const SizedBox(height: XantaraSpacing.sm),
          Text(value, style: XantaraType.statNumber),
          if (trendLabel != null) ...[
            const SizedBox(height: XantaraSpacing.xs),
            Text(
              '$_trendGlyph $trendLabel',
              style: XantaraType.labelMd.copyWith(color: _trendColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small status/compliance banner — a proper component for the training
/// banner, "gateway not configured" notice, etc. instead of ad hoc Containers.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.text, this.tone = BannerTone.warning});

  final String text;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BannerTone.warning => (XantaraColors.warningBg, XantaraColors.warning),
      BannerTone.info => (XantaraColors.primaryLight, XantaraColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: XantaraSpacing.md, vertical: XantaraSpacing.sm),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(XantaraRadius.input)),
      child: Text(text, style: XantaraType.labelMd.copyWith(color: fg)),
    );
  }
}

enum BannerTone { warning, info }
