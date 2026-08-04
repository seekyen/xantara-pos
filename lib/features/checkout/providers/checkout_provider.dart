import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../pos/fnb/providers/cart_provider.dart';
import '../../../core/compliance/bir_invoice.dart' as bir;

enum PaymentMethod { card, cash, gcash, maya, bank, qrph }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.card => 'Credit / Debit Card',
        PaymentMethod.cash => 'Cash',
        PaymentMethod.gcash => 'GCash',
        PaymentMethod.maya => 'Maya',
        PaymentMethod.bank => 'Bank Transfer',
        PaymentMethod.qrph => 'QRPh (Legacy)',
      };
}

class BirReceiptDetails {
  const BirReceiptDetails({
    required this.invoiceNumber,
    required this.vatableSalesCentavos,
    required this.vatAmountCentavos,
    required this.zeroRatedSalesCentavos,
    required this.vatExemptSalesCentavos,
    required this.nonVatSalesCentavos,
    required this.sellerName,
    required this.sellerTin,
    required this.sellerAddress,
    required this.branchCode,
    required this.machineIdentificationNumber,
    required this.permitToUseNumber,
    required this.machineSerialNumber,
    required this.isTraining,
  });

  final String invoiceNumber;
  final int vatableSalesCentavos;
  final int vatAmountCentavos;
  final int zeroRatedSalesCentavos;
  final int vatExemptSalesCentavos;
  final int nonVatSalesCentavos;
  final String sellerName;
  final String sellerTin;
  final String sellerAddress;
  final String branchCode;
  final String machineIdentificationNumber;
  final String permitToUseNumber;
  final String machineSerialNumber;
  final bool isTraining;
}

/// The seller profile stays "training" until real BIR registration details
/// (TIN, RDO, approved serial start) are configured — see
/// docs/BIR_COMPLIANCE_BASELINE.md. Terminal-specific fields (MIN/PTU/
/// serial) come from the seeded Terminal row instead, inside
/// OfflineSaleRepository.issueSale.
class MerchantProfile {
  const MerchantProfile({
    required this.registeredName,
    required this.tin,
    required this.registeredAddress,
    required this.registrationType,
    required this.softwareName,
    required this.softwareVersion,
  });

  final String registeredName;
  final String tin;
  final String registeredAddress;
  final bir.TaxRegistrationType registrationType;
  final String softwareName;
  final String softwareVersion;
}

const trainingMerchantProfile = MerchantProfile(
  registeredName: 'XANTARA POS TRAINING MERCHANT',
  tin: '000-000-000-00000',
  registeredAddress: 'CONFIGURE REGISTERED BUSINESS ADDRESS',
  registrationType: bir.TaxRegistrationType.vat,
  softwareName: 'Xantara POS',
  softwareVersion: '1.0.0',
);

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final double? cashReceived;
  final double? change;
  final DateTime timestamp;
  final BirReceiptDetails? birReceipt;
  final String paymentReference;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
    this.cashReceived,
    this.change,
    this.birReceipt,
    required this.paymentReference,
  });
}

const _uuid = Uuid();

Order buildOrder({
  String? id,
  DateTime? timestamp,
  required List<CartItem> cartItems,
  required double total,
  required PaymentMethod method,
  double? cashReceived,
  BirReceiptDetails? birReceipt,
  required String paymentReference,
}) {
  return Order(
    id: id ?? newOrderId(),
    items: cartItems
        .map((i) => OrderItem(
              name: i.product.name,
              price: i.product.price,
              quantity: i.quantity,
              subtotal: i.subtotal,
            ))
        .toList(),
    total: total,
    paymentMethod: method,
    cashReceived: cashReceived,
    change: cashReceived != null ? cashReceived - total : null,
    timestamp: timestamp ?? DateTime.now(),
    birReceipt: birReceipt,
    paymentReference: paymentReference,
  );
}

String newOrderId() => _uuid.v4().substring(0, 8).toUpperCase();

/// The seller profile is always "training" until real BIR registration
/// details (TIN, RDO, approved serial start) are configured — see
/// docs/BIR_COMPLIANCE_BASELINE.md.
BirReceiptDetails birReceiptFromInvoice(bir.BirInvoice invoice) =>
    BirReceiptDetails(
      invoiceNumber: invoice.invoiceNumber,
      vatableSalesCentavos: invoice.taxSummary.vatableSalesCentavos,
      vatAmountCentavos: invoice.taxSummary.vatAmountCentavos,
      zeroRatedSalesCentavos: invoice.taxSummary.zeroRatedSalesCentavos,
      vatExemptSalesCentavos: invoice.taxSummary.vatExemptSalesCentavos,
      nonVatSalesCentavos: invoice.taxSummary.nonVatSalesCentavos,
      sellerName: invoice.seller.registeredName,
      sellerTin: invoice.seller.tin,
      sellerAddress: invoice.seller.registeredAddress,
      branchCode: invoice.seller.branchCode,
      machineIdentificationNumber: invoice.seller.machineIdentificationNumber,
      permitToUseNumber: invoice.seller.permitToUseNumber,
      machineSerialNumber: invoice.seller.machineSerialNumber,
      isTraining: true,
    );

final lastOrderProvider = StateProvider<Order?>((ref) => null);
