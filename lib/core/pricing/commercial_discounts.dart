/// Commercial discounts only. This does not implement statutory SC/PWD rules.
/// Largest remainder allocation conserves centavos; ties use stable product IDs,
/// so reordering an otherwise identical mixed-tax basket cannot change its tax.
Map<String, int> allocateCommercialDiscount(
    Map<String, int> gross, int discount) {
  if (discount < 0 || gross.values.any((v) => v < 0)) {
    throw ArgumentError('Discount and line amounts cannot be negative.');
  }
  final total =
      gross.values.fold<BigInt>(BigInt.zero, (s, v) => s + BigInt.from(v));
  final amount = BigInt.from(discount);
  if (amount > total) throw ArgumentError('Discount exceeds the sale amount.');
  if (total == BigInt.zero) return {for (final id in gross.keys) id: 0};
  final allocated = <String, int>{};
  final remainders = <String, BigInt>{};
  for (final entry in gross.entries) {
    final product = BigInt.from(entry.value) * amount;
    allocated[entry.key] = (product ~/ total).toInt();
    remainders[entry.key] = product % total;
  }
  var left = discount - allocated.values.fold<int>(0, (s, v) => s + v);
  final ids = gross.keys.toList()
    ..sort((a, b) {
      final byRemainder = remainders[b]!.compareTo(remainders[a]!);
      return byRemainder == 0 ? a.compareTo(b) : byRemainder;
    });
  for (final id in ids) {
    if (left == 0) break;
    if (allocated[id]! < gross[id]!) {
      allocated[id] = allocated[id]! + 1;
      left--;
    }
  }
  return allocated;
}

/// Returns hundredths (centavos or basis points). Rejects exponent notation,
/// non-finite values and silently rounded fractional centavos.
int parseDiscountHundredths(String value) {
  final text = value.trim();
  if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) {
    throw ArgumentError(
        'Enter a non-negative discount with up to two decimal places.');
  }
  final parts = text.split('.');
  return int.parse(parts.first) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

int commercialDiscountAmount(int base, String input,
    {required bool percentage}) {
  if (percentage) {
    final text = input.trim();
    if (!RegExp(r'^\d{1,3}(\.\d{1,6})?$').hasMatch(text)) {
      throw ArgumentError(
          'Enter a percentage from 0 to 100 with up to six decimal places.');
    }
    final parts = text.split('.');
    final scale = BigInt.from(10).pow(parts.length == 1 ? 0 : parts[1].length);
    final numerator = BigInt.parse(parts.join());
    if (base < 0 || numerator > scale * BigInt.from(100)) {
      throw ArgumentError('Percentage must be from 0 to 100.');
    }
    final denominator = scale * BigInt.from(100);
    return ((BigInt.from(base) * numerator + denominator ~/ BigInt.two) ~/
            denominator)
        .toInt();
  }
  final value = parseDiscountHundredths(input);
  if (base < 0 || value > base) {
    throw ArgumentError(
        'Discount must be within the sale amount (percentage: 0 to 100).');
  }
  return value;
}
