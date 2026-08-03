import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';

void main() {
  group('BirInvoiceCalculator', () {
    test('splits VAT-inclusive sales using integer centavos', () {
      const calculator = BirInvoiceCalculator();
      const lines = [
        BirInvoiceLine(
          productId: 'P1',
          description: 'VAT item',
          quantity: 1,
          unitPriceCentavos: 11200,
          taxCategory: TaxCategory.vat12,
        ),
      ];

      final result = calculator.summarize(lines);

      expect(result.vatableSalesCentavos, 10000);
      expect(result.vatAmountCentavos, 1200);
      expect(calculator.total(lines), 11200);
    });

    test('keeps zero-rated, exempt, and non-VAT sales separate', () {
      const calculator = BirInvoiceCalculator();
      const lines = [
        BirInvoiceLine(
          productId: 'Z',
          description: 'Zero rated',
          quantity: 1,
          unitPriceCentavos: 10000,
          taxCategory: TaxCategory.zeroRated,
        ),
        BirInvoiceLine(
          productId: 'E',
          description: 'Exempt',
          quantity: 2,
          unitPriceCentavos: 5000,
          taxCategory: TaxCategory.vatExempt,
        ),
        BirInvoiceLine(
          productId: 'N',
          description: 'Non VAT',
          quantity: 1,
          unitPriceCentavos: 7500,
          taxCategory: TaxCategory.nonVat,
        ),
      ];

      final result = calculator.summarize(lines);

      expect(result.zeroRatedSalesCentavos, 10000);
      expect(result.vatExemptSalesCentavos, 10000);
      expect(result.nonVatSalesCentavos, 7500);
    });
  });

  group('BirInvoiceSequence', () {
    test('allocates stable branch and terminal scoped serials', () {
      final sequence = BirInvoiceSequence(
        branchCode: '001',
        terminalCode: 'POS01',
        nextSequence: 42,
      );

      expect(sequence.allocate(), '001-POS01-00000042');
      expect(sequence.allocate(), '001-POS01-00000043');
      expect(sequence.nextSequence, 44);
    });
  });

  group('BirInvoiceIssuer', () {
    const vatSeller = BirSellerProfile(
      registeredName: 'Example Retail Inc.',
      tin: '000-000-000-00000',
      branchCode: '001',
      registeredAddress: 'Quezon City',
      registrationType: TaxRegistrationType.vat,
      machineIdentificationNumber: 'MIN-001',
      permitToUseNumber: 'PTU-001',
      machineSerialNumber: 'SERIAL-001',
      softwareName: 'Xantara POS',
      softwareVersion: '1.0.0',
    );

    test('issues a validated immutable invoice with the next serial', () {
      final sequence = BirInvoiceSequence(
        branchCode: '001',
        terminalCode: 'POS01',
        nextSequence: 1,
      );
      const lines = [
        BirInvoiceLine(
          productId: 'P1',
          description: 'Retail item',
          quantity: 1,
          unitPriceCentavos: 11200,
          taxCategory: TaxCategory.vat12,
        ),
      ];

      final invoice = const BirInvoiceIssuer().issue(
        id: 'local-uuid',
        issuedAt: DateTime(2026, 7, 11),
        seller: vatSeller,
        lines: lines,
        sequence: sequence,
        paymentReference: 'CASH',
      );

      expect(invoice.invoiceNumber, '001-POS01-00000001');
      expect(invoice.totalCentavos, 11200);
      expect(invoice.taxSummary.vatAmountCentavos, 1200);
      expect(() => invoice.lines.add(lines.first), throwsUnsupportedError);
    });

    test('does not consume a serial when validation fails', () {
      final sequence = BirInvoiceSequence(
        branchCode: '001',
        terminalCode: 'POS01',
        nextSequence: 8,
      );
      const invalidLines = [
        BirInvoiceLine(
          productId: 'P1',
          description: 'Wrong tax category',
          quantity: 1,
          unitPriceCentavos: 10000,
          taxCategory: TaxCategory.nonVat,
        ),
      ];

      expect(
        () => const BirInvoiceIssuer().issue(
          id: 'invalid',
          issuedAt: DateTime(2026, 7, 11),
          seller: vatSeller,
          lines: invalidLines,
          sequence: sequence,
          paymentReference: 'CASH',
        ),
        throwsA(isA<BirInvoiceValidationException>()),
      );
      expect(sequence.nextSequence, 8);
    });
  });

  test('voiding preserves the original financial record', () {
    const seller = BirSellerProfile(
      registeredName: 'Example Retail Inc.',
      tin: '000-000-000-00000',
      branchCode: '001',
      registeredAddress: 'Quezon City',
      registrationType: TaxRegistrationType.vat,
      machineIdentificationNumber: 'MIN-001',
      permitToUseNumber: 'PTU-001',
      machineSerialNumber: 'SERIAL-001',
      softwareName: 'Xantara POS',
      softwareVersion: '1.0.0',
    );
    final invoice = BirInvoice(
      id: 'INV-ID',
      invoiceNumber: '001-POS01-00000001',
      issuedAt: DateTime(2026, 1, 1),
      seller: seller,
      lines: [],
      taxSummary: const BirTaxSummary(
        vatableSalesCentavos: 0,
        vatAmountCentavos: 0,
        zeroRatedSalesCentavos: 0,
        vatExemptSalesCentavos: 0,
        nonVatSalesCentavos: 0,
      ),
      totalCentavos: 0,
      status: InvoiceStatus.issued,
      paymentReference: 'CASH',
    );

    final voided = invoice.voidInvoice(
      at: DateTime(2026, 1, 2),
      reason: 'Customer cancelled',
    );

    expect(voided.invoiceNumber, invoice.invoiceNumber);
    expect(voided.totalCentavos, invoice.totalCentavos);
    expect(voided.status, InvoiceStatus.voided);
    expect(voided.voidReason, 'Customer cancelled');
  });
}
