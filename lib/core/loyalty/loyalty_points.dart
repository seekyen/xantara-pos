/// Loyalty points on the POS are only an ESTIMATE shown to the cashier and printed on the
/// receipt. Xantara Cloud awards the real points when the invoice syncs, using the same rule:
/// every `spend per point` of the sale, excluding VAT, earns one whole point, under the promo
/// running on the invoice date (if promos overlap, the one earning the most points wins).
library;

/// A promo period cached from Xantara Cloud. Dates are Manila calendar days (`yyyy-MM-dd`,
/// both inclusive) so they compare correctly as strings.
class LoyaltyPromoRule {
  const LoyaltyPromoRule({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.spendPerPointCentavos,
  });

  final String name;
  final String startDate;
  final String endDate;
  final int spendPerPointCentavos;

  bool runsOn(String day) =>
      day.compareTo(startDate) >= 0 && day.compareTo(endDate) <= 0;
}

class LoyaltyEstimate {
  const LoyaltyEstimate(this.points, this.promoName);

  static const none = LoyaltyEstimate(0, null);

  final int points;
  final String? promoName;
}

/// The Manila calendar day of an instant, which is the day the server uses to pick a promo
/// (Manila is UTC+8 all year, so no daylight-saving handling is needed).
String manilaDay(DateTime instant) {
  final manila = instant.toUtc().add(const Duration(hours: 8));
  String two(int value) => value.toString().padLeft(2, '0');
  return '${manila.year.toString().padLeft(4, '0')}-${two(manila.month)}-${two(manila.day)}';
}

/// Whole centavos from a decimal peso amount such as `"50"` or `"50.25"` (how the cloud sends
/// money). Returns null for anything else, so a malformed value never becomes a wrong rate.
int? pesosToCentavos(Object? value) {
  final text = '$value'.trim();
  final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(text);
  if (match == null) return null;
  final pesos = int.parse(match.group(1)!);
  final centavos = int.parse((match.group(2) ?? '').padRight(2, '0'));
  return pesos * 100 + centavos;
}

/// Points a sale of `netCentavos` (total less VAT) earns on `issuedAt`, and the promo that gives
/// them. [LoyaltyEstimate.none] when no running promo earns anything.
LoyaltyEstimate estimateLoyaltyPoints({
  required int netCentavos,
  required DateTime issuedAt,
  required Iterable<LoyaltyPromoRule> promos,
}) {
  if (netCentavos <= 0) return LoyaltyEstimate.none;
  final day = manilaDay(issuedAt);
  var best = LoyaltyEstimate.none;
  for (final promo in promos) {
    if (!promo.runsOn(day) || promo.spendPerPointCentavos <= 0) continue;
    final points = netCentavos ~/ promo.spendPerPointCentavos;
    if (points > best.points) best = LoyaltyEstimate(points, promo.name);
  }
  return best;
}
