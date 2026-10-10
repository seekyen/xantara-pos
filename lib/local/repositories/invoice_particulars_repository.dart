import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../core/compliance/bir_invoice.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'company_registration_repository.dart';
import 'staff_auth_repository.dart';

const supplierFooterFields = <String, String>{
  'supplierName': 'Supplier registered name',
  'supplierAddress': 'Supplier address',
  'supplierTin': 'Supplier TIN with 5-digit branch code',
  'accreditationNumber': 'Accreditation number',
  'accreditationIssuedOn': 'Accreditation issued (YYYY-MM-DD)',
  'accreditationValidUntil': 'Accreditation valid until (YYYY-MM-DD)',
};

class InvoiceParticularsRepository {
  InvoiceParticularsRepository(this.db, {StaffAuthRepository? staff})
      : staff = staff ?? StaffAuthRepository(db);
  final AppDatabase db;
  final StaffAuthRepository staff;

  Future<Map<String, String>> footer() async {
    final row = await db
        .customSelect('SELECT data_json FROM invoice_footer_config WHERE id=1')
        .getSingleOrNull();
    return row == null
        ? {}
        : Map<String, String>.from(
            jsonDecode(row.read<String>('data_json')) as Map);
  }

  Future<void> saveFooter(
      {required String email,
      required String password,
      required Map<String, String> values}) async {
    final user = await staff.authenticate(
        email: email, password: password, now: DateTime.now());
    final company = await CompanyRegistrationRepository(db).read();
    if (company == null || user.id != company.ownerId) {
      throw StateError(
          'Only the registered owner can update supplier particulars.');
    }
    final clean = {
      for (final key in supplierFooterFields.keys)
        key: (values[key] ?? '').trim()
    };
    if (clean.values.any((v) =>
        v.isEmpty ||
        v.length > 400 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(v))) {
      throw ArgumentError(
          'Complete all supplier particulars using the approved documents.');
    }
    if (!RegExp(r'^[0-9 -]+$').hasMatch(clean['supplierTin']!) ||
        clean['supplierTin']!.replaceAll(RegExp(r'[^0-9]'), '').length != 14) {
      throw ArgumentError(
          'Supplier TIN must contain nine digits and a five-digit branch code.');
    }
    for (final key in ['accreditationIssuedOn', 'accreditationValidUntil']) {
      final date = DateTime.tryParse(clean[key]!);
      if (date == null ||
          date.toIso8601String().substring(0, 10) != clean[key]) {
        throw ArgumentError('Use valid YYYY-MM-DD accreditation dates.');
      }
    }
    if (clean['accreditationIssuedOn']!
            .compareTo(clean['accreditationValidUntil']!) >
        0) {
      throw ArgumentError(
          'Accreditation expiry must not precede its issue date.');
    }
    await db.transaction(() async {
      final previous = await footer();
      await db.customStatement(
          'INSERT INTO invoice_footer_config(id,data_json) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET data_json=excluded.data_json',
          [jsonEncode(clean)]);
      await AuditTrailRepository(db).append(
          branchId: CompanyRegistration.branchId,
          terminalId: company.terminalId,
          actorId: user.id,
          eventType: 'invoice_footer.updated',
          entityType: 'terminal',
          entityId: company.terminalId,
          payloadJson: jsonEncode({'before': previous, 'after': clean}),
          occurredAt: DateTime.now());
    });
  }

  Future<Map<String, dynamic>> read(String invoiceId) async {
    final row = await db.customSelect(
        'SELECT data_json FROM invoice_particulars WHERE invoice_id=?',
        variables: [Variable(invoiceId)]).getSingleOrNull();
    return row == null
        ? {}
        : jsonDecode(row.read<String>('data_json')) as Map<String, dynamic>;
  }
}

Map<String, dynamic> invoiceParticulars(BirInvoice invoice) => {
      'footer': invoice.seller.invoiceFooter,
      'buyerBusiness': invoice.buyer?.isBusiness ?? false,
      if (invoice.statutoryDiscount.isNotEmpty)
        'statutoryDiscount': invoice.statutoryDiscount,
    };

String particularsHash(Map<String, dynamic> particulars,
        {String? name, String? tin, String? address}) =>
    sha256
        .convert(utf8.encode(jsonEncode({
          'particulars': particulars,
          'buyerName': name,
          'buyerTin': tin,
          'buyerAddress': address
        })))
        .toString();
