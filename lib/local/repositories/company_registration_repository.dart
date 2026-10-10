import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../core/auth/pos_authorization.dart';
import '../../core/compliance/bir_invoice.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'staff_auth_repository.dart';

class CompanyRegistration {
  const CompanyRegistration({
    required this.companyId,
    required this.registeredName,
    required this.tin,
    required this.address,
    required this.branchCode,
    required this.rdo,
    required this.registrationType,
    required this.terminalId,
    required this.terminalCode,
    required this.machineSerial,
    required this.min,
    required this.ptu,
    required this.ptuIssuedOn,
    required this.startingSerial,
    required this.ownerId,
    required this.createdAt,
    this.activatedAt,
    this.cloudBusinessId = '',
    this.cloudBranchCode = 'MAIN',
    this.serverTerminalId = '',
  });

  final String companyId, registeredName, tin, address, branchCode, rdo;
  final TaxRegistrationType registrationType;
  final String terminalId, terminalCode, machineSerial, min, ptu, ptuIssuedOn;
  final int startingSerial;
  final String ownerId, createdAt, cloudBusinessId;
  final String cloudBranchCode, serverTerminalId;
  final String? activatedAt;
  bool get isActive => activatedAt != null;
  static const branchId = 'branch-main';

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'registeredName': registeredName,
        'tin': tin,
        'address': address,
        'branchCode': branchCode,
        'rdo': rdo,
        'registrationType': registrationType.name,
        'terminalId': terminalId,
        'terminalCode': terminalCode,
        'machineSerial': machineSerial,
        'min': min,
        'ptu': ptu,
        'ptuIssuedOn': ptuIssuedOn,
        'startingSerial': startingSerial,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'activatedAt': activatedAt,
        'cloudBusinessId': cloudBusinessId,
        'cloudBranchCode': cloudBranchCode,
        'serverTerminalId': serverTerminalId,
      };

  factory CompanyRegistration.fromJson(Map<String, dynamic> j) =>
      CompanyRegistration(
        companyId: j['companyId'] as String,
        registeredName: j['registeredName'] as String,
        tin: j['tin'] as String,
        address: j['address'] as String,
        branchCode: j['branchCode'] as String,
        rdo: j['rdo'] as String,
        registrationType:
            TaxRegistrationType.values.byName(j['registrationType'] as String),
        terminalId: j['terminalId'] as String,
        terminalCode: j['terminalCode'] as String,
        machineSerial: j['machineSerial'] as String,
        min: j['min'] as String,
        ptu: j['ptu'] as String,
        ptuIssuedOn: j['ptuIssuedOn'] as String,
        startingSerial: j['startingSerial'] as int,
        ownerId: j['ownerId'] as String,
        createdAt: j['createdAt'] as String,
        activatedAt: j['activatedAt'] as String?,
        cloudBusinessId: j['cloudBusinessId'] as String? ?? '',
        cloudBranchCode: j['cloudBranchCode'] as String? ?? 'MAIN',
        serverTerminalId: j['serverTerminalId'] as String? ?? '',
      );
}

class CompanySetupRequest {
  const CompanySetupRequest({
    required this.registeredName,
    required this.tin,
    required this.address,
    required this.branchCode,
    required this.rdo,
    required this.registrationType,
    required this.terminalCode,
    required this.machineSerial,
    required this.min,
    required this.ptu,
    required this.ptuIssuedOn,
    required this.startingSerial,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPassword,
    this.cloudBusinessId = '',
  });
  final String registeredName, tin, address, branchCode, rdo, terminalCode;
  final String machineSerial,
      min,
      ptu,
      ptuIssuedOn,
      ownerName,
      ownerEmail,
      ownerPassword;
  final String cloudBusinessId;
  final TaxRegistrationType registrationType;
  final int startingSerial;

  void validate() {
    if ([registeredName, address, machineSerial, min, ptu, ownerName]
        .any((s) => s.trim().isEmpty)) {
      throw ArgumentError('Complete the company, terminal and owner details.');
    }
    if (!RegExp(r'^\d{9}$').hasMatch(tin.replaceAll('-', '').trim()) ||
        RegExp(r'^0+$').hasMatch(tin.replaceAll('-', '').trim())) {
      throw ArgumentError(
          'Enter the nine-digit company TIN, without the branch code.');
    }
    if (!RegExp(r'^\d{5}$').hasMatch(branchCode.trim())) {
      throw ArgumentError('The registered branch code must have five digits.');
    }
    if (!RegExp(r'^\d{3}$').hasMatch(rdo.trim())) {
      throw ArgumentError('Enter a three-digit RDO code.');
    }
    if (!RegExp(r'^[A-Z0-9]{2,16}$').hasMatch(terminalCode.trim())) {
      throw ArgumentError(
          'Terminal code must have 2-16 uppercase letters or digits.');
    }
    if (startingSerial < 1 || startingSerial > 99999999) {
      throw ArgumentError('Starting serial must be between 1 and 99999999.');
    }
    final date = DateTime.tryParse(ptuIssuedOn);
    if (date == null ||
        date.toIso8601String().substring(0, 10) != ptuIssuedOn ||
        date.isAfter(DateTime.now())) {
      throw ArgumentError(
          'Enter a valid PTU issue date (YYYY-MM-DD), not in the future.');
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(ownerEmail.trim())) {
      throw ArgumentError('Enter a valid owner email.');
    }
    if ([registeredName, machineSerial, min, ptu].any((v) =>
        RegExp(r'training|placeholder|configure', caseSensitive: false)
            .hasMatch(v))) {
      throw ArgumentError(
          'Replace training placeholders with the company registration details.');
    }
  }
}

class CompanyRegistrationRepository {
  CompanyRegistrationRepository(this.database, {StaffAuthRepository? staff})
      : staff = staff ?? StaffAuthRepository(database);
  final AppDatabase database;
  final StaffAuthRepository staff;

  Future<CompanyRegistration?> read() async {
    final row = await database
        .customSelect(
            'SELECT profile_json FROM company_registration WHERE id = 1')
        .getSingleOrNull();
    return row == null
        ? null
        : CompanyRegistration.fromJson(
            jsonDecode(row.read<String>('profile_json'))
                as Map<String, dynamic>);
  }

  Future<CompanyRegistration> register(CompanySetupRequest request) =>
      _register(request);

  /// Only called with the authenticated enrollment endpoint's configuration.
  /// Uses the same atomic empty-database and owner creation path as local setup.
  Future<CompanyRegistration> registerEnrolled(Map<String, dynamic> config,
      {required String ownerName,
      required String ownerEmail,
      required String ownerPassword}) {
    for (final key in [
      'companyId',
      'terminalId',
      'serverTerminalId',
      'cloudBusinessId',
      'cloudBranchCode',
      'activatedAt'
    ]) {
      if (config[key] is! String || (config[key] as String).isEmpty) {
        throw FormatException('Incomplete enrollment configuration: $key');
      }
    }
    final request = CompanySetupRequest(
        registeredName: config['registeredName'] as String,
        tin: config['tin'] as String,
        address: config['address'] as String,
        branchCode: config['branchCode'] as String,
        rdo: config['rdo'] as String,
        registrationType: TaxRegistrationType.values
            .byName(config['registrationType'] as String),
        terminalCode: config['terminalCode'] as String,
        machineSerial: config['machineSerial'] as String,
        min: config['min'] as String,
        ptu: config['ptu'] as String,
        ptuIssuedOn: config['ptuIssuedOn'] as String,
        startingSerial: config['startingSerial'] as int,
        ownerName: ownerName,
        ownerEmail: ownerEmail,
        ownerPassword: ownerPassword,
        cloudBusinessId: config['cloudBusinessId'] as String);
    return _register(request, enrollment: config);
  }

  Future<CompanyRegistration> _register(CompanySetupRequest request,
      {Map<String, dynamic>? enrollment}) async {
    request.validate();
    return database.transaction(() async {
      if (await read() != null) {
        throw StateError('This installation is already registered.');
      }
      if ((await database.select(database.branches).get()).isNotEmpty ||
          (await database.select(database.staffUsers).get()).isNotEmpty ||
          (await database.select(database.invoices).get()).isNotEmpty) {
        throw StateError(
            'Registration requires a separate, empty company database. Existing records are preserved.');
      }
      final now = DateTime.now();
      final terminalId =
          enrollment?['terminalId'] as String? ?? const Uuid().v4();
      await database.into(database.branches).insert(BranchesCompanion.insert(
          id: CompanyRegistration.branchId,
          code: 'MAIN',
          name: request.registeredName.trim(),
          createdAt: now));
      await database.into(database.terminals).insert(TerminalsCompanion.insert(
          id: terminalId,
          branchId: CompanyRegistration.branchId,
          code: request.terminalCode.trim(),
          machineIdentificationNumber: request.min.trim(),
          permitToUseNumber: request.ptu.trim(),
          machineSerialNumber: request.machineSerial.trim(),
          createdAt: now));
      await database.into(database.invoiceSequences).insert(
          InvoiceSequencesCompanion.insert(
              terminalId: terminalId,
              nextValue: request.startingSerial,
              updatedAt: now));
      final ownerId = await staff.createStaff(CreateStaffRequest(
          displayName: request.ownerName,
          email: request.ownerEmail,
          password: request.ownerPassword,
          role: StaffRole.owner,
          branchIds: {CompanyRegistration.branchId},
          createdBy: 'company-setup',
          createdAt: now));
      final profile = CompanyRegistration(
        companyId: enrollment?['companyId'] as String? ?? const Uuid().v4(),
        registeredName: request.registeredName.trim(),
        tin: request.tin.replaceAll('-', '').trim(),
        address: request.address.trim(),
        branchCode: request.branchCode.trim(),
        rdo: request.rdo.trim(),
        registrationType: request.registrationType,
        terminalId: terminalId,
        terminalCode: request.terminalCode.trim(),
        machineSerial: request.machineSerial.trim(),
        min: request.min.trim(),
        ptu: request.ptu.trim(),
        ptuIssuedOn: request.ptuIssuedOn,
        startingSerial: request.startingSerial,
        ownerId: ownerId,
        createdAt: now.toUtc().toIso8601String(),
        cloudBusinessId: request.cloudBusinessId.trim(),
        cloudBranchCode: enrollment?['cloudBranchCode'] as String? ?? 'MAIN',
        serverTerminalId: enrollment?['serverTerminalId'] as String? ?? '',
        activatedAt: enrollment?['activatedAt'] as String?,
      );
      await database.customStatement(
          'INSERT INTO company_registration (id, profile_json) VALUES (1, ?)',
          [jsonEncode(profile.toJson())]);
      await AuditTrailRepository(database).append(
          branchId: CompanyRegistration.branchId,
          terminalId: terminalId,
          actorId: ownerId,
          eventType: 'company.registered',
          entityType: 'company',
          entityId: profile.companyId,
          payloadJson: jsonEncode(profile.toJson()),
          occurredAt: now);
      return profile;
    });
  }

  Future<CompanyRegistration> updateDraft(CompanySetupRequest request) async {
    request.validate();
    final actor = await staff.authenticate(
        email: request.ownerEmail,
        password: request.ownerPassword,
        now: DateTime.now());
    return database.transaction(() async {
      final previous = await read();
      if (previous == null || previous.isActive) {
        throw StateError('Only an unactivated registration can be edited.');
      }
      if (actor.id != previous.ownerId || actor.role != StaffRole.owner) {
        throw const AuthorizationException(
            'Only the registered owner can edit setup.');
      }
      if ((await database.select(database.invoices).get()).isNotEmpty) {
        throw StateError(
            'Registration cannot change after an invoice has been issued.');
      }
      final next = CompanyRegistration.fromJson({
        ...previous.toJson(),
        'registeredName': request.registeredName.trim(),
        'tin': request.tin.replaceAll('-', '').trim(),
        'address': request.address.trim(),
        'branchCode': request.branchCode.trim(),
        'rdo': request.rdo.trim(),
        'registrationType': request.registrationType.name,
        'terminalCode': request.terminalCode.trim(),
        'machineSerial': request.machineSerial.trim(),
        'min': request.min.trim(),
        'ptu': request.ptu.trim(),
        'ptuIssuedOn': request.ptuIssuedOn,
        'startingSerial': request.startingSerial,
        'cloudBusinessId': request.cloudBusinessId.trim(),
      });
      await (database.update(database.terminals)
            ..where((t) => t.id.equals(previous.terminalId)))
          .write(TerminalsCompanion(
              code: Value(next.terminalCode),
              machineIdentificationNumber: Value(next.min),
              permitToUseNumber: Value(next.ptu),
              machineSerialNumber: Value(next.machineSerial)));
      await (database.update(database.invoiceSequences)
            ..where((s) => s.terminalId.equals(previous.terminalId)))
          .write(InvoiceSequencesCompanion(
              nextValue: Value(next.startingSerial),
              updatedAt: Value(DateTime.now())));
      await (database.update(database.branches)
            ..where((b) => b.id.equals(CompanyRegistration.branchId)))
          .write(BranchesCompanion(name: Value(next.registeredName)));
      await database.customStatement(
          'UPDATE company_registration SET profile_json = ? WHERE id = 1',
          [jsonEncode(next.toJson())]);
      await AuditTrailRepository(database).append(
          branchId: CompanyRegistration.branchId,
          terminalId: next.terminalId,
          actorId: actor.id,
          eventType: 'company.setup_updated',
          entityType: 'company',
          entityId: next.companyId,
          payloadJson:
              jsonEncode({'before': previous.toJson(), 'after': next.toJson()}),
          occurredAt: DateTime.now());
      return next;
    });
  }

  Future<CompanyRegistration> activate(
      {required String email, required String password}) async {
    // Authenticate outside the transaction so failed-login counters are retained.
    final actor = await staff.authenticate(
        email: email, password: password, now: DateTime.now());
    return database.transaction(() async {
      final profile = await read();
      if (profile == null) throw StateError('Complete company setup first.');
      if (actor.id != profile.ownerId ||
          actor.role != StaffRole.owner ||
          !actor.branchIds.contains(CompanyRegistration.branchId)) {
        throw const AuthorizationException(
            'Only the registered owner can activate this terminal.');
      }
      if (profile.isActive) return profile;
      final now = DateTime.now();
      final activated = CompanyRegistration.fromJson(
          {...profile.toJson(), 'activatedAt': now.toUtc().toIso8601String()});
      await database.customStatement(
          'UPDATE company_registration SET profile_json = ? WHERE id = 1',
          [jsonEncode(activated.toJson())]);
      await AuditTrailRepository(database).append(
          branchId: CompanyRegistration.branchId,
          terminalId: profile.terminalId,
          actorId: actor.id,
          eventType: 'company.activated',
          entityType: 'company',
          entityId: profile.companyId,
          payloadJson: jsonEncode(activated.toJson()),
          occurredAt: now);
      return activated;
    });
  }
}
