import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../core/hardware/pos_hardware.dart';
import '../database.dart';
import 'invoice_assembler.dart';
import 'invoice_particulars_repository.dart';
import '../../core/compliance/credit_note.dart';

bool isJournalEvent(String type) => const {
      'invoice.issued',
      'credit_note.issued',
      'credit_note.copy_requested',
      'invoice.voided',
      'invoice.reprint_requested',
      'invoice.pdf_copy_requested',
      'reading.x_generated',
      'reading.z_closed',
      'reading.x_copy_requested',
      'reading.z_copy_requested',
      'cash_drawer.opening',
      'cash_drawer.cash_in',
      'cash_drawer.cash_out',
      'cash_drawer.refund',
      'cash_drawer.count',
      'cash_drawer.review'
    }.contains(type);

/// Called inside the same transaction as the audit and underlying operation.
Future<void> captureJournalDocument(AppDatabase db, AuditEvent event,
    {bool reconstructed = false}) async {
  if (!isJournalEvent(event.eventType) || event.terminalId == null) return;
  final found = await db.customSelect(
      'SELECT id FROM journal_documents WHERE source_id=?',
      variables: [Variable(event.id)]).get();
  if (found.isNotEmpty) return;
  final payload = jsonDecode(event.payloadJson) as Map<String, dynamic>;
  final actor = await (db.select(db.staffUsers)
        ..where((s) => s.id.equals(event.actorId)))
      .getSingleOrNull();
  final document = <String, dynamic>{
    'schema': 1,
    'sourceAuditId': event.id,
    'sourceAuditHash': event.eventHash,
    'type': event.eventType,
    'entityId': event.entityId,
    'actorId': event.actorId,
    'actorName': actor?.displayName ?? event.actorId,
    'occurredAtUtc': event.occurredAt.toUtc().toIso8601String(),
    'provenance': reconstructed
        ? 'RECONSTRUCTED FROM STORED RECORDS'
        : 'CAPTURED AT EVENT',
    'event': payload
  };
  var day = event.occurredAt
      .toUtc()
      .add(const Duration(hours: 8))
      .toIso8601String()
      .substring(0, 10);
  if (event.eventType == 'reading.x_generated' ||
      event.eventType == 'reading.z_closed') {
    day = payload['businessDay'] as String;
  } else if (event.eventType.startsWith('cash_drawer.')) {
    day = event.entityId.substring(event.entityId.length - 10);
  }
  if (event.eventType.startsWith('invoice.')) {
    final row = await (db.select(db.invoices)
          ..where((i) => i.id.equals(event.entityId)))
        .getSingleOrNull();
    if (row == null ||
        row.branchId != event.branchId ||
        row.terminalId != event.terminalId) {
      document['error'] = 'Missing invoice or mismatched branch/terminal';
    } else {
      final lines = await (db.select(db.invoiceLines)
            ..where((l) => l.invoiceId.equals(row.id)))
          .get();
      final payment = await (db.select(db.payments)
            ..where((p) => p.invoiceId.equals(row.id)))
          .getSingleOrNull();
      var snapshotRow = row;
      // Preserve the issue-time document when backfilling an invoice later voided.
      if (event.eventType == 'invoice.issued' ||
          (row.voidedAt != null && event.occurredAt.isBefore(row.voidedAt!))) {
        snapshotRow = row.copyWith(
            status: 'issued',
            voidedAt: const Value(null),
            voidReason: const Value(null));
      }
      final header = snapshotRow.toJson()..remove('synced');
      document['invoice'] = header;
      final particulars = await InvoiceParticularsRepository(db).read(row.id);
      document['particulars'] = particulars;
      document['lines'] = lines.map((l) => l.toJson()).toList();
      document['payment'] = payment?.toJson();
      if (lines.isEmpty || payment == null) {
        document['error'] = 'Missing invoice lines or payment';
      } else {
        final issued = await (db.select(db.auditEvents)
              ..where((e) =>
                  e.entityId.equals(row.id) &
                  e.eventType.equals('invoice.issued'))
              ..orderBy([(e) => OrderingTerm.asc(e.sequence)])
              ..limit(1))
            .getSingleOrNull();
        final cashier = issued == null
            ? null
            : await (db.select(db.staffUsers)
                  ..where((s) => s.id.equals(issued.actorId)))
                .getSingleOrNull();
        final originalCashier = cashier?.displayName ??
            issued?.actorId ??
            'Original operator unavailable';
        document['originalCashierId'] = issued?.actorId;
        final issuePayload = issued == null
            ? <String, dynamic>{}
            : jsonDecode(issued.payloadJson) as Map<String, dynamic>;
        if (issuePayload['particularsHash'] != null &&
            issuePayload['particularsHash'] !=
                particularsHash(particulars,
                    name: row.buyerName,
                    tin: row.buyerTin,
                    address: row.buyerAddress)) {
          throw StateError('Invoice buyer or footer integrity check failed.');
        }
        document['originalCashierName'] = originalCashier;
        document['invoiceText'] = const BirReceiptFormatter().format(
            ReceiptPrintData(
                invoice: assembleInvoice(snapshotRow, lines,
                    particulars: particulars),
                payment: assemblePayment(payment),
                cashierName: originalCashier,
                isReprint: event.eventType.contains('copy') ||
                    event.eventType.contains('reprint'),
                reprintedAt: event.eventType.contains('copy') ||
                        event.eventType.contains('reprint')
                    ? event.occurredAt
                    : null));
      }
    }
  }
  if (event.eventType.startsWith('credit_note.')) {
    final credit = await db.customSelect(
        'SELECT snapshot_json,branch_id,terminal_id FROM credit_notes WHERE id=?',
        variables: [Variable(event.entityId)]).getSingle();
    if (credit.read<String>('branch_id') != event.branchId ||
        credit.read<String>('terminal_id') != event.terminalId) {
      throw StateError('Credit note scope mismatch.');
    }
    final note = jsonDecode(credit.read<String>('snapshot_json'))
        as Map<String, dynamic>;
    final originalEvent = await (db.select(db.auditEvents)
          ..where((a) =>
              a.entityId.equals(event.entityId) &
              a.eventType.equals('credit_note.issued')))
        .getSingle();
    if (originalEvent.payloadJson != credit.read<String>('snapshot_json')) {
      throw StateError('Credit note source verification failed.');
    }
    document['creditNote'] = note;
    document['creditNoteText'] =
        formatCreditNote(note, copy: event.eventType.contains('copy'));
  }
  document.addAll({
    'businessDay': day,
    'branchId': event.branchId,
    'terminalId': event.terminalId
  });
  final encoded = jsonEncode(document);
  await db.customStatement(
      'INSERT INTO journal_documents(source_id,branch_id,terminal_id,business_day,event_type,occurred_at,snapshot_json,sha256) VALUES(?,?,?,?,?,?,?,?)',
      [
        event.id,
        event.branchId,
        event.terminalId,
        day,
        event.eventType,
        event.occurredAt.toUtc().toIso8601String(),
        encoded,
        sha256.convert(utf8.encode(encoded)).toString()
      ]);
}
