import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../core/auth/pos_authorization.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'company_registration_repository.dart';
import 'staff_auth_repository.dart';
import 'journal_store.dart';
import 'invoice_particulars_repository.dart';
part 'cash_drawer_repository.dart';
part 'daily_journal_repository.dart';

String manilaBusinessDay(DateTime time) => time
    .toUtc()
    .add(const Duration(hours: 8))
    .toIso8601String()
    .substring(0, 10);

class ReadingSnapshot {
  ReadingSnapshot(Map<String, dynamic> data) : data = Map.unmodifiable(data);
  final Map<String, dynamic> data;
  String get day => data['businessDay'] as String;
  int get watermark => data['eventWatermark'] as int;
  int get zNumber => data['zNumber'] as int;
  int get previousZ => data['previousZ'] as int;
  String get terminalId => data['terminalId'] as String;
  String get branchId => data['branchId'] as String;
  bool get isZ => data['type'] == 'Z';
  Map<String, dynamic> get totals =>
      Map<String, dynamic>.from(data['totals'] as Map);

  String format({bool reprint = false}) {
    String money(dynamic v) => ((v as int) / 100).toStringAsFixed(2);
    final b = StringBuffer();
    if (reprint) b.writeln('REPRINT / COPY');
    b.writeln('${data['type']} READING${isZ ? ' #$zNumber' : ''}');
    final seller = data['seller'] as Map;
    for (final key in [
      'name',
      'tin',
      'address',
      'branchCode',
      'terminalCode',
      'min',
      'ptu',
      'serial',
      'rdo',
      'ptuDate'
    ]) {
      b.writeln('$key: ${seller[key]}');
    }
    if (seller['training'] == true) b.writeln('TRAINING - NOT FOR TAX FILING');
    b.writeln('Business date (Asia/Manila): $day');
    b.writeln('Generated (UTC): ${data['generatedAt']}');
    b.writeln('Operator: ${data['actorName']}');
    b.writeln(
        'Invoices: ${data['firstInvoice'] ?? '-'} to ${data['lastInvoice'] ?? '-'}');
    b.writeln(
        'Sales count: ${data['saleCount']} | Void count: ${data['voidCount']}');
    const labels = {
      'gross': 'Sales before discounts (after VAT relief)',
      'discount': 'Sales discounts',
      'sales': 'Sales after discounts',
      'void': 'Void adjustments',
      'net': 'Net sales',
      'vatable': 'VATable sales (net of voids)',
      'vat': 'VAT (net of voids)',
      'exempt': 'VAT-exempt sales (net)',
      'zero': 'Zero-rated sales (net)',
      'nonVat': 'Non-VAT sales (net)',
    };
    for (final entry in labels.entries) {
      b.writeln('${entry.value}: PHP ${money(totals[entry.key])}');
    }
    for (final entry in (data['statutoryTotals'] as Map? ?? {}).entries) {
      b.writeln(
          'Statutory ${entry.key} (net of voids): PHP ${money(entry.value)}');
    }
    if (data['creditNoteTotal'] != null) {
      b.writeln('Credit notes: ${(data['creditNotes'] as List).join(', ')}');
      b.writeln(
          'Returns / cash refunds: PHP ${money(data['creditNoteTotal'])}');
    }
    for (final entry in (data['payments'] as Map).entries) {
      b.writeln('${entry.key} net payments: PHP ${money(entry.value)}');
    }
    b.writeln(
        'Previously closed cumulative net: PHP ${money(data['oldGrandTotal'])}');
    b.writeln(
        '${isZ ? 'New cumulative net' : 'Closed total plus this reading'}: PHP ${money(data['newGrandTotal'])}');
    b.writeln(
        'Void invoice references: ${(data['voidInvoices'] as List).join(', ')}');
    b.writeln('Voids are recorded on their adjustment day.');
    final cash = data['cashDrawer'] as Map?;
    if (cash != null && cash['started'] == true) {
      b.writeln(
          'CASH DRAWER: ${cash['reviewed'] == true ? 'Manager reviewed' : 'Pending / recount required'}');
      for (final key in [
        'opening',
        'cashSales',
        'cashIn',
        'cashOut',
        'refunds',
        'expected',
        'counted',
        'variance'
      ]) {
        b.writeln(
            '$key: ${cash[key] == null ? 'Not counted' : 'PHP ${money(cash[key])}'}');
      }
      for (final event in cash['entries'] as List) {
        b.writeln(
            '${event['kind']}: PHP ${money(event['amount'])} | ${event['actorName']} | ${event['recordedAt']} | ${event['note']}');
      }
    } else {
      b.writeln('Cash drawer: not reconciled');
    }
    b.writeln('Internal report; BIR inspection readiness remains in progress.');
    return b.toString();
  }
}

class TerminalCloseoutRepository {
  TerminalCloseoutRepository(this.db,
      {DateTime Function()? clock, StaffAuthRepository? staff})
      : clock = clock ?? DateTime.now,
        staff = staff ?? StaffAuthRepository(db);
  final AppDatabase db;
  final DateTime Function() clock;
  final StaffAuthRepository staff;

  Future<StaffPrincipal> _authorize(String actorId, String branch,
      String terminal, PosPermission permission) async {
    final user = await (db.select(db.staffUsers)
          ..where((u) => u.id.equals(actorId)))
        .getSingleOrNull();
    final access = await (db.select(db.staffBranchAccess)
          ..where((a) => a.staffUserId.equals(actorId)))
        .get();
    if (user == null || !user.isActive) {
      throw const AuthorizationException('Sign in with an active account.');
    }
    final actor = StaffPrincipal(
        id: user.id,
        displayName: user.displayName,
        email: user.emailNormalized,
        role: StaffRole.values.byName(user.role),
        branchIds: access.map((a) => a.branchId).toSet());
    const PosAuthorizationPolicy().require(actor, permission, branchId: branch);
    final t = await (db.select(db.terminals)
          ..where((t) => t.id.equals(terminal) & t.branchId.equals(branch)))
        .getSingleOrNull();
    if (t == null) throw StateError('Terminal does not belong to this branch.');
    if (permission == PosPermission.closeBusinessDay) {
      final registration = await CompanyRegistrationRepository(db).read();
      if (!t.isActive ||
          (db.requireRegistration &&
              (registration == null ||
                  !registration.isActive ||
                  registration.terminalId != terminal))) {
        throw StateError(
            'Activate the registered terminal before closing business days.');
      }
    }
    return actor;
  }

  void _validateDay(String day) {
    final parsed = DateTime.tryParse(day);
    if (parsed == null ||
        parsed.toIso8601String().substring(0, 10) != day ||
        day.compareTo(manilaBusinessDay(clock())) > 0) {
      throw ArgumentError('Choose a valid business date, not in the future.');
    }
  }

  Future<List<ReadingSnapshot>> history(
      {required String actorId,
      required String branchId,
      required String terminalId}) async {
    await _authorize(
        actorId, branchId, terminalId, PosPermission.viewTerminalReading);
    return _history(terminalId);
  }

  Future<List<ReadingSnapshot>> _history(String terminal) async {
    final rows = await db.customSelect(
        'SELECT snapshot_json FROM fiscal_z_readings WHERE terminal_id=? ORDER BY z_no DESC',
        variables: [Variable(terminal)]).get();
    return rows
        .map((r) => ReadingSnapshot(jsonDecode(r.read<String>('snapshot_json'))
            as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> openDays(
      {required String actorId,
      required String branchId,
      required String terminalId}) async {
    await _authorize(
        actorId, branchId, terminalId, PosPermission.viewTerminalReading);
    final saved = await _history(terminalId);
    final lastDay = saved.isEmpty ? '' : saved.first.day;
    final rows = await db
        .customSelect('''SELECT DISTINCT e.business_day FROM fiscal_reading_events e
      JOIN invoices i ON i.id=e.invoice_id WHERE i.terminal_id=? AND e.business_day>?
      UNION SELECT business_day FROM cash_drawer_events WHERE terminal_id=? AND business_day>?
      ORDER BY business_day''', variables: [
      Variable(terminalId),
      Variable(lastDay),
      Variable(terminalId),
      Variable(lastDay)
    ]).get();
    return {
      ...rows.map((r) => r.read<String>('business_day')),
      if (manilaBusinessDay(clock()).compareTo(lastDay) > 0)
        manilaBusinessDay(clock())
    }.toList()
      ..sort();
  }

  Future<ReadingSnapshot> xReading(
          {required String actorId,
          required String branchId,
          required String terminalId,
          required String day}) =>
      db.transaction(() async {
        _validateDay(day);
        final actor = await _authorize(
            actorId, branchId, terminalId, PosPermission.viewTerminalReading);
        final history = await _history(terminalId);
        if (history.isNotEmpty && day.compareTo(history.first.day) <= 0) {
          throw StateError('This day is closed. Open its saved Z reading.');
        }
        final snapshot =
            await _build(actor, branchId, terminalId, day, history);
        await _audit(actor.id, snapshot, 'reading.x_generated');
        return snapshot;
      });

  Future<ReadingSnapshot> closeDay(
      {required String actorId,
      required String password,
      required ReadingSnapshot reviewed}) async {
    final actor = await _authorize(actorId, reviewed.branchId,
        reviewed.terminalId, PosPermission.closeBusinessDay);
    final verified = await staff.authenticate(
        email: actor.email, password: password, now: clock());
    if (verified.id != actorId) {
      throw const AuthorizationException('Use your own manager account.');
    }
    return db.transaction(() async {
      _validateDay(reviewed.day);
      await _authorize(actorId, reviewed.branchId, reviewed.terminalId,
          PosPermission.closeBusinessDay);
      final history = await _history(reviewed.terminalId);
      final existing = history.where((r) => r.day == reviewed.day).firstOrNull;
      if (existing != null) return existing; // response-loss/double-click retry
      if (history.isNotEmpty &&
          reviewed.day.compareTo(history.first.day) <= 0) {
        throw StateError(
            'Business days must be closed in chronological order.');
      }
      final days = await openDays(
          actorId: actorId,
          branchId: reviewed.branchId,
          terminalId: reviewed.terminalId);
      if (days.isNotEmpty && days.first.compareTo(reviewed.day) < 0) {
        throw StateError('Close the earlier business day ${days.first} first.');
      }
      final current = await _build(
          actor, reviewed.branchId, reviewed.terminalId, reviewed.day, history);
      final cash = current.data['cashDrawer'] as Map;
      if (cash['started'] == true && cash['reviewed'] != true) {
        throw StateError(
            'Count the drawer and have a manager review it before closing.');
      }
      if ((reviewed.data['cashDrawer'] as Map?)?['version'] !=
          cash['version']) {
        throw StateError(
            'Cash drawer changed. Refresh and review the report again.');
      }
      if (current.watermark != reviewed.watermark ||
          current.data['creditNoteWatermark'] !=
              reviewed.data['creditNoteWatermark'] ||
          current.previousZ != reviewed.previousZ) {
        throw StateError(
            'Sales or closeouts changed. Refresh the X reading and review it again.');
      }
      final z = ReadingSnapshot(
          {...current.data, 'type': 'Z', 'zNumber': current.previousZ + 1});
      await db.customStatement(
          'INSERT INTO fiscal_z_readings(terminal_id,branch_id,z_no,business_day,snapshot_json) VALUES(?,?,?,?,?)',
          [z.terminalId, z.branchId, z.zNumber, z.day, jsonEncode(z.data)]);
      await _audit(actorId, z, 'reading.z_closed');
      return z;
    });
  }

  Future<void> recordOutputRequest(
      {required String actorId, required ReadingSnapshot reading}) async {
    await _authorize(actorId, reading.branchId, reading.terminalId,
        PosPermission.viewTerminalReading);
    var canonical = reading;
    if (reading.isZ) {
      canonical = (await _history(reading.terminalId))
          .firstWhere((r) => r.zNumber == reading.zNumber);
    }
    await _audit(actorId, canonical,
        'reading.${canonical.isZ ? 'z' : 'x'}_copy_requested');
  }

  Future<void> _audit(String actor, ReadingSnapshot r, String type) =>
      AuditTrailRepository(db)
          .append(
              branchId: r.branchId,
              terminalId: r.terminalId,
              actorId: actor,
              eventType: type,
              entityType: 'terminal_reading',
              entityId: '${r.terminalId}:${r.day}:${r.data['type']}',
              payloadJson: jsonEncode(r.data),
              occurredAt: clock())
          .then((_) {});

  Future<ReadingSnapshot> _build(StaffPrincipal actor, String branch,
      String terminal, String day, List<ReadingSnapshot> history) async {
    final rows = await db.customSelect('''SELECT e.id AS event_id,e.kind,i.*,
      COALESCE((SELECT SUM(l.discount_centavos) FROM invoice_lines l WHERE l.invoice_id=i.id),0) AS discount
      FROM fiscal_reading_events e JOIN invoices i ON i.id=e.invoice_id
      WHERE i.terminal_id=? AND i.branch_id=? AND e.business_day=? ORDER BY e.id''',
        variables: [Variable(terminal), Variable(branch), Variable(day)]).get();
    final totals = {
      for (final k in [
        'gross',
        'discount',
        'sales',
        'void',
        'net',
        'vatable',
        'vat',
        'exempt',
        'zero',
        'nonVat'
      ])
        k: 0
    };
    final payments = <String, int>{};
    final statutoryTotals = <String, int>{};
    final saleNumbers = <String>[], voidNumbers = <String>[];
    for (final r in rows) {
      final isSale = r.read<String>('kind') == 'sale';
      final sign = isSale ? 1 : -1;
      final benefit = (await InvoiceParticularsRepository(db)
          .read(r.read<String>('id')))['statutoryDiscount'] as Map?;
      if (benefit != null) {
        final claim = benefit['claim'] as Map;
        final key = '${claim['kind']}.${claim['scheme']}';
        statutoryTotals['$key.discount'] =
            (statutoryTotals['$key.discount'] ?? 0) +
                sign * (benefit['discountCentavos'] as int);
        statutoryTotals['$key.vatRelief'] =
            (statutoryTotals['$key.vatRelief'] ?? 0) +
                sign * (benefit['vatReliefCentavos'] as int);
      }
      final total = r.read<int>('total_centavos');
      if (isSale) {
        saleNumbers.add(r.read<String>('invoice_number'));
        totals['sales'] = totals['sales']! + total;
        totals['discount'] = totals['discount']! + r.read<int>('discount');
        totals['gross'] = totals['gross']! + total + r.read<int>('discount');
      } else {
        voidNumbers.add(r.read<String>('invoice_number'));
        totals['void'] = totals['void']! + total;
      }
      totals['net'] = totals['net']! + sign * total;
      const taxColumns = {
        'vatable': 'vatable_sales_centavos',
        'vat': 'vat_amount_centavos',
        'exempt': 'vat_exempt_sales_centavos',
        'zero': 'zero_rated_sales_centavos',
        'nonVat': 'non_vat_sales_centavos'
      };
      for (final e in taxColumns.entries) {
        totals[e.key] = totals[e.key]! + sign * r.read<int>(e.value);
      }
      final method = r.read<String>('payment_method');
      payments[method] = (payments[method] ?? 0) + sign * total;
    }
    final creditRows = await db.customSelect(
        'SELECT id,sequence,number,snapshot_json FROM credit_notes WHERE branch_id=? AND terminal_id=? AND business_day=? ORDER BY sequence',
        variables: [Variable(branch), Variable(terminal), Variable(day)]).get();
    var creditTotal = 0;
    for (final row in creditRows) {
      final credit = jsonDecode(row.read<String>('snapshot_json')) as Map;
      final amounts = credit['totals'] as Map;
      creditTotal += amounts['total'] as int;
      for (final key in ['vatable', 'vat', 'exempt', 'zero', 'nonVat']) {
        totals[key] = totals[key]! - (amounts[key] as int);
      }
      if (credit['statutoryClaim'] != null) {
        final claim = credit['statutoryClaim'] as Map;
        final key = '${claim['kind']}.${claim['scheme']}';
        statutoryTotals['$key.discount'] =
            (statutoryTotals['$key.discount'] ?? 0) -
                (amounts['discount'] as int);
        statutoryTotals['$key.vatRelief'] =
            (statutoryTotals['$key.vatRelief'] ?? 0) -
                (amounts['vatRelief'] as int);
      }
    }
    totals['net'] = totals['net']! - creditTotal;
    if (creditRows.isNotEmpty) {
      payments['cash'] = (payments['cash'] ?? 0) - creditTotal;
    }
    final t = await (db.select(db.terminals)
          ..where((t) => t.id.equals(terminal)))
        .getSingle();
    final b = await (db.select(db.branches)..where((b) => b.id.equals(branch)))
        .getSingle();
    final registration = await CompanyRegistrationRepository(db).read();
    final oldGrand =
        history.isEmpty ? 0 : history.first.data['newGrandTotal'] as int;
    return ReadingSnapshot({
      'version': 1,
      'type': 'X',
      'zNumber': 0,
      'previousZ': history.isEmpty ? 0 : history.first.zNumber,
      'businessDay': day,
      'terminalId': terminal,
      'branchId': branch,
      'generatedAt': clock().toUtc().toIso8601String(),
      'actorId': actor.id,
      'actorName': actor.displayName,
      'eventWatermark': rows.isEmpty ? 0 : rows.last.read<int>('event_id'),
      'saleCount': saleNumbers.length,
      'voidCount': voidNumbers.length,
      'firstInvoice': saleNumbers.firstOrNull,
      'lastInvoice': saleNumbers.lastOrNull,
      'voidInvoices': voidNumbers,
      'totals': totals,
      'payments': payments,
      'creditNoteWatermark':
          creditRows.isEmpty ? 0 : creditRows.last.read<int>('sequence'),
      'creditNoteTotal': creditTotal,
      'creditNotes': creditRows.map((r) => r.read<String>('number')).toList(),
      if (statutoryTotals.isNotEmpty) 'statutoryTotals': statutoryTotals,
      'cashDrawer': await _cashState(branch, terminal, day),
      'oldGrandTotal': oldGrand,
      'newGrandTotal': oldGrand + totals['net']!,
      'seller': {
        'name': registration?.registeredName ?? 'TRAINING MERCHANT',
        'tin': registration?.tin ?? 'NOT REGISTERED',
        'address': registration?.address ?? 'TRAINING',
        'branchCode': registration?.branchCode ?? b.code,
        'terminalCode': t.code,
        'min': t.machineIdentificationNumber,
        'ptu': t.permitToUseNumber,
        'serial': t.machineSerialNumber,
        'rdo': registration?.rdo ?? 'TRAINING',
        'ptuDate': registration?.ptuIssuedOn ?? 'TRAINING',
        'training': registration == null
      },
    });
  }
}
