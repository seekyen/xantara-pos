import '../../core/compliance/bir_invoice.dart' as bir;
import '../../core/payments/payment.dart';
import '../database.dart';

class SaleRecord {
  const SaleRecord({required this.invoice, required this.payment});

  final bir.BirInvoice invoice;
  final PaymentEvidence payment;
}

bir.BirInvoice assembleInvoice(Invoice row, List<InvoiceLine> lines) {
  return bir.BirInvoice(
    id: row.id,
    invoiceNumber: row.invoiceNumber,
    issuedAt: row.issuedAt,
    seller: bir.BirSellerProfile(
      registeredName: row.sellerName,
      tin: row.sellerTin,
      branchCode: row.branchCode,
      registeredAddress: row.sellerAddress,
      registrationType:
          bir.TaxRegistrationType.values.byName(row.sellerRegistrationType),
      machineIdentificationNumber: row.machineIdentificationNumber,
      permitToUseNumber: row.permitToUseNumber,
      machineSerialNumber: row.machineSerialNumber,
      softwareName: row.softwareName,
      softwareVersion: row.softwareVersion,
    ),
    buyer: row.buyerName == null
        ? null
        : bir.BirBuyerDetails(
            registeredName: row.buyerName!,
            tin: row.buyerTin,
            address: row.buyerAddress,
          ),
    lines: List.unmodifiable(
      lines.map(
        (line) => bir.BirInvoiceLine(
          productId: line.productId,
          description: line.description,
          quantity: line.quantity,
          unitPriceCentavos: line.unitPriceCentavos,
          discountCentavos: line.discountCentavos,
          taxCategory: bir.TaxCategory.values.byName(line.taxCategory),
        ),
      ),
    ),
    taxSummary: bir.BirTaxSummary(
      vatableSalesCentavos: row.vatableSalesCentavos,
      vatAmountCentavos: row.vatAmountCentavos,
      zeroRatedSalesCentavos: row.zeroRatedSalesCentavos,
      vatExemptSalesCentavos: row.vatExemptSalesCentavos,
      nonVatSalesCentavos: row.nonVatSalesCentavos,
    ),
    totalCentavos: row.totalCentavos,
    status: bir.InvoiceStatus.values.byName(row.status),
    paymentReference: row.paymentReference,
    voidedAt: row.voidedAt,
    voidReason: row.voidReason,
    originalInvoiceId: row.originalInvoiceId,
  );
}

PaymentEvidence assemblePayment(Payment row) {
  return PaymentEvidence(
    id: row.id,
    provider: PaymentProvider.values.byName(row.provider),
    status: PaymentStatus.values.byName(row.status),
    amountCentavos: row.amountCentavos,
    reference: row.reference,
    authorizedAt: row.authorizedAt,
    isOffline: row.isOffline,
    cashTenderedCentavos: row.cashTenderedCentavos,
    changeCentavos: row.changeCentavos,
  );
}
