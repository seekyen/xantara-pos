import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../core/auth/pos_authorization.dart';
import '../../core/compliance/bir_invoice.dart' as bir;
import '../../core/pricing/statutory_discount.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'company_registration_repository.dart';
import 'invoice_particulars_repository.dart';
import 'staff_auth_repository.dart';

class StatutoryDiscountRepository {
  StatutoryDiscountRepository(this.db, {StaffAuthRepository? staff})
      : staff = staff ?? StaffAuthRepository(db);
  final AppDatabase db;
  final StaffAuthRepository staff;

  String _fingerprint(Product p) => sha256
      .convert(utf8.encode(jsonEncode([p.id, p.sku, p.name, p.taxCategory])))
      .toString();

  Future<Map<String, BenefitProductKind>> classifications() async {
    final rows =
        await db.customSelect('SELECT * FROM statutory_product_classes').get();
    final products = {
      for (final p in await db.select(db.products).get()) p.id: p
    };
    return {
      for (final r in rows)
        if (products[r.read<String>('product_id')] != null &&
            _fingerprint(products[r.read<String>('product_id')]!) ==
                r.read<String>('product_fingerprint'))
          r.read<String>('product_id'):
              BenefitProductKind.values.byName(r.read<String>('kind'))
    };
  }

  Future<Set<StatutoryScheme>> enabledSchemes() async {
    final row = await db
        .customSelect('SELECT * FROM statutory_policy WHERE id=1')
        .getSingleOrNull();
    return {
      if (row?.read<int>('food_service') == 1) StatutoryScheme.foodService,
      if (row?.read<int>('bnpc') == 1) StatutoryScheme.bnpc
    };
  }

  Future<void> configure(
      {required String email,
      required String password,
      required String branchId,
      required Set<StatutoryScheme> schemes,
      required Map<String, BenefitProductKind> classes}) async {
    final actor = await staff.authenticate(
        email: email, password: password, now: DateTime.now());
    final company = await CompanyRegistrationRepository(db).read();
    if (actor.role != StaffRole.owner ||
        !actor.branchIds.contains(branchId) ||
        (company != null && company.ownerId != actor.id)) {
      throw const AuthorizationException(
          'Only the business owner can configure statutory eligibility.');
    }
    await db.transaction(() async {
      final before = await classifications();
      final previous = await enabledSchemes();
      for (final entry in classes.entries) {
        final product = await (db.select(db.products)
              ..where((p) => p.id.equals(entry.key)))
            .getSingle();
        await db.customStatement(
            'INSERT INTO statutory_product_classes(product_id,kind,product_fingerprint) VALUES(?,?,?) ON CONFLICT(product_id) DO UPDATE SET kind=excluded.kind,product_fingerprint=excluded.product_fingerprint',
            [entry.key, entry.value.name, _fingerprint(product)]);
      }
      await db.customStatement(
          'INSERT INTO statutory_policy(id,food_service,bnpc) VALUES(1,?,?) ON CONFLICT(id) DO UPDATE SET food_service=excluded.food_service,bnpc=excluded.bnpc',
          [
            schemes.contains(StatutoryScheme.foodService) ? 1 : 0,
            schemes.contains(StatutoryScheme.bnpc) ? 1 : 0
          ]);
      await AuditTrailRepository(db).append(
          branchId: branchId,
          actorId: actor.id,
          eventType: 'statutory.configuration_updated',
          entityType: 'statutory_policy',
          entityId: '1',
          payloadJson: jsonEncode({
            'before': before.map((k, v) => MapEntry(k, v.name)),
            'after': classes.map((k, v) => MapEntry(k, v.name)),
            'previousSchemes': previous.map((s) => s.name).toList(),
            'schemes': schemes.map((s) => s.name).toList()
          }),
          occurredAt: DateTime.now());
    });
  }

  /// Re-evaluated inside the sale transaction; preview is never authority.
  Future<StatutoryQuote> quote(
      {required StatutoryClaim claim,
      required List<bir.BirInvoiceLine> lines,
      required bir.TaxRegistrationType registration,
      required DateTime issuedAt,
      required String checkoutType}) async {
    final expected = checkoutType == 'fnb'
        ? StatutoryScheme.foodService
        : checkoutType == 'retail'
            ? StatutoryScheme.bnpc
            : null;
    if (expected != claim.scheme ||
        !(await enabledSchemes()).contains(claim.scheme)) {
      throw StateError(
          'The owner must enable the applicable benefit for this checkout.');
    }
    claim.validate();
    if (claim.scheme == StatutoryScheme.bnpc) {
      // Sunday-through-Saturday calendar week in the Philippines. Local claims
      // are a lower bound; the cashier must consult purchases at other stores.
      final local = issuedAt.toUtc().add(const Duration(hours: 8));
      final startLocal = DateTime.utc(local.year, local.month, local.day)
          .subtract(Duration(days: local.weekday % 7));
      final start = startLocal.subtract(const Duration(hours: 8));
      final end = start.add(const Duration(days: 7));
      final invoices = await (db.select(db.invoices)
            ..where((i) =>
                i.issuedAt.isBiggerOrEqualValue(start) &
                i.issuedAt.isSmallerThanValue(end)))
          .get();
      var used = 0, discountUsed = 0;
      for (final invoice in invoices) {
        final snapshot = (await InvoiceParticularsRepository(db)
            .read(invoice.id))['statutoryDiscount'] as Map?;
        final saved = snapshot?['claim'] as Map?;
        if (saved?['scheme'] == StatutoryScheme.bnpc.name &&
            saved?['kind'] == claim.kind.name &&
            _id(saved?['idNumber'] as String? ?? '') == _id(claim.idNumber)) {
          // Do not automatically restore a booklet allowance on void/refund.
          final observedSpend = (saved!['priorWeekSpendCentavos'] as int) +
              (snapshot!['eligiblePurchaseCentavos'] as int);
          final observedDiscount = (saved['priorWeekDiscountCentavos'] as int) +
              (snapshot['discountCentavos'] as int);
          if (observedSpend > used) used = observedSpend;
          if (observedDiscount > discountUsed) discountUsed = observedDiscount;
        }
      }
      if (claim.priorWeekSpendCentavos < used ||
          claim.priorWeekDiscountCentavos < discountUsed) {
        throw StateError(
            'The booklet amount is below this POS’s recorded weekly purchases. Review all stores and both IDs if applicable.');
      }
    }
    return calculateStatutoryDiscount(
        lines: lines,
        classifications: await classifications(),
        claim: claim,
        registration: registration);
  }

  Future<StatutoryQuote> preview(
      {required StatutoryClaim claim,
      required Map<String, int> quantities,
      required String checkoutType}) async {
    final company = await CompanyRegistrationRepository(db).read();
    final lines = <bir.BirInvoiceLine>[];
    for (final entry in quantities.entries) {
      final p = await (db.select(db.products)
            ..where((p) => p.id.equals(entry.key)))
          .getSingle();
      lines.add(bir.BirInvoiceLine(
          productId: p.id,
          description: p.name,
          quantity: entry.value,
          unitPriceCentavos: p.unitPriceCentavos,
          taxCategory: productTaxCategory(p.taxCategory)));
    }
    return quote(
        claim: claim,
        lines: lines,
        registration: company?.registrationType ?? bir.TaxRegistrationType.vat,
        issuedAt: DateTime.now(),
        checkoutType: checkoutType);
  }

  Future<String> exportCsv(
          {required String actorId,
          required String branchId,
          required String terminalId,
          required String day}) =>
      db.transaction(() async {
        final user = await (db.select(db.staffUsers)
              ..where((s) => s.id.equals(actorId)))
            .getSingle();
        final access = await (db.select(db.staffBranchAccess)
              ..where((a) =>
                  a.staffUserId.equals(actorId) & a.branchId.equals(branchId)))
            .getSingleOrNull();
        if (!user.isActive || access == null) {
          throw const AuthorizationException('No access to this branch.');
        }
        const PosAuthorizationPolicy().require(
            StaffPrincipal(
                id: user.id,
                displayName: user.displayName,
                email: user.emailNormalized,
                role: StaffRole.values.byName(user.role),
                branchIds: {branchId}),
            PosPermission.viewTerminalReading,
            branchId: branchId);
        if (!(await AuditTrailRepository(db).verifyBranch(branchId)).isValid) {
          throw StateError(
              'Audit verification failed. Preserve this database for review before exporting beneficiary sales.');
        }
        final date = DateTime.tryParse(day);
        if (date == null || date.toIso8601String().substring(0, 10) != day) {
          throw ArgumentError('Use YYYY-MM-DD.');
        }
        final start = DateTime.utc(date.year, date.month, date.day)
            .subtract(const Duration(hours: 8));
        final rows = await (db.select(db.invoices)
              ..where((i) =>
                  i.branchId.equals(branchId) &
                  i.terminalId.equals(terminalId) &
                  i.issuedAt.isBiggerOrEqualValue(start) &
                  i.issuedAt
                      .isSmallerThanValue(start.add(const Duration(days: 1))))
              ..orderBy([
                (i) => OrderingTerm.asc(i.issuedAt),
                (i) => OrderingTerm.asc(i.invoiceNumber)
              ]))
            .get();
        final csv = StringBuffer('\uFEFF');
        void row(List<Object?> cells) => csv.writeln(cells.map((c) {
              var s = c?.toString() ?? '';
              if (RegExp(r'^\s*[=+@-]').hasMatch(s)) s = "'$s";
              return '"${s.replaceAll('"', '""')}"';
            }).join(','));
        row([
          'Supporting beneficiary sales register — internal report',
          branchId,
          terminalId,
          day
        ]);
        row([
          'Invoice',
          'Status',
          'Voided at UTC',
          'Issued at UTC',
          'Benefit',
          'Scheme',
          'Name',
          'ID type',
          'ID number',
          'Regular gross PHP',
          'VAT removed PHP',
          'Gross after VAT relief PHP',
          'Discount PHP',
          'Amount due PHP',
          'Weekly eligible purchases PHP'
        ]);
        for (final invoice in rows) {
          final particulars =
              await InvoiceParticularsRepository(db).read(invoice.id);
          final s = particulars['statutoryDiscount'] as Map?;
          if (s == null) continue;
          final event = await (db.select(db.auditEvents)
                ..where((e) =>
                    e.entityId.equals(invoice.id) &
                    e.eventType.equals('invoice.issued')))
              .getSingle();
          if ((jsonDecode(event.payloadJson) as Map)['particularsHash'] !=
              particularsHash(particulars,
                  name: invoice.buyerName,
                  tin: invoice.buyerTin,
                  address: invoice.buyerAddress)) {
            throw StateError('Beneficiary invoice integrity check failed.');
          }
          final claim = s['claim'] as Map;
          final discount = s['discountCentavos'] as int,
              relief = s['vatReliefCentavos'] as int;
          String money(int n) => (n / 100).toStringAsFixed(2);
          row([
            invoice.invoiceNumber,
            invoice.status,
            invoice.voidedAt?.toUtc().toIso8601String(),
            invoice.issuedAt.toUtc().toIso8601String(),
            claim['kind'],
            claim['scheme'],
            claim['name'],
            claim['idType'],
            claim['idNumber'],
            money(invoice.totalCentavos + discount + relief),
            money(relief),
            money(invoice.totalCentavos + discount),
            money(discount),
            money(invoice.totalCentavos),
            claim['scheme'] == 'bnpc'
                ? money(s['eligiblePurchaseCentavos'] as int)
                : ''
          ]);
        }
        await AuditTrailRepository(db).append(
            branchId: branchId,
            terminalId: terminalId,
            actorId: actorId,
            eventType: 'statutory.report_exported',
            entityType: 'statutory_report',
            entityId: '$terminalId:$day',
            payloadJson: jsonEncode({
              'sha256': sha256.convert(utf8.encode(csv.toString())).toString()
            }),
            occurredAt: DateTime.now());
        return csv.toString();
      });
}

String _id(String value) =>
    value.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
bir.TaxCategory productTaxCategory(String value) =>
    bir.TaxCategory.values.byName(switch (value) {
      'vat_exempt' => 'vatExempt',
      'zero_rated' => 'zeroRated',
      'non_vat' => 'nonVat',
      _ => value
    });
