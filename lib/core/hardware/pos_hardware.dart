import '../compliance/bir_invoice.dart';
import '../payments/payment.dart';

enum HardwareJobType { printInvoice, openCashDrawer }

enum HardwareJobStatus { queued, processing, completed, failed }

class ReceiptPrintData {
  const ReceiptPrintData({
    required this.invoice,
    required this.payment,
    required this.cashierName,
    required this.isReprint,
    this.reprintedAt,
    this.loyaltyCustomerName,
    this.loyaltyEstimatedPoints = 0,
  });

  final BirInvoice invoice;
  final PaymentEvidence payment;
  final String cashierName;
  final bool isReprint;
  final DateTime? reprintedAt;

  /// The customer the sale was attached to and the points the POS estimated for it (the cloud
  /// confirms the final amount when the invoice syncs).
  final String? loyaltyCustomerName;
  final int loyaltyEstimatedPoints;
}

class BirReceiptFormatter {
  const BirReceiptFormatter({this.lineWidth = 42});

  final int lineWidth;

  String format(ReceiptPrintData data) {
    final invoice = data.invoice;
    final seller = invoice.seller;
    final buffer = StringBuffer();
    if (seller.machineIdentificationNumber.startsWith('TRAINING-')) {
      buffer.writeln(_center('TRAINING - NOT A SALES INVOICE'));
      buffer.writeln(_line());
    }
    if (data.isReprint) {
      buffer.writeln(_center('REPRINT ONLY'));
      buffer.writeln(_line());
    }
    buffer.writeln(_center(seller.registeredName));
    buffer.writeln(_center(seller.registeredAddress));
    final digits = seller.tin.replaceAll(RegExp(r'[^0-9]'), '');
    final identifier = digits.length == 9
        ? '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}-${seller.branchCode}'
        : seller.tin;
    buffer.writeln(_center(
        '${seller.registrationType == TaxRegistrationType.vat ? 'VAT' : 'NON-VAT'} REG TIN: $identifier'));
    buffer.writeln(_center('BRANCH: ${seller.branchCode}'));
    buffer.writeln(_center(
      seller.registrationType == TaxRegistrationType.vat
          ? 'VAT INVOICE'
          : 'NON-VAT INVOICE',
    ));
    if (invoice.status == InvoiceStatus.voided) {
      buffer.writeln(_center('VOIDED INVOICE'));
      if (invoice.voidReason?.isNotEmpty ?? false) {
        buffer.writeln(_center('Reason: ${invoice.voidReason}'));
      }
    }
    buffer.writeln(_line());
    buffer.writeln('Invoice No: ${invoice.invoiceNumber}');
    buffer.writeln(
        'Date (Asia/Manila): ${invoice.issuedAt.toUtc().add(const Duration(hours: 8)).toIso8601String().substring(0, 19).replaceFirst('T', ' ')}');
    buffer.writeln('Cashier: ${data.cashierName}');
    buffer.writeln('MIN: ${seller.machineIdentificationNumber}');
    buffer.writeln('PTU: ${seller.permitToUseNumber}');
    buffer.writeln('Serial: ${seller.machineSerialNumber}');
    buffer.writeln(
      'Software: ${seller.softwareName} ${seller.softwareVersion}',
    );
    if (invoice.buyer != null) {
      buffer.writeln(_line());
      buffer.writeln('Buyer: ${invoice.buyer!.registeredName}');
      if (invoice.buyer!.tin?.trim().isNotEmpty ?? false) {
        buffer.writeln('Buyer TIN: ${invoice.buyer!.tin}');
      }
      if (invoice.buyer!.address?.trim().isNotEmpty ?? false) {
        buffer.writeln('Buyer Address: ${invoice.buyer!.address}');
      }
    } else {
      buffer.writeln('Buyer: ____________________');
      buffer.writeln('Buyer TIN: ________________');
      buffer.writeln('Buyer Address: ____________');
    }
    buffer.writeln(_line());
    if (invoice.statutoryDiscount.isNotEmpty) {
      final claim = invoice.statutoryDiscount['claim'] as Map;
      buffer.writeln(
          '${claim['kind'].toString().toUpperCase()} / ${claim['scheme']}');
      buffer.writeln('Beneficiary: ${claim['name']}');
      buffer.writeln('${claim['idType']}: ${claim['idNumber']}');
    }
    for (final item in invoice.lines) {
      buffer.writeln(item.description);
      buffer.writeln(
        _columns(
          '${item.quantity} x ${_money(item.unitPriceCentavos)}',
          _money(item.netCentavos),
        ),
      );
      if (item.vatReliefCentavos > 0) {
        buffer.writeln(
            _columns('VAT removed', '-${_money(item.vatReliefCentavos)}'));
      }
      if (item.discountCentavos > 0) {
        buffer.writeln(
          _columns('Discount', '-${_money(item.discountCentavos)}'),
        );
      }
    }
    buffer.writeln(_line());
    buffer.writeln(_columns('TOTAL', _money(invoice.totalCentavos)));
    buffer.writeln(_columns(
      'VATable Sales',
      _money(invoice.taxSummary.vatableSalesCentavos),
    ));
    buffer.writeln(_columns(
      'VAT Amount',
      _money(invoice.taxSummary.vatAmountCentavos),
    ));
    buffer.writeln(_columns(
      'Zero-Rated Sales',
      _money(invoice.taxSummary.zeroRatedSalesCentavos),
    ));
    buffer.writeln(_columns(
      'VAT-Exempt Sales',
      _money(invoice.taxSummary.vatExemptSalesCentavos),
    ));
    buffer.writeln(_columns(
      'Non-VAT Sales',
      _money(invoice.taxSummary.nonVatSalesCentavos),
    ));
    buffer.writeln(_line());
    buffer.writeln('Payment: ${data.payment.provider.name.toUpperCase()}');
    buffer.writeln('Reference: ${data.payment.reference}');
    if (data.payment.provider == PaymentProvider.cash) {
      buffer.writeln(_columns(
        'Cash Tendered',
        _money(data.payment.cashTenderedCentavos ?? 0),
      ));
      buffer.writeln(_columns(
        'Change',
        _money(data.payment.changeCentavos ?? 0),
      ));
    }
    if (data.loyaltyCustomerName != null &&
        invoice.status != InvoiceStatus.voided) {
      buffer.writeln(_line());
      buffer.writeln('Customer: ${data.loyaltyCustomerName}');
      if (data.loyaltyEstimatedPoints > 0) {
        buffer.writeln(
            'Points earned: ~${data.loyaltyEstimatedPoints} (confirmed on sync)');
      }
    }
    if (data.isReprint) {
      buffer.writeln(_line());
      buffer.writeln(_center('REPRINT ONLY'));
      if (data.reprintedAt != null) {
        buffer.writeln(
            _center('Reprinted: ${data.reprintedAt!.toIso8601String()}'));
      }
    }
    if (seller.registrationType == TaxRegistrationType.nonVat) {
      buffer.writeln(_line());
      buffer.writeln('THIS DOCUMENT IS NOT VALID');
      buffer.writeln('FOR CLAIM OF INPUT TAX.');
    }
    if (seller.invoiceFooter.isNotEmpty) {
      buffer.writeln(_line());
      const labels = <String, String>{
        'ptuIssuedOn': 'PTU issued',
        'supplierName': 'Supplier',
        'supplierAddress': 'Supplier address',
        'supplierTin': 'Supplier TIN',
        'accreditationNumber': 'Accreditation No',
        'accreditationIssuedOn': 'Accreditation issued',
        'accreditationValidUntil': 'Accreditation valid until'
      };
      for (final e in labels.entries) {
        final value = seller.invoiceFooter[e.key];
        if (value != null && value.isNotEmpty) {
          buffer.writeln('${e.value}: $value');
        }
      }
    }
    return buffer.toString();
  }

  String _money(int centavos) => 'PHP ${(centavos / 100).toStringAsFixed(2)}';

  String _line() => '-' * lineWidth;

  String _center(String value) {
    if (value.length >= lineWidth) return value;
    final padding = (lineWidth - value.length) ~/ 2;
    return '${' ' * padding}$value';
  }

  String _columns(String left, String right) {
    final spaces = lineWidth - left.length - right.length;
    if (spaces < 1) return '$left $right';
    return '$left${' ' * spaces}$right';
  }
}

abstract interface class ReceiptPrinterAdapter {
  Future<void> printReceipt(
    String formattedReceipt, {
    required String jobId,
  });
}

abstract interface class CashDrawerAdapter {
  Future<void> openDrawer({required String jobId});
}

/// No physical printer is selected yet (docs/HARDWARE_ARCHITECTURE.md).
/// Marks the print job complete immediately so the hardware job queue has a
/// working adapter to dispatch to until a real ESC/POS/Bluetooth/USB driver
/// is chosen.
class LoggingReceiptPrinterAdapter implements ReceiptPrinterAdapter {
  const LoggingReceiptPrinterAdapter({this.onPrint});

  final void Function(String jobId, String formattedReceipt)? onPrint;

  @override
  Future<void> printReceipt(String formattedReceipt,
      {required String jobId}) async {
    onPrint?.call(jobId, formattedReceipt);
  }
}

/// No physical cash drawer is selected yet (docs/HARDWARE_ARCHITECTURE.md).
/// Marks the open-drawer job complete immediately.
class LoggingCashDrawerAdapter implements CashDrawerAdapter {
  const LoggingCashDrawerAdapter({this.onOpen});

  final void Function(String jobId)? onOpen;

  @override
  Future<void> openDrawer({required String jobId}) async {
    onOpen?.call(jobId);
  }
}
