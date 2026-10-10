import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/core/compliance/bir_invoice.dart';
import 'package:pos_app/core/hardware/pos_hardware.dart';
import 'package:pos_app/core/payments/payment.dart';
import 'package:pos_app/core/pricing/statutory_discount.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/company_registration_repository.dart';
import 'package:pos_app/local/repositories/offline_sale_repository.dart';
import 'package:pos_app/local/repositories/recovery_inspection_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';
import 'package:pos_app/local/repositories/statutory_discount_repository.dart';
import 'package:pos_app/local/repositories/terminal_closeout_repository.dart';
import 'company_registration_test.dart' as fixture;

StatutoryClaim claim(
        {StatutoryScheme scheme = StatutoryScheme.foodService,
        BeneficiaryKind kind = BeneficiaryKind.senior,
        int prior = 0,
        int priorDiscount = 0,
        bool verified = true,
        bool four = true,
        String name = 'Example Beneficiary',
        String id = 'SC-123'}) =>
    StatutoryClaim(
        kind: kind,
        scheme: scheme,
        name: name,
        idNumber: id,
        idType: 'Government ID',
        identityVerified: verified,
        exclusiveUse: true,
        personalPurchase: true,
        bookletChecked: true,
        priorWeekSpendCentavos: prior,
        priorWeekDiscountCentavos: priorDiscount,
        fourKindsConfirmed: four);

BirInvoiceLine line(
        {String id = 'p',
        int price = 11200,
        int qty = 1,
        TaxCategory tax = TaxCategory.vat12,
        int discount = 0}) =>
    BirInvoiceLine(
        productId: id,
        description: id,
        quantity: qty,
        unitPriceCentavos: price,
        taxCategory: tax,
        discountCentavos: discount);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('food service separates VAT relief, true discount and mixed-tax sales',
      () {
    for (final kind in BeneficiaryKind.values) {
      final result = calculateStatutoryDiscount(lines: [
        line(price: 112000),
        line(id: 'other', price: 11200)
      ], classifications: {
        'p': BenefitProductKind.preparedFood,
        'other': BenefitProductKind.excluded
      }, claim: claim(kind: kind), registration: TaxRegistrationType.vat);
      expect(result.totalCentavos, 91200);
      expect(result.discountCentavos, 20000);
      expect(result.vatReliefCentavos, 12000);
      final tax = const BirInvoiceCalculator().summarize(result.lines);
      expect(tax.vatExemptSalesCentavos, 80000);
      expect(tax.vatAmountCentavos, 1200);
      expect(tax.vatableSalesCentavos, 10000);
    }
    final nonVat = calculateStatutoryDiscount(
        lines: [line(tax: TaxCategory.nonVat)],
        classifications: {'p': BenefitProductKind.preparedFood},
        claim: claim(),
        registration: TaxRegistrationType.nonVat);
    expect(nonVat.totalCentavos, 8960);
    expect(nonVat.vatReliefCentavos, 0);
    expect(nonVat.lines.single.taxCategory, TaxCategory.nonVat);
  });
  test(
      'BNPC retains original tax and caps both purchase basis and actual discount',
      () {
    StatutoryQuote quote(StatutoryClaim c) => calculateStatutoryDiscount(
        lines: [line(price: 300000)],
        classifications: {'p': BenefitProductKind.rice},
        claim: c,
        registration: TaxRegistrationType.vat);
    expect(quote(claim(scheme: StatutoryScheme.bnpc)).totalCentavos, 287500);
    expect(quote(claim(scheme: StatutoryScheme.bnpc)).lines.single.taxCategory,
        TaxCategory.vat12);
    final remaining = quote(claim(
        scheme: StatutoryScheme.bnpc, prior: 240000, priorDiscount: 12000));
    expect(remaining.discountCentavos, 500);
    expect(remaining.vatReliefCentavos, 0);
    expect(remaining.snapshot['eligiblePurchaseCentavos'], 10000);
    expect(
        quote(claim(scheme: StatutoryScheme.bnpc, priorDiscount: 12499))
            .discountCentavos,
        1);
    expect(() => quote(claim(scheme: StatutoryScheme.bnpc, four: false)),
        throwsStateError);
    expect(() => quote(claim(scheme: StatutoryScheme.bnpc, prior: 250000)),
        throwsStateError);
  });
  test('centavo boundaries conserve money and do not depend on basket order',
      () {
    for (final price in [1, 5, 6, 10, 11, 112, 999, 11201]) {
      final result = calculateStatutoryDiscount(
          lines: [line(price: price, qty: 3)],
          classifications: {'p': BenefitProductKind.preparedFood},
          claim: claim(),
          registration: TaxRegistrationType.vat);
      expect(
          result.totalCentavos +
              result.discountCentavos +
              result.vatReliefCentavos,
          price * 3);
      expect(result.totalCentavos, greaterThanOrEqualTo(0));
    }
    final lines = [line(id: 'z', price: 11), line(id: 'a', price: 11)];
    final classes = {
      'z': BenefitProductKind.bread,
      'a': BenefitProductKind.bread
    };
    final a = calculateStatutoryDiscount(
        lines: lines,
        classifications: classes,
        claim: claim(scheme: StatutoryScheme.bnpc),
        registration: TaxRegistrationType.vat);
    final b = calculateStatutoryDiscount(
        lines: lines.reversed.toList(),
        classifications: classes,
        claim: claim(scheme: StatutoryScheme.bnpc),
        registration: TaxRegistrationType.vat);
    expect(a.snapshot['lines'], b.snapshot['lines']);
  });
  test(
      'missing evidence, unknown classifications, duplicate products and stacked discounts fail',
      () {
    StatutoryQuote calc(List<BirInvoiceLine> lines,
            {StatutoryClaim? c, Map<String, BenefitProductKind>? classes}) =>
        calculateStatutoryDiscount(
            lines: lines,
            classifications: classes ?? {'p': BenefitProductKind.preparedFood},
            claim: c ?? claim(),
            registration: TaxRegistrationType.vat);
    expect(
        () => calc([line()], c: claim(verified: false)), throwsArgumentError);
    expect(() => calc([line()], classes: {}), throwsStateError);
    expect(() => calc([line(discount: 1)]), throwsArgumentError);
    expect(() => calc([line(), line()]), throwsArgumentError);
    expect(() => calc([line()], c: claim(name: 'Name\nTOTAL: 0')),
        throwsArgumentError);
  });

  group('registered statutory sales', () {
    late AppDatabase db;
    late Directory dir;
    late File file;
    late CompanyRegistration company;
    late StaffAuthRepository staff;
    late StatutoryDiscountRepository benefits;
    final at = DateTime.utc(2026, 10, 10, 1);
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('statutory-sale-');
      file = File('${dir.path}/pos.sqlite');
      db = AppDatabase(NativeDatabase(file), requireRegistration: true);
      staff = StaffAuthRepository(db,
          passwordHasher: Pbkdf2PasswordHasher(iterations: 2));
      final reg = CompanyRegistrationRepository(db, staff: staff);
      company = await reg.register(fixture.setup());
      await reg.activate(
          email: 'owner@example.test', password: fixture.password);
      await fixture.stock(db);
      benefits = StatutoryDiscountRepository(db, staff: staff);
    });
    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });
    Future<void> configure({bool bnpc = false}) => benefits.configure(
            email: 'owner@example.test',
            password: fixture.password,
            branchId: CompanyRegistration.branchId,
            schemes: {
              bnpc ? StatutoryScheme.bnpc : StatutoryScheme.foodService
            },
            classes: {
              'p': bnpc
                  ? BenefitProductKind.bread
                  : BenefitProductKind.preparedFood
            });
    OfflineSaleRequest request(
            {StatutoryClaim? c,
            int amount = 8000,
            String id = 'pay',
            DateTime? time,
            int discount = 0}) =>
        OfflineSaleRequest(
            branchId: CompanyRegistration.branchId,
            terminalId: company.terminalId,
            actorId: company.ownerId,
            issuedAt: time ?? at,
            payment: PaymentEvidence(
                id: id,
                provider: PaymentProvider.cash,
                status: PaymentStatus.captured,
                amountCentavos: amount,
                reference: id,
                authorizedAt: time ?? at,
                isOffline: true,
                cashTenderedCentavos: 11200,
                changeCentavos: 11200 - amount),
            sellerName: 'unused',
            sellerTin: 'unused',
            sellerAddress: 'unused',
            registrationType: TaxRegistrationType.nonVat,
            softwareName: 'Xantara',
            softwareVersion: '1',
            lines: [
              OfflineSaleLineRequest(
                  productId: 'p',
                  quantity: 1,
                  discountCentavos: discount,
                  expectedUnitPriceCentavos: 11200)
            ],
            checkoutType: (c?.scheme ?? StatutoryScheme.foodService) ==
                    StatutoryScheme.bnpc
                ? 'retail'
                : 'fnb',
            statutoryClaim: c ?? claim());

    test(
        'beneficiary receipt survives restart, matches journal, X/Z and later void',
        () async {
      await configure();
      final invoice = await OfflineSaleRepository(db)
          .issueSale(request(c: claim(name: '=Example Beneficiary')));
      expect(invoice.totalCentavos, 8000);
      expect(invoice.lines.single.discountCentavos, 2000);
      expect(invoice.lines.single.vatReliefCentavos, 1200);
      final event = (await db.select(db.syncOutboxEvents).get())
          .firstWhere((e) => e.eventType == 'invoice.issued');
      expect((jsonDecode(event.payloadJson) as Map)['statutoryDiscount'],
          isNotNull);
      await db.close();
      db = AppDatabase(NativeDatabase(file), requireRegistration: true);
      final saved = (await OfflineSaleRepository(db)
              .watchSales(branchId: CompanyRegistration.branchId)
              .first)
          .single;
      expect(saved.invoice.statutoryDiscount, invoice.statutoryDiscount);
      expect(saved.invoice.lines.single.netCentavos, 8000);
      final receipt = const BirReceiptFormatter().format(ReceiptPrintData(
          invoice: saved.invoice,
          payment: saved.payment,
          cashierName: 'Owner',
          isReprint: true));
      expect(receipt, contains('VAT removed'));
      expect(receipt, contains('=Example Beneficiary'));
      final reports = TerminalCloseoutRepository(db,
          clock: () => at.add(const Duration(hours: 1)));
      final x = await reports.xReading(
          actorId: company.ownerId,
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId,
          day: '2026-10-10');
      expect(x.totals['gross'], 10000);
      expect(x.totals['discount'], 2000);
      expect(x.totals['net'], 8000);
      expect(x.totals['exempt'], 8000);
      final z = await reports.closeDay(
          actorId: company.ownerId, password: fixture.password, reviewed: x);
      expect(z.totals, x.totals);
      final journal = await reports.exportJournal(
          actorId: company.ownerId,
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId,
          day: '2026-10-10');
      expect(journal.text, contains('RECONCILIATION: PASS'));
      expect(journal.text, contains('VAT removed'));
      final csv = await StatutoryDiscountRepository(db).exportCsv(
          actorId: company.ownerId,
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId,
          day: '2026-10-10');
      expect(csv, contains("'=Example Beneficiary"));
      expect(csv, contains('"112.00","12.00","100.00","20.00","80.00"'));
      await OfflineSaleRepository(db).voidInvoice(VoidInvoiceRequest(
          invoiceId: invoice.id,
          actorId: company.ownerId,
          reason: 'Test void',
          voidedAt: at.add(const Duration(days: 1))));
      final next = await TerminalCloseoutRepository(db,
              clock: () => at.add(const Duration(days: 1, hours: 1)))
          .xReading(
              actorId: company.ownerId,
              branchId: CompanyRegistration.branchId,
              terminalId: company.terminalId,
              day: '2026-10-11');
      expect(next.totals['net'], -8000);
      expect(next.totals['exempt'], -8000);
      expect(z.totals['net'], 8000);
    });
    test(
        'unsupported, stacked and stale payment attempts leave all fiscal state untouched',
        () async {
      var checkpoint = await RecoveryInspectionRepository(db).checkpoint();
      await expectLater(
          OfflineSaleRepository(db).issueSale(request()), throwsStateError);
      expect(
          await RecoveryInspectionRepository(db).inspect(expected: checkpoint),
          isEmpty);
      await configure();
      checkpoint = await RecoveryInspectionRepository(db).checkpoint();
      await expectLater(
          OfflineSaleRepository(db).issueSale(request(amount: 11200)),
          throwsA(isA<PaymentEvidenceException>()));
      await expectLater(
          OfflineSaleRepository(db).issueSale(request(discount: 1)),
          throwsArgumentError);
      expect(
          await RecoveryInspectionRepository(db).inspect(expected: checkpoint),
          isEmpty);
      await db.customStatement(
          "CREATE TRIGGER abort_statutory BEFORE INSERT ON invoice_lines BEGIN SELECT RAISE(ABORT,'interrupted'); END");
      await expectLater(
          OfflineSaleRepository(db).issueSale(request()), throwsA(anything));
      await db.customStatement('DROP TRIGGER abort_statutory');
      expect(
          await RecoveryInspectionRepository(db).inspect(expected: checkpoint),
          isEmpty);
    });
    test(
        'weekly claims detect stale booklet values and reset at Sunday Manila boundary',
        () async {
      await configure(bnpc: true);
      await OfflineSaleRepository(db).issueSale(
          request(c: claim(scheme: StatutoryScheme.bnpc), amount: 10640));
      final checkpoint = await RecoveryInspectionRepository(db).checkpoint();
      await expectLater(
          OfflineSaleRepository(db).issueSale(request(
              c: claim(scheme: StatutoryScheme.bnpc, id: 'sc123'),
              amount: 10640,
              id: 'again')),
          throwsStateError);
      expect(
          await RecoveryInspectionRepository(db).inspect(expected: checkpoint),
          isEmpty);
      await OfflineSaleRepository(db).issueSale(request(
          c: claim(
              scheme: StatutoryScheme.bnpc, prior: 11200, priorDiscount: 560),
          amount: 10640,
          id: 'next'));
      await OfflineSaleRepository(db).issueSale(request(
          c: claim(scheme: StatutoryScheme.bnpc),
          amount: 10640,
          id: 'new-week',
          time: DateTime.utc(2026, 10, 10, 16)));
      expect(await db.select(db.invoices).get(), hasLength(3));
    });
    test('catalog identity edits invalidate eligibility, price changes do not',
        () async {
      await configure();
      await (db.update(db.products)..where((p) => p.id.equals('p')))
          .write(const ProductsCompanion(unitPriceCentavos: Value(12000)));
      expect((await benefits.classifications())['p'],
          BenefitProductKind.preparedFood);
      await (db.update(db.products)..where((p) => p.id.equals('p')))
          .write(const ProductsCompanion(name: Value('Different product')));
      expect(await benefits.classifications(), isEmpty);
    });
    test('known external weekly usage cannot be lowered on a later claim',
        () async {
      await configure(bnpc: true);
      await OfflineSaleRepository(db).issueSale(request(
          c: claim(
              scheme: StatutoryScheme.bnpc,
              prior: 240000,
              priorDiscount: 12000),
          amount: 10700));
      final checkpoint = await RecoveryInspectionRepository(db).checkpoint();
      await expectLater(
          OfflineSaleRepository(db).issueSale(request(
              c: claim(
                  scheme: StatutoryScheme.bnpc,
                  prior: 10000,
                  priorDiscount: 500),
              amount: 10640,
              id: 'reset')),
          throwsStateError);
      expect(
          await RecoveryInspectionRepository(db).inspect(expected: checkpoint),
          isEmpty);
    });
    test(
        'non-owner cannot configure benefits and inventory staff cannot export beneficiary data',
        () async {
      final clerk = await staff.createStaff(CreateStaffRequest(
          displayName: 'Clerk',
          email: 'clerk@example.test',
          role: StaffRole.inventoryClerk,
          password: fixture.password,
          branchIds: {CompanyRegistration.branchId},
          createdBy: company.ownerId,
          createdAt: at));
      await expectLater(
          benefits.configure(
              email: 'clerk@example.test',
              password: fixture.password,
              branchId: CompanyRegistration.branchId,
              schemes: {StatutoryScheme.bnpc},
              classes: {'p': BenefitProductKind.bread}),
          throwsA(isA<AuthorizationException>()));
      expect(await benefits.enabledSchemes(), isEmpty);
      expect(await benefits.classifications(), isEmpty);
      await expectLater(
          benefits.exportCsv(
              actorId: clerk,
              branchId: CompanyRegistration.branchId,
              terminalId: company.terminalId,
              day: '2026-10-10'),
          throwsA(isA<AuthorizationException>()));
    });
    test(
        'v11 upgrade preserves saved invoice and series, leaves new benefits disabled',
        () async {
      await OfflineSaleRepository(db).issueSale(
          fixture.sale(terminal: company.terminalId, actor: company.ownerId));
      await db.customStatement('DROP TABLE statutory_product_classes');
      await db.customStatement('DROP TABLE statutory_policy');
      await db.customStatement('PRAGMA user_version=11');
      await db.close();
      db = AppDatabase(NativeDatabase(file), requireRegistration: true);
      expect(await StatutoryDiscountRepository(db).enabledSchemes(), isEmpty);
      expect(await db.select(db.invoices).get(), hasLength(1));
      expect((await db.select(db.invoiceSequences).getSingle()).nextValue, 43);
    });
  });
}
