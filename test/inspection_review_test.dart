import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/features/reports/daily_report_csv.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

void main() {
  test('VAT rounding conserves every centavo across boundary amounts', () {
    const calculator = BirInvoiceCalculator();
    // Independent expected values: inclusive price, VAT-exclusive base, VAT.
    for (final row in [
      [1, 1, 0],
      [5, 4, 1],
      [99, 88, 11],
      [100, 89, 11],
      [11199, 9999, 1200],
      [11200, 10000, 1200],
      [11201, 10001, 1200],
    ]) {
      final tax = calculator.summarize([
        BirInvoiceLine(
            productId: 'p',
            description: 'Boundary',
            quantity: 1,
            unitPriceCentavos: row[0],
            taxCategory: TaxCategory.vat12)
      ]);
      expect(tax.vatableSalesCentavos, row[1]);
      expect(tax.vatAmountCentavos, row[2]);
      expect(tax.vatableSalesCentavos + tax.vatAmountCentavos, row[0]);
    }
  });

  test('line rounding differs from aggregate rounding and remains conserved',
      () {
    const calc = BirInvoiceCalculator();
    final lines = List.generate(
        2,
        (i) => BirInvoiceLine(
            productId: 'p$i',
            description: 'Small item',
            quantity: 1,
            unitPriceCentavos: 5,
            taxCategory: TaxCategory.vat12));
    final result = calc.summarize(lines);
    expect(result.vatableSalesCentavos, 8);
    expect(result.vatAmountCentavos, 2);
    expect(calc.total(lines), 10);
    // Aggregate 0.10 would yield base 0.09 and VAT 0.01: document the policy.
  });

  test(
      'registered mixed-tax invoice matches X, Z, CSV and journal after discount',
      () async {
    final db = AppDatabase(NativeDatabase.memory(), requireRegistration: true);
    addTearDown(db.close);
    final staff = StaffAuthRepository(db,
        passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
    final registration = CompanyRegistrationRepository(db, staff: staff);
    final company = await registration.register(fixture.setup());
    await registration.activate(
        email: 'owner@example.test', password: fixture.password);
    final at = DateTime.utc(2026, 10, 7, 2);
    for (final row in [
      ('vat', 11200, 'vat12'),
      ('zero', 5000, 'zeroRated'),
      ('exempt', 3000, 'vatExempt')
    ]) {
      await db.into(db.products).insert(ProductsCompanion.insert(
          id: row.$1,
          sku: row.$1,
          name: 'TEST ONLY ${row.$1}',
          taxCategory: row.$3,
          unitPriceCentavos: row.$2,
          createdAt: at,
          updatedAt: at));
      await db.into(db.branchInventories).insert(
          BranchInventoriesCompanion.insert(
              branchId: CompanyRegistration.branchId,
              productId: row.$1,
              stockOnHand: const Value(10),
              updatedAt: at));
    }
    final payment =
        await CashPaymentGateway(createEvidenceId: () => 'inspection-payment')
            .capture(PaymentRequest(
                idempotencyKey: 'inspection-sale',
                amountCentavos: 17280,
                provider: PaymentProvider.cash,
                requestedAt: at,
                cashTenderedCentavos: 20000));
    final invoice = await OfflineSaleRepository(db).issueSale(
        OfflineSaleRequest(
            branchId: CompanyRegistration.branchId,
            terminalId: company.terminalId,
            actorId: company.ownerId,
            issuedAt: at,
            payment: payment,
            sellerName: 'Ignored',
            sellerTin: 'Ignored',
            sellerAddress: 'Ignored',
            registrationType: TaxRegistrationType.vat,
            softwareName: 'Xantara POS',
            softwareVersion: '1.0.0',
            buyer: const BirBuyerDetails(
                registeredName: 'TEST BUYER ONLY',
                tin: '987654321',
                address: 'Test address'),
            lines: const [
          OfflineSaleLineRequest(
              productId: 'vat', quantity: 1, discountCentavos: 1120),
          OfflineSaleLineRequest(
              productId: 'zero', quantity: 1, discountCentavos: 500),
          OfflineSaleLineRequest(
              productId: 'exempt', quantity: 1, discountCentavos: 300)
        ]));
    expect(invoice.totalCentavos, 17280);
    expect(invoice.taxSummary.vatableSalesCentavos, 9000);
    expect(invoice.taxSummary.vatAmountCentavos, 1080);
    expect(invoice.taxSummary.zeroRatedSalesCentavos, 4500);
    expect(invoice.taxSummary.vatExemptSalesCentavos, 2700);
    expect(payment.changeCentavos, 2720);
    expect(invoice.seller.registeredName, 'Example Company');
    final reports = TerminalCloseoutRepository(db,
        staff: staff, clock: () => at.add(const Duration(hours: 1)));
    final x = await reports.xReading(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        day: '2026-10-07');
    for (final entry in {
      'gross': 19200,
      'discount': 1920,
      'sales': 17280,
      'net': 17280,
      'vatable': 9000,
      'vat': 1080,
      'zero': 4500,
      'exempt': 2700,
      'nonVat': 0,
      'void': 0
    }.entries) {
      expect(x.totals[entry.key], entry.value, reason: entry.key);
    }
    final z = await reports.closeDay(
        actorId: company.ownerId, password: fixture.password, reviewed: x);
    expect(z.totals, x.totals);
    expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    final journal = await reports.exportJournal(
        actorId: company.ownerId,
        branchId: CompanyRegistration.branchId,
        terminalId: company.terminalId,
        day: '2026-10-07');
    expect(journal.text, contains('RECONCILIATION: PASS'));
    expect(journal.text, contains('TEST BUYER ONLY'));
    final receipt = const BirReceiptFormatter().format(ReceiptPrintData(
        invoice: invoice,
        payment: payment,
        cashierName: 'TEST OPERATOR',
        isReprint: false));
    expect(receipt, contains('Buyer TIN: 987654321'));
    expect(receipt, contains('PHP 172.80'));
    final csv = dailyReportCsv(z);
    expect(csv, contains('"Net sales","172.80","PHP"'));
    // Optional, explicit evidence output; normal test runs do not create artifacts.
    final evidencePath = Platform.environment['INSPECTION_EVIDENCE_DIR'];
    if (evidencePath != null) {
      final dir = Directory(evidencePath)..createSync(recursive: true);
      for (final file in {
        'registered-invoice.txt': receipt,
        'registered-x.txt': x.format(),
        'registered-z.txt': z.format(),
        'registered-z.csv': csv,
        'registered-journal.txt': journal.text
      }.entries) {
        File('${dir.path}/${file.key}').writeAsStringSync(file.value);
      }
      File('${dir.path}/README.txt').writeAsStringSync(
          'SYNTHETIC TEST FIXTURES ONLY - NOT VALID SALES OR BIR REGISTRATION DOCUMENTS.\n'
          'Generated by inspection_review_test.dart in an isolated in-memory database.\n'
          'Example Company, buyer, MIN and PTU are fictional. Repository-level samples; no physical print.\n'
          'Gross PHP192.00 - discount PHP19.20 = PHP172.80; base90 + VAT10.80 + zero45 + exempt27.\n');
    }
  });
}
