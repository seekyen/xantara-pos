part of 'terminal_closeout_repository.dart';

class DailyJournalExport {
  const DailyJournalExport(
      this.text, this.documentCount, this.reconstructedCount);
  final String text;
  final int documentCount, reconstructedCount;
}

extension DailyJournalRepository on TerminalCloseoutRepository {
  Future<DailyJournalExport> exportJournal(
          {required String actorId,
          required String branchId,
          required String terminalId,
          required String day}) =>
      db.transaction(() async {
        _validateDay(day);
        final actor = await _authorize(
            actorId, branchId, terminalId, PosPermission.viewTerminalReading);
        final verification =
            await AuditTrailRepository(db).verifyBranch(branchId);
        if (!verification.isValid) {
          throw StateError(
              'Audit verification failed at record ${verification.brokenSequence}. '
              'Journal export stopped; preserve this database for review. '
              'Older records may have lost timestamp precision.');
        }
        // Older versions did not capture documents. Reconstruct once, with provenance.
        final audits = await (db.select(db.auditEvents)
              ..where((e) =>
                  e.branchId.equals(branchId) & e.terminalId.equals(terminalId))
              ..orderBy([(e) => OrderingTerm.asc(e.sequence)]))
            .get();
        for (final event in audits) {
          await captureJournalDocument(db, event, reconstructed: true);
        }
        final rows = await db.customSelect(
            'SELECT * FROM journal_documents WHERE branch_id=? AND terminal_id=? AND business_day=? ORDER BY occurred_at,id',
            variables: [
              Variable(branchId),
              Variable(terminalId),
              Variable(day)
            ]).get();
        final docs = <Map<String, dynamic>>[];
        final auditById = {for (final e in audits) e.id: e};
        final counts = <String, int>{};
        var sales = 0, voids = 0, reconstructed = 0;
        const taxFields = {
          'vatable': 'vatableSalesCentavos',
          'vat': 'vatAmountCentavos',
          'exempt': 'vatExemptSalesCentavos',
          'zero': 'zeroRatedSalesCentavos',
          'nonVat': 'nonVatSalesCentavos'
        };
        final journalTotals = {
          for (final key in [...taxFields.keys, 'gross', 'discount']) key: 0
        };
        final issueIds = <String>{}, voidIds = <String>{};
        final creditIds = <String>{};
        var creditTotal = 0;
        final benefitTotals = <String, int>{};
        final manifest = StringBuffer();
        for (final row in rows) {
          final raw = row.read<String>('snapshot_json');
          final digest = sha256.convert(utf8.encode(raw)).toString();
          if (digest != row.read<String>('sha256')) {
            throw StateError('Journal document hash mismatch.');
          }
          final d = jsonDecode(raw) as Map<String, dynamic>;
          final source = auditById[row.read<String>('source_id')];
          if (source == null ||
              source.eventHash != d['sourceAuditHash'] ||
              d['businessDay'] != day ||
              d['branchId'] != branchId ||
              d['terminalId'] != terminalId) {
            throw StateError('Journal source or scope verification failed.');
          }
          if (d['error'] != null) {
            throw StateError(
                'Journal record ${row.read<String>('source_id')}: ${d['error']}');
          }
          docs.add(d);
          final kind = d['type'] as String;
          counts[kind] = (counts[kind] ?? 0) + 1;
          if (d['provenance'] != 'CAPTURED AT EVENT') reconstructed++;
          if (kind == 'invoice.issued' || kind == 'invoice.voided') {
            final invoice = d['invoice'] as Map;
            final total = invoice['totalCentavos'] as int;
            final lines = d['lines'] as List;
            final benefit =
                (d['particulars'] as Map?)?['statutoryDiscount'] as Map?;
            if (benefit != null) {
              final claim = benefit['claim'] as Map;
              final key = '${claim['kind']}.${claim['scheme']}';
              final sign = kind == 'invoice.issued' ? 1 : -1;
              benefitTotals['$key.discount'] =
                  (benefitTotals['$key.discount'] ?? 0) +
                      sign * (benefit['discountCentavos'] as int);
              benefitTotals['$key.vatRelief'] =
                  (benefitTotals['$key.vatRelief'] ?? 0) +
                      sign * (benefit['vatReliefCentavos'] as int);
              for (final line in lines) {
                final relief = ((benefit['lines'] as Map)[line['productId']]
                    as Map)['vatReliefCentavos'] as int;
                if ((line['unitPriceCentavos'] as int) *
                            (line['quantity'] as int) -
                        (line['discountCentavos'] as int) -
                        relief !=
                    line['lineTotalCentavos']) {
                  throw StateError('Statutory invoice lines do not reconcile.');
                }
              }
            }
            final lineTotal = lines.fold<int>(
                0, (v, l) => v + (l['lineTotalCentavos'] as int));
            if (lineTotal != total ||
                (d['payment'] as Map)['amountCentavos'] != total) {
              throw StateError(
                  'Invoice ${invoice['invoiceNumber']} does not reconcile.');
            }
            if (kind == 'invoice.issued') {
              final discount = lines.fold<int>(
                  0, (v, l) => v + (l['discountCentavos'] as int));
              journalTotals['discount'] = journalTotals['discount']! + discount;
              journalTotals['gross'] =
                  journalTotals['gross']! + total + discount;
              sales += total;
              issueIds.add(d['entityId'] as String);
            } else {
              voids += total;
              voidIds.add(d['entityId'] as String);
            }
            for (final field in taxFields.entries) {
              journalTotals[field.key] = journalTotals[field.key]! +
                  (kind == 'invoice.issued' ? 1 : -1) *
                      (invoice[field.value] as int);
            }
          }
          if (kind == 'credit_note.issued') {
            final note = d['creditNote'] as Map;
            final amounts = note['totals'] as Map;
            final noteLines = note['lines'] as List;
            if (noteLines.fold<int>(
                    0, (n, l) => n + ((l['amounts'] as Map)['total'] as int)) !=
                amounts['total']) {
              throw StateError('Credit note line totals do not reconcile.');
            }
            creditIds.add(d['entityId'] as String);
            creditTotal += amounts['total'] as int;
            for (final key in taxFields.keys) {
              journalTotals[key] = journalTotals[key]! - (amounts[key] as int);
            }
            if (note['statutoryClaim'] != null) {
              final claim = note['statutoryClaim'] as Map;
              final key = '${claim['kind']}.${claim['scheme']}';
              benefitTotals['$key.discount'] =
                  (benefitTotals['$key.discount'] ?? 0) -
                      (amounts['discount'] as int);
              benefitTotals['$key.vatRelief'] =
                  (benefitTotals['$key.vatRelief'] ?? 0) -
                      (amounts['vatRelief'] as int);
            }
          }
          manifest.writeln('${d['sourceAuditId']} $digest');
        }
        final ledger = await db.customSelect(
            '''SELECT e.invoice_id,e.kind FROM fiscal_reading_events e JOIN invoices i ON i.id=e.invoice_id
      WHERE i.branch_id=? AND i.terminal_id=? AND e.business_day=?''',
            variables: [Variable(branchId), Variable(terminalId), Variable(day)]).get();
        final ledgerIssues = ledger
            .where((r) => r.read<String>('kind') == 'sale')
            .map((r) => r.read<String>('invoice_id'))
            .toSet();
        final ledgerVoids = ledger
            .where((r) => r.read<String>('kind') == 'void')
            .map((r) => r.read<String>('invoice_id'))
            .toSet();
        bool same(Set<String> a, Set<String> b) =>
            a.length == b.length && a.containsAll(b);
        if (!same(issueIds, ledgerIssues) ||
            !same(voidIds, ledgerVoids) ||
            (counts['invoice.issued'] ?? 0) != issueIds.length ||
            (counts['invoice.voided'] ?? 0) != voidIds.length) {
          throw StateError(
              'Journal invoice/void coverage does not match the fiscal ledger.');
        }
        final history = await _history(terminalId);
        final creditRows = await db.customSelect(
            'SELECT id,total_centavos FROM credit_notes WHERE branch_id=? AND terminal_id=? AND business_day=?',
            variables: [
              Variable(branchId),
              Variable(terminalId),
              Variable(day)
            ]).get();
        if (!same(creditIds,
                creditRows.map((r) => r.read<String>('id')).toSet()) ||
            (counts['credit_note.issued'] ?? 0) != creditIds.length ||
            creditTotal !=
                creditRows.fold<int>(
                    0, (n, r) => n + r.read<int>('total_centavos'))) {
          throw StateError('Credit note coverage does not match the journal.');
        }
        final cashCount = await db.customSelect(
            'SELECT COUNT(*) AS n FROM cash_drawer_events WHERE branch_id=? AND terminal_id=? AND business_day=?',
            variables: [
              Variable(branchId),
              Variable(terminalId),
              Variable(day)
            ]).getSingle();
        if (docs
                .where((d) => (d['type'] as String).startsWith('cash_drawer.'))
                .length !=
            cashCount.read<int>('n')) {
          throw StateError(
              'Journal cash records do not match the drawer ledger.');
        }
        final snapshot =
            await _build(actor, branchId, terminalId, day, history);
        final savedZ = history.where((r) => r.day == day).firstOrNull;
        bool sameBenefits(Map a, Map b) =>
            a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
        if (!sameBenefits(benefitTotals,
                snapshot.data['statutoryTotals'] as Map? ?? {}) ||
            (savedZ != null &&
                !sameBenefits(benefitTotals,
                    savedZ.data['statutoryTotals'] as Map? ?? {}))) {
          throw StateError(
              'Beneficiary totals do not reconcile with the journal and saved Z.');
        }
        if (sales != snapshot.totals['sales'] ||
            voids != snapshot.totals['void'] ||
            sales - voids - creditTotal != snapshot.totals['net'] ||
            creditTotal != (snapshot.data['creditNoteTotal'] ?? 0)) {
          throw StateError(
              'Journal totals do not reconcile with stored invoices.');
        }
        if (journalTotals.entries
                .any((e) => snapshot.totals[e.key] != e.value) ||
            (savedZ != null &&
                snapshot.totals.entries
                    .any((e) => savedZ.totals[e.key] != e.value))) {
          throw StateError(
              'Journal tax/discount totals do not reconcile with invoices or saved Z.');
        }
        if (savedZ != null &&
            (savedZ.totals['net'] != sales - voids - creditTotal ||
                (savedZ.data['creditNoteTotal'] ?? 0) != creditTotal ||
                (counts['reading.z_closed'] ?? 0) != 1)) {
          throw StateError('Saved Z does not reconcile with journal records.');
        }
        final b = StringBuffer('XANTARA DAILY ELECTRONIC JOURNAL - v1\n');
        b.writeln('Business date (Asia/Manila): $day');
        b.writeln('Branch: $branchId | Terminal: $terminalId');
        b.writeln(
            'Status: ${savedZ == null ? 'OPEN / AS-OF EXPORT' : 'CLOSED / Z #${savedZ.zNumber}'}');
        b.writeln(
            'Exported UTC: ${clock().toUtc().toIso8601String()} | Operator: ${actor.displayName}');
        b.writeln(
            'Documents: ${docs.length} | Reconstructed historical documents: $reconstructed');
        b.writeln(
            'Coverage: supported invoices, voids, credit notes, copy requests, X/Z readings and cash records.');
        b.writeln(
            'Copies are requests, not confirmation of physical printing. Only cash payouts linked to credit notes represent invoice refunds.');
        b.writeln(
            'Reading originals use their business date; reading copies and invoice reprints use the request date.');
        b.writeln(
            'Historical reconstructions are not proof of the exact original printed layout.');
        b.writeln(
            'Internal inspection-preparation export; field/layout compliance review remains pending.');
        if (docs.isEmpty) b.writeln('NO JOURNAL DOCUMENTS FOR THIS DAY');
        for (var i = 0; i < docs.length; i++) {
          final d = docs[i];
          b.writeln('\n========== DOCUMENT ${i + 1}: ${d['type']} ==========');
          b.writeln('Source audit: ${d['sourceAuditId']} | ${d['provenance']}');
          b.writeln(
              'UTC: ${d['occurredAtUtc']} | Actor: ${d['actorName']} (${d['actorId']})');
          if (d['invoiceText'] != null) b.writeln(d['invoiceText']);
          if (d['creditNoteText'] != null) b.writeln(d['creditNoteText']);
          if ((d['type'] as String).startsWith('reading.')) {
            b.writeln(
                ReadingSnapshot(Map<String, dynamic>.from(d['event'] as Map))
                    .format(reprint: (d['type'] as String).contains('copy')));
          }
          b.writeln(
              'FULL STORED FIELDS (money fields suffixed Centavos are integer centavos):');
          b.writeln(const JsonEncoder.withIndent('  ')
              .convert({...d}..remove('invoiceText')));
          b.writeln('========== END DOCUMENT ${i + 1} ==========');
        }
        b.writeln('\nRECONCILIATION: PASS');
        b.writeln('Issued: ${issueIds.length} | Voids: ${voidIds.length}');
        b.writeln(
            'Sales PHP ${(sales / 100).toStringAsFixed(2)} | Voids PHP ${(voids / 100).toStringAsFixed(2)} | Credit notes PHP ${(creditTotal / 100).toStringAsFixed(2)} | Net PHP ${((sales - voids - creditTotal) / 100).toStringAsFixed(2)}');
        b.writeln('DOCUMENT COUNTS: ${jsonEncode(counts)}');
        b.writeln('REPORT TOTALS AT EXPORT (not an additional X/Z document):');
        b.writeln((savedZ ?? snapshot).format());
        b.writeln(
            'DOCUMENT MANIFEST (audit id / snapshot SHA-256):\n$manifest');
        b.writeln(
            'Manifest SHA-256: ${sha256.convert(utf8.encode(manifest.toString()))}');
        final result = b.toString();
        await AuditTrailRepository(db).append(
            branchId: branchId,
            terminalId: terminalId,
            actorId: actor.id,
            eventType: 'journal.export_requested',
            entityType: 'daily_journal',
            entityId: '$terminalId:$day',
            payloadJson: jsonEncode({
              'day': day,
              'documents': docs.length,
              'reconstructed': reconstructed,
              'exportSha256': sha256.convert(utf8.encode(result)).toString()
            }),
            occurredAt: clock());
        return DailyJournalExport(result, docs.length, reconstructed);
      });

  Future<DateTime> recordInvoicePdfCopy(
          {required String actorId, required String invoiceId}) =>
      db.transaction(() async {
        final invoice = await (db.select(db.invoices)
              ..where((i) => i.id.equals(invoiceId)))
            .getSingle();
        await _authorize(actorId, invoice.branchId, invoice.terminalId,
            PosPermission.createSale);
        final requestedAt = clock();
        await AuditTrailRepository(db).append(
            branchId: invoice.branchId,
            terminalId: invoice.terminalId,
            actorId: actorId,
            eventType: 'invoice.pdf_copy_requested',
            entityType: 'invoice',
            entityId: invoiceId,
            payloadJson: jsonEncode({
              'invoiceId': invoiceId,
              'invoiceNumber': invoice.invoiceNumber,
              'output': 'PDF copy request'
            }),
            occurredAt: requestedAt);
        return requestedAt;
      });
}
