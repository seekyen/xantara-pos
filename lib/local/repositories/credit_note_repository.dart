import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/pos_authorization.dart';
import '../../core/compliance/bir_invoice.dart' as bir;
import '../../core/compliance/credit_note.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'company_registration_repository.dart';
import 'invoice_assembler.dart';
import 'invoice_particulars_repository.dart';
import 'staff_auth_repository.dart';
import 'terminal_closeout_repository.dart';

class ReturnLineRequest {
  const ReturnLineRequest(this.lineId, this.quantity, {this.restock = false});
  final String lineId;
  final int quantity;
  final bool restock;
  Map<String, dynamic> toJson() =>
      {'lineId': lineId, 'quantity': quantity, 'restock': restock};
}

class ReturnContext {
  ReturnContext(this.invoice, this.lines, this.returned, this.notes);
  final bir.BirInvoice invoice;
  final List<InvoiceLine> lines;
  final Map<String, int> returned;
  final List<Map<String, dynamic>> notes;
}

class CreditNoteRepository {
  CreditNoteRepository(this.db,
      {StaffAuthRepository? staff, DateTime Function()? clock})
      : staff = staff ?? StaffAuthRepository(db),
        clock = clock ?? DateTime.now;
  final AppDatabase db;
  final StaffAuthRepository staff;
  final DateTime Function() clock;

  Future<StaffPrincipal> _authorize(
      String actorId, String branch, PosPermission permission) async {
    final user = await (db.select(db.staffUsers)
          ..where((u) => u.id.equals(actorId)))
        .getSingleOrNull();
    final access = await (db.select(db.staffBranchAccess)
          ..where(
              (a) => a.staffUserId.equals(actorId) & a.branchId.equals(branch)))
        .getSingleOrNull();
    if (user == null || !user.isActive || access == null) {
      throw const AuthorizationException('No access to the invoice branch.');
    }
    final actor = StaffPrincipal(
        id: user.id,
        displayName: user.displayName,
        email: user.emailNormalized,
        role: StaffRole.values.byName(user.role),
        branchIds: {branch});
    const PosAuthorizationPolicy().require(actor, permission, branchId: branch);
    return actor;
  }

  Future<ReturnContext> inspect(
      {required String invoiceId, required String actorId}) async {
    final original = await (db.select(db.invoices)
          ..where((i) => i.id.equals(invoiceId)))
        .getSingle();
    await _authorize(actorId, original.branchId, PosPermission.createSale);
    if (!(await AuditTrailRepository(db).verifyBranch(original.branchId))
        .isValid) {
      throw StateError('Original invoice audit trail failed verification.');
    }
    final lines = await (db.select(db.invoiceLines)
          ..where((l) => l.invoiceId.equals(invoiceId))
          ..orderBy([(l) => OrderingTerm.asc(l.id)]))
        .get();
    final particulars = await InvoiceParticularsRepository(db).read(invoiceId);
    final events = await (db.select(db.auditEvents)
          ..where((e) =>
              e.entityId.equals(invoiceId) &
              e.eventType.equals('invoice.issued')))
        .get();
    if (events.length != 1) {
      throw StateError('Original invoice evidence is unavailable.');
    }
    final issued = jsonDecode(events.single.payloadJson) as Map;
    if (issued['particularsHash'] != null &&
        issued['particularsHash'] !=
            particularsHash(particulars,
                name: original.buyerName,
                tin: original.buyerTin,
                address: original.buyerAddress)) {
      throw StateError('Original invoice particulars failed verification.');
    }
    final invoice = assembleInvoice(original, lines, particulars: particulars);
    final evidence = issued['lines'];
    if (evidence is! List || evidence.length != invoice.lines.length) {
      throw StateError('Original invoice line evidence is unavailable.');
    }
    for (final line in invoice.lines) {
      final matches =
          evidence.where((e) => e['productId'] == line.productId).toList();
      if (matches.length != 1 ||
          matches.single['quantity'] != line.quantity ||
          matches.single['unitPriceCentavos'] != line.unitPriceCentavos ||
          matches.single['discountCentavos'] != line.discountCentavos ||
          (matches.single['vatReliefCentavos'] ?? 0) !=
              line.vatReliefCentavos ||
          matches.single['taxCategory'] != line.taxCategory.name ||
          matches.single['lineTotalCentavos'] != line.netCentavos) {
        throw StateError('Original invoice lines failed verification.');
      }
    }
    if (invoice.lines.fold<int>(0, (n, l) => n + l.netCentavos) !=
            invoice.totalCentavos ||
        issued['totalCentavos'] != invoice.totalCentavos) {
      throw StateError('Original invoice amounts do not reconcile.');
    }
    final notes = await db.customSelect(
        'SELECT snapshot_json FROM credit_notes WHERE invoice_id=? ORDER BY sequence',
        variables: [Variable(invoiceId)]).get();
    final snapshots = notes
        .map((r) =>
            jsonDecode(r.read<String>('snapshot_json')) as Map<String, dynamic>)
        .toList();
    final returned = <String, int>{};
    for (final note in snapshots) {
      for (final line in note['lines'] as List) {
        final id = line['lineId'] as String;
        returned[id] = (returned[id] ?? 0) + (line['quantity'] as int);
      }
    }
    return ReturnContext(invoice, lines, returned, snapshots);
  }

  Map<String, dynamic> quote(
      ReturnContext context, List<ReturnLineRequest> requested) {
    if (requested.isEmpty ||
        requested.map((r) => r.lineId).toSet().length != requested.length) {
      throw ArgumentError('Choose each returned invoice line once.');
    }
    final lines = <Map<String, dynamic>>[];
    final totals = {
      for (final k in [
        'total',
        'discount',
        'vatRelief',
        'vatable',
        'vat',
        'exempt',
        'zero',
        'nonVat'
      ])
        k: 0
    };
    for (final r in requested) {
      final index = context.lines.indexWhere((l) => l.id == r.lineId);
      if (index < 0) {
        throw ArgumentError('A return line is not on the original invoice.');
      }
      final source = context.invoice.lines[index];
      final amounts =
          creditPortion(source, context.returned[r.lineId] ?? 0, r.quantity);
      for (final e in amounts.entries) {
        totals[e.key] = totals[e.key]! + e.value;
      }
      lines.add({
        ...r.toJson(),
        'productId': source.productId,
        'description': source.description,
        'originalQuantity': source.quantity,
        'originalUnitPriceCentavos': source.unitPriceCentavos,
        'taxCategory': source.taxCategory.name,
        'amounts': amounts
      });
    }
    if (totals['total']! <= 0) {
      throw ArgumentError('The selected items have no refundable amount.');
    }
    return {'lines': lines, 'totals': totals};
  }

  Future<Map<String, dynamic>> issue(
      {required String invoiceId,
      required String actorId,
      required String supervisorEmail,
      required String supervisorPassword,
      required String requestKey,
      required String reason,
      required List<ReturnLineRequest> lines,
      required int expectedTotalCentavos,
      required bool cashRefundConfirmed}) async {
    final requested = List<ReturnLineRequest>.unmodifiable(lines);
    final cleanReason = reason.trim();
    if (!cashRefundConfirmed ||
        cleanReason.isEmpty ||
        cleanReason.length > 500 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(cleanReason) ||
        requestKey.isEmpty ||
        requestKey.length > 100) {
      throw ArgumentError('Confirm the cash refund and enter a valid reason.');
    }
    final supervisor = await staff.authenticate(
        email: supervisorEmail, password: supervisorPassword, now: clock());
    final sorted = requested.toList()
      ..sort((a, b) => a.lineId.compareTo(b.lineId));
    final fingerprint = sha256
        .convert(utf8.encode(jsonEncode({
          'invoiceId': invoiceId,
          'actorId': actorId,
          'reason': cleanReason,
          'lines': sorted.map((l) => l.toJson()).toList(),
          'expectedTotal': expectedTotalCentavos,
          'supervisorId': supervisor.id
        })))
        .toString();
    return db.transaction(() async {
      final original = await (db.select(db.invoices)
            ..where((i) => i.id.equals(invoiceId)))
          .getSingle();
      final actor = await _authorize(
          actorId, original.branchId, PosPermission.createSale);
      await _authorize(
          supervisor.id, original.branchId, PosPermission.issueCreditNote);
      final retry = await db.customSelect(
          'SELECT request_hash,snapshot_json FROM credit_notes WHERE request_key=?',
          variables: [Variable(requestKey)]).getSingleOrNull();
      if (retry != null) {
        if (retry.read<String>('request_hash') != fingerprint) {
          throw StateError(
              'This return request key belongs to different details.');
        }
        return jsonDecode(retry.read<String>('snapshot_json'))
            as Map<String, dynamic>;
      }
      final registration = await CompanyRegistrationRepository(db).read();
      final terminal = await (db.select(db.terminals)
            ..where((t) => t.id.equals(original.terminalId)))
          .getSingle();
      if (!terminal.isActive ||
          (db.requireRegistration &&
              (registration == null || !registration.isActive)) ||
          (registration != null &&
              (registration.terminalId != original.terminalId ||
                  !registration.isActive))) {
        throw StateError(
            'Use the active terminal that issued the original invoice.');
      }
      if (original.status != 'issued' || original.paymentMethod != 'cash') {
        throw StateError(
            'Only issued cash invoices support this return workflow.');
      }
      if (await (db.select(db.invoiceLoyalty)
                ..where((l) => l.invoiceId.equals(invoiceId)))
              .getSingleOrNull() !=
          null) {
        throw StateError(
            'This invoice has loyalty settlement. Linked loyalty returns require a separate settlement workflow.');
      }
      final now = clock();
      if (now.isBefore(original.issuedAt)) {
        throw StateError('A credit note cannot precede its original invoice.');
      }
      final context = await inspect(invoiceId: invoiceId, actorId: actorId);
      final amounts = quote(context, requested);
      final total = (amounts['totals'] as Map)['total'] as int;
      if (total != expectedTotalCentavos) {
        throw StateError(
            'Remaining return amounts changed. Review the invoice again.');
      }
      final reports =
          TerminalCloseoutRepository(db, clock: () => now, staff: staff);
      final reading = await reports.xReading(
          actorId: actorId,
          branchId: original.branchId,
          terminalId: original.terminalId,
          day: manilaBusinessDay(now));
      if ((reading.data['cashDrawer'] as Map)['started'] != true) {
        throw StateError(
            'Record the opening float before recording a cash refund.');
      }
      await db.customStatement(
          'INSERT OR IGNORE INTO credit_note_sequences(terminal_id,next_value) VALUES(?,1)',
          [terminal.id]);
      final seq = (await db.customSelect(
              'SELECT next_value FROM credit_note_sequences WHERE terminal_id=?',
              variables: [Variable(terminal.id)]).getSingle())
          .read<int>('next_value');
      final id = const Uuid().v4();
      final number =
          '${original.branchCode}-${terminal.code}-CN-${seq.toString().padLeft(8, '0')}';
      final note = <String, dynamic>{
        'version': 1,
        'id': id,
        'number': number,
        'invoiceId': invoiceId,
        'invoiceNumber': original.invoiceNumber,
        'branchId': original.branchId,
        'terminalId': original.terminalId,
        'businessDay': reading.day,
        'issuedAt': now.toUtc().toIso8601String(),
        'actorId': actor.id,
        'actorName': actor.displayName,
        'supervisorId': supervisor.id,
        'supervisorName': supervisor.displayName,
        'reason': cleanReason,
        'settlement': 'cashRefundRecorded',
        'buyer': original.buyerName,
        'seller': {
          'name': original.sellerName,
          'tin': original.sellerTin,
          'address': original.sellerAddress,
          'branchCode': original.branchCode,
          'terminalCode': terminal.code,
          'min': original.machineIdentificationNumber,
          'ptu': original.permitToUseNumber
        },
        if (context.invoice.statutoryDiscount.isNotEmpty)
          'statutoryClaim': context.invoice.statutoryDiscount['claim'],
        ...amounts
      };
      await db.customStatement(
          'INSERT INTO credit_notes(id,invoice_id,branch_id,terminal_id,sequence,number,business_day,issued_at,total_centavos,request_key,request_hash,snapshot_json) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            id,
            invoiceId,
            original.branchId,
            original.terminalId,
            seq,
            number,
            reading.day,
            now.millisecondsSinceEpoch ~/ 1000,
            total,
            requestKey,
            fingerprint,
            jsonEncode(note)
          ]);
      await db.customStatement(
          'UPDATE credit_note_sequences SET next_value=next_value+1 WHERE terminal_id=?',
          [terminal.id]);
      for (final r in requested.where((r) => r.restock)) {
        final line = context.lines.firstWhere((l) => l.id == r.lineId);
        final inventory = await (db.select(db.branchInventories)
              ..where((i) =>
                  i.branchId.equals(original.branchId) &
                  i.productId.equals(line.productId)))
            .getSingle();
        final balance = inventory.stockOnHand + r.quantity;
        await (db.update(db.branchInventories)
              ..where((i) =>
                  i.branchId.equals(original.branchId) &
                  i.productId.equals(line.productId)))
            .write(BranchInventoriesCompanion(
                stockOnHand: Value(balance),
                version: Value(inventory.version + 1),
                updatedAt: Value(now)));
        await db.into(db.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
                id: const Uuid().v4(),
                branchId: original.branchId,
                productId: line.productId,
                type: 'sale_return',
                quantityDelta: r.quantity,
                balanceAfter: balance,
                referenceType: 'credit_note',
                referenceId: id,
                occurredAt: now));
      }
      await reports.recordCash(
          actorId: actorId,
          reading: reading,
          kind: 'refund',
          amountCentavos: total,
          note: '$number: $cleanReason',
          creditNoteId: id);
      await AuditTrailRepository(db).append(
          branchId: original.branchId,
          terminalId: terminal.id,
          actorId: actorId,
          eventType: 'credit_note.issued',
          entityType: 'credit_note',
          entityId: id,
          payloadJson: jsonEncode(note),
          occurredAt: now);
      await db.into(db.syncOutboxEvents).insert(
          SyncOutboxEventsCompanion.insert(
              id: const Uuid().v4(),
              branchId: original.branchId,
              aggregateType: 'credit_note',
              aggregateId: id,
              eventType: 'credit_note.issued',
              idempotencyKey: 'credit_note.issued:$id',
              payloadJson: jsonEncode(note),
              createdAt: now));
      return note;
    });
  }

  Future<String> copyText({required String noteId, required String actorId}) =>
      db.transaction(() async {
        final row = await db.customSelect(
            'SELECT * FROM credit_notes WHERE id=?',
            variables: [Variable(noteId)]).getSingle();
        await _authorize(
            actorId, row.read<String>('branch_id'), PosPermission.createSale);
        final note = jsonDecode(row.read<String>('snapshot_json'))
            as Map<String, dynamic>;
        await AuditTrailRepository(db).append(
            branchId: row.read<String>('branch_id'),
            terminalId: row.read<String>('terminal_id'),
            actorId: actorId,
            eventType: 'credit_note.copy_requested',
            entityType: 'credit_note',
            entityId: noteId,
            payloadJson: jsonEncode({'id': noteId, 'number': note['number']}),
            occurredAt: clock());
        return formatCreditNote(note, copy: true);
      });
}
