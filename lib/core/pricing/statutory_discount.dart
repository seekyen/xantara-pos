import '../compliance/bir_invoice.dart';
import 'commercial_discounts.dart';

enum BeneficiaryKind { senior, pwd }

enum StatutoryScheme { foodService, bnpc }

/// Explicitly reviewed catalog classifications. Fuel has additional periodic
/// limits and is deliberately not represented by a general BNPC classification.
enum BenefitProductKind {
  unclassified,
  excluded,
  preparedFood,
  rice,
  corn,
  bread,
  fish,
  meat,
  eggs,
  water,
  milk,
  vegetables,
  fruit,
  noodles,
  coffee,
  sugar,
  oil,
  salt,
  laundrySoap,
  firewood,
  charcoal,
  candles,
  flour,
  processedMeat,
  dairy,
  condiments,
  bathSoap,
  farmSupplies,
  schoolSupplies,
  constructionSupplies,
  batteries,
  electricalSupplies,
}

class StatutoryClaim {
  StatutoryClaim({
    required this.kind,
    required this.scheme,
    required String name,
    required String idNumber,
    required String idType,
    required this.identityVerified,
    required this.exclusiveUse,
    required this.personalPurchase,
    this.bookletChecked = false,
    this.priorWeekSpendCentavos = 0,
    this.priorWeekDiscountCentavos = 0,
    this.fourKindsConfirmed = false,
  })  : name = name.trim(),
        idNumber = idNumber.trim(),
        idType = idType.trim();
  final BeneficiaryKind kind;
  final StatutoryScheme scheme;
  final String name, idNumber, idType;
  final bool identityVerified, exclusiveUse, personalPurchase;
  final bool bookletChecked, fourKindsConfirmed;

  /// Total already used at ALL stores this calendar week, including this POS.
  final int priorWeekSpendCentavos;
  final int priorWeekDiscountCentavos;

  void validate() {
    for (final text in [name, idNumber, idType]) {
      if (text.isEmpty ||
          text.length > 200 ||
          RegExp(r'[\x00-\x1f\x7f]').hasMatch(text)) {
        throw ArgumentError(
            'Enter a valid beneficiary name, ID type and ID number.');
      }
    }
    if (!identityVerified || !exclusiveUse || !personalPurchase) {
      throw ArgumentError(
          'Verify entitlement and personal, exclusive consumption. Representative and shared orders require a separate supported process.');
    }
    if (scheme == StatutoryScheme.bnpc &&
        (!bookletChecked ||
            priorWeekSpendCentavos < 0 ||
            priorWeekSpendCentavos > 250000 ||
            priorWeekDiscountCentavos < 0 ||
            priorWeekDiscountCentavos > 12500)) {
      throw ArgumentError(
          'Check the purchase booklet and enter this week’s prior purchases (0 to PHP 2,500).');
    }
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'scheme': scheme.name,
        'name': name,
        'idNumber': idNumber,
        'idType': idType,
        'identityVerified': identityVerified,
        'exclusiveUse': exclusiveUse,
        'personalPurchase': personalPurchase,
        'bookletChecked': bookletChecked,
        'priorWeekSpendCentavos': priorWeekSpendCentavos,
        'priorWeekDiscountCentavos': priorWeekDiscountCentavos,
        'fourKindsConfirmed': fourKindsConfirmed,
      };
}

class StatutoryQuote {
  StatutoryQuote(this.lines, this.snapshot);
  final List<BirInvoiceLine> lines;
  final Map<String, dynamic> snapshot;
  int get totalCentavos => const BirInvoiceCalculator().total(lines);
  int get discountCentavos => lines.fold(0, (n, l) => n + l.discountCentavos);
  int get vatReliefCentavos => lines.fold(0, (n, l) => n + l.vatReliefCentavos);
}

StatutoryQuote calculateStatutoryDiscount(
    {required List<BirInvoiceLine> lines,
    required Map<String, BenefitProductKind> classifications,
    required StatutoryClaim claim,
    required TaxRegistrationType registration}) {
  claim.validate();
  if (lines.isEmpty ||
      lines.map((l) => l.productId).toSet().length != lines.length ||
      lines.any((l) =>
          l.validate().isNotEmpty ||
          l.discountCentavos != 0 ||
          l.vatReliefCentavos != 0)) {
    throw ArgumentError(
        'Use a valid basket without another discount or promotion.');
  }
  if (lines.any((l) => registration == TaxRegistrationType.nonVat
      ? l.taxCategory != TaxCategory.nonVat
      : l.taxCategory == TaxCategory.nonVat)) {
    throw ArgumentError(
        'Product tax categories do not match the seller registration.');
  }
  final eligible = <String, int>{};
  for (final line in lines) {
    final kind =
        classifications[line.productId] ?? BenefitProductKind.unclassified;
    if (kind == BenefitProductKind.unclassified) {
      throw StateError(
          'Classify ${line.description} in Senior/PWD settings before applying a benefit.');
    }
    final qualifies = claim.scheme == StatutoryScheme.foodService
        ? kind == BenefitProductKind.preparedFood
        : kind.index > BenefitProductKind.preparedFood.index;
    if (qualifies) eligible[line.productId] = line.grossCentavos;
  }
  if (eligible.isEmpty || eligible.values.every((v) => v == 0)) {
    throw StateError('There are no qualifying items in this basket.');
  }
  final grossEligible = eligible.values.fold(0, (a, b) => a + b);
  final bnpc = claim.scheme == StatutoryScheme.bnpc;
  final basis = bnpc
      ? grossEligible.clamp(0, 250000 - claim.priorWeekSpendCentavos)
      : grossEligible;
  if (basis == 0 || (bnpc && claim.priorWeekDiscountCentavos == 12500)) {
    throw StateError('The weekly BNPC purchase allowance is exhausted.');
  }
  if (bnpc &&
      basis + claim.priorWeekSpendCentavos == 250000 &&
      !claim.fourKindsConfirmed) {
    throw StateError(
        'Verify at least four qualifying kinds across the weekly purchases before using the full allowance.');
  }
  final bnpcDiscounts = bnpc
      ? allocateCommercialDiscount(
          eligible,
          ((basis * 5 + 50) ~/ 100)
              .clamp(0, 12500 - claim.priorWeekDiscountCentavos))
      : <String, int>{};
  final result = <BirInvoiceLine>[];
  final detail = <String, dynamic>{};
  for (final line in lines) {
    var relief = 0, discount = 0;
    var tax = line.taxCategory;
    if (eligible.containsKey(line.productId)) {
      if (bnpc) {
        discount = bnpcDiscounts[line.productId]!;
      } else {
        if (tax == TaxCategory.vat12) {
          final exclusive = (line.grossCentavos * 100 + 56) ~/ 112;
          relief = line.grossCentavos - exclusive;
        }
        discount = ((line.grossCentavos - relief) * 20 + 50) ~/ 100;
        tax = registration == TaxRegistrationType.vat
            ? TaxCategory.vatExempt
            : TaxCategory.nonVat;
      }
    }
    result.add(BirInvoiceLine(
        productId: line.productId,
        description: line.description,
        quantity: line.quantity,
        unitPriceCentavos: line.unitPriceCentavos,
        taxCategory: tax,
        discountCentavos: discount,
        vatReliefCentavos: relief));
    detail[line.productId] = {
      'classification': classifications[line.productId]!.name,
      'originalTaxCategory': line.taxCategory.name,
      'grossCentavos': line.grossCentavos,
      'vatReliefCentavos': relief,
      'discountCentavos': discount
    };
  }
  return StatutoryQuote(
      List.unmodifiable(result),
      Map.unmodifiable({
        'version': 1,
        'claim': claim.toJson(),
        'lines': detail,
        'eligiblePurchaseCentavos': basis,
        'discountCentavos':
            result.fold<int>(0, (n, l) => n + l.discountCentavos),
        'vatReliefCentavos':
            result.fold<int>(0, (n, l) => n + l.vatReliefCentavos),
        'rule': bnpc ? 'JAO24-02-2024' : 'RR7-2010/RR5-2017',
      }));
}
