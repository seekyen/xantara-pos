/// BIR-oriented invoice domain primitives.
///
/// Monetary values are stored as integer centavos. Do not use floating point
/// values for persisted financial records.
enum TaxRegistrationType { vat, nonVat }

enum TaxCategory { vat12, zeroRated, vatExempt, nonVat }

enum InvoiceStatus { issued, voided }

class BirSellerProfile {
  const BirSellerProfile({
    required this.registeredName,
    required this.tin,
    required this.branchCode,
    required this.registeredAddress,
    required this.registrationType,
    required this.machineIdentificationNumber,
    required this.permitToUseNumber,
    required this.machineSerialNumber,
    required this.softwareName,
    required this.softwareVersion,
  });

  final String registeredName;
  final String tin;
  final String branchCode;
  final String registeredAddress;
  final TaxRegistrationType registrationType;
  final String machineIdentificationNumber;
  final String permitToUseNumber;
  final String machineSerialNumber;
  final String softwareName;
  final String softwareVersion;

  List<String> validate() {
    final errors = <String>[];
    if (registeredName.trim().isEmpty) {
      errors.add('Registered name is required.');
    }
    if (tin.trim().isEmpty) errors.add('TIN is required.');
    if (branchCode.trim().isEmpty) errors.add('Branch code is required.');
    if (registeredAddress.trim().isEmpty) {
      errors.add('Registered address is required.');
    }
    if (machineIdentificationNumber.trim().isEmpty) {
      errors.add('Machine Identification Number (MIN) is required.');
    }
    if (permitToUseNumber.trim().isEmpty) {
      errors.add('Permit to Use (PTU) number is required.');
    }
    if (machineSerialNumber.trim().isEmpty) {
      errors.add('Machine serial number is required.');
    }
    if (softwareName.trim().isEmpty) errors.add('Software name is required.');
    if (softwareVersion.trim().isEmpty) {
      errors.add('Software version is required.');
    }
    return errors;
  }
}

class BirBuyerDetails {
  const BirBuyerDetails({
    required this.registeredName,
    this.tin,
    this.address,
  });

  final String registeredName;
  final String? tin;
  final String? address;
}

class BirInvoiceLine {
  const BirInvoiceLine({
    required this.productId,
    required this.description,
    required this.quantity,
    required this.unitPriceCentavos,
    required this.taxCategory,
    this.discountCentavos = 0,
  })  : assert(quantity > 0),
        assert(unitPriceCentavos >= 0),
        assert(discountCentavos >= 0);

  final String productId;
  final String description;
  final int quantity;
  final int unitPriceCentavos;
  final int discountCentavos;
  final TaxCategory taxCategory;

  int get grossCentavos => quantity * unitPriceCentavos;
  int get netCentavos => grossCentavos - discountCentavos;

  List<String> validate() {
    final errors = <String>[];
    if (productId.trim().isEmpty) errors.add('Product ID is required.');
    if (description.trim().isEmpty) errors.add('Item description is required.');
    if (quantity <= 0) errors.add('Quantity must be greater than zero.');
    if (unitPriceCentavos < 0) errors.add('Unit price cannot be negative.');
    if (discountCentavos < 0) errors.add('Discount cannot be negative.');
    if (discountCentavos > grossCentavos) {
      errors.add('Discount cannot exceed the line gross amount.');
    }
    return errors;
  }
}

class BirTaxSummary {
  const BirTaxSummary({
    required this.vatableSalesCentavos,
    required this.vatAmountCentavos,
    required this.zeroRatedSalesCentavos,
    required this.vatExemptSalesCentavos,
    required this.nonVatSalesCentavos,
  });

  final int vatableSalesCentavos;
  final int vatAmountCentavos;
  final int zeroRatedSalesCentavos;
  final int vatExemptSalesCentavos;
  final int nonVatSalesCentavos;
}

class BirInvoice {
  const BirInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.issuedAt,
    required this.seller,
    required this.lines,
    required this.taxSummary,
    required this.totalCentavos,
    required this.status,
    required this.paymentReference,
    this.buyer,
    this.voidedAt,
    this.voidReason,
    this.originalInvoiceId,
  });

  final String id;
  final String invoiceNumber;
  final DateTime issuedAt;
  final BirSellerProfile seller;
  final BirBuyerDetails? buyer;
  final List<BirInvoiceLine> lines;
  final BirTaxSummary taxSummary;
  final int totalCentavos;
  final InvoiceStatus status;
  final String paymentReference;
  final DateTime? voidedAt;
  final String? voidReason;
  final String? originalInvoiceId;

  BirInvoice voidInvoice({
    required DateTime at,
    required String reason,
  }) {
    if (status == InvoiceStatus.voided) {
      throw StateError('Invoice is already voided.');
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Void reason is required.');
    }
    return BirInvoice(
      id: id,
      invoiceNumber: invoiceNumber,
      issuedAt: issuedAt,
      seller: seller,
      buyer: buyer,
      lines: lines,
      taxSummary: taxSummary,
      totalCentavos: totalCentavos,
      status: InvoiceStatus.voided,
      paymentReference: paymentReference,
      voidedAt: at,
      voidReason: reason.trim(),
      originalInvoiceId: originalInvoiceId,
    );
  }
}

class BirInvoiceCalculator {
  const BirInvoiceCalculator({this.vatRateBasisPoints = 1200});

  /// 1200 basis points means 12% VAT.
  final int vatRateBasisPoints;

  BirTaxSummary summarize(List<BirInvoiceLine> lines) {
    var vatable = 0;
    var vat = 0;
    var zeroRated = 0;
    var exempt = 0;
    var nonVat = 0;

    for (final line in lines) {
      final amount = line.netCentavos;
      switch (line.taxCategory) {
        case TaxCategory.vat12:
          // Retail prices are VAT-inclusive. Round to the nearest centavo.
          final base = _divideRounded(
            amount * 10000,
            10000 + vatRateBasisPoints,
          );
          vatable += base;
          vat += amount - base;
          break;
        case TaxCategory.zeroRated:
          zeroRated += amount;
          break;
        case TaxCategory.vatExempt:
          exempt += amount;
          break;
        case TaxCategory.nonVat:
          nonVat += amount;
          break;
      }
    }

    return BirTaxSummary(
      vatableSalesCentavos: vatable,
      vatAmountCentavos: vat,
      zeroRatedSalesCentavos: zeroRated,
      vatExemptSalesCentavos: exempt,
      nonVatSalesCentavos: nonVat,
    );
  }

  int total(List<BirInvoiceLine> lines) =>
      lines.fold(0, (sum, line) => sum + line.netCentavos);

  int _divideRounded(int numerator, int denominator) =>
      (numerator + denominator ~/ 2) ~/ denominator;
}

class BirInvoiceIssuer {
  const BirInvoiceIssuer({this.calculator = const BirInvoiceCalculator()});

  final BirInvoiceCalculator calculator;

  BirInvoice issue({
    required String id,
    required DateTime issuedAt,
    required BirSellerProfile seller,
    required List<BirInvoiceLine> lines,
    required BirInvoiceSequence sequence,
    required String paymentReference,
    BirBuyerDetails? buyer,
  }) {
    final errors = <String>[
      ...seller.validate(),
      for (final line in lines) ...line.validate(),
    ];
    if (id.trim().isEmpty) errors.add('Invoice ID is required.');
    if (lines.isEmpty) errors.add('At least one invoice line is required.');
    if (paymentReference.trim().isEmpty) {
      errors.add('Payment reference is required.');
    }
    if (seller.registrationType == TaxRegistrationType.vat &&
        lines.any((line) => line.taxCategory == TaxCategory.nonVat)) {
      errors.add('A VAT seller cannot issue a non-VAT invoice line.');
    }
    if (seller.registrationType == TaxRegistrationType.nonVat &&
        lines.any((line) => line.taxCategory != TaxCategory.nonVat)) {
      errors.add('A non-VAT seller can only issue non-VAT invoice lines.');
    }
    if (errors.isNotEmpty) throw BirInvoiceValidationException(errors);

    final immutableLines = List<BirInvoiceLine>.unmodifiable(lines);
    final total = calculator.total(immutableLines);
    if (total <= 0) {
      throw const BirInvoiceValidationException([
        'Invoice total must be greater than zero.',
      ]);
    }

    return BirInvoice(
      id: id.trim(),
      invoiceNumber: sequence.allocate(),
      issuedAt: issuedAt,
      seller: seller,
      buyer: buyer,
      lines: immutableLines,
      taxSummary: calculator.summarize(immutableLines),
      totalCentavos: total,
      status: InvoiceStatus.issued,
      paymentReference: paymentReference.trim(),
    );
  }
}

class BirInvoiceValidationException implements Exception {
  const BirInvoiceValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'Invalid BIR invoice: ${errors.join(' ')}';
}

/// Allocates a monotonic series scoped to a registered branch and terminal.
///
/// The caller must persist [nextSequence] transactionally with the invoice.
/// Cloud sync must never renumber an invoice issued offline.
class BirInvoiceSequence {
  BirInvoiceSequence({
    required this.branchCode,
    required this.terminalCode,
    required int nextSequence,
    this.minimumDigits = 8,
  }) : _nextSequence = nextSequence {
    if (nextSequence < 1) {
      throw ArgumentError.value(nextSequence, 'nextSequence');
    }
  }

  final String branchCode;
  final String terminalCode;
  final int minimumDigits;
  int _nextSequence;

  int get nextSequence => _nextSequence;

  String allocate() {
    if (branchCode.trim().isEmpty || terminalCode.trim().isEmpty) {
      throw StateError('Branch and terminal codes are required.');
    }
    final serial = _nextSequence.toString().padLeft(minimumDigits, '0');
    _nextSequence++;
    return '${branchCode.trim()}-${terminalCode.trim()}-$serial';
  }
}
