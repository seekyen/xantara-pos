part of 'terminal_closeout_repository.dart';

extension CashDrawerRepository on TerminalCloseoutRepository {
  Future<Map<String, dynamic>> _cashState(
      String branch, String terminal, String day) async {
    final rows = await db.customSelect(
        'SELECT * FROM cash_drawer_events WHERE branch_id=? AND terminal_id=? AND business_day=? ORDER BY id',
        variables: [Variable(branch), Variable(terminal), Variable(day)]).get();
    final sales = await db.customSelect(
        '''SELECT COALESCE(SUM(CASE WHEN e.kind='sale' AND i.payment_method='cash' THEN i.total_centavos ELSE 0 END),0) AS cash,
      COALESCE(MAX(e.id),0) AS watermark FROM fiscal_reading_events e JOIN invoices i ON i.id=e.invoice_id
      WHERE i.branch_id=? AND i.terminal_id=? AND e.business_day=?''',
        variables: [Variable(branch), Variable(terminal), Variable(day)]).getSingle();
    var opening = 0, cashIn = 0, cashOut = 0, refunds = 0, movement = 0;
    Map<String, dynamic>? count, review;
    final entries = <Map<String, dynamic>>[];
    for (final row in rows) {
      final kind = row.read<String>('kind');
      final amount = row.read<int>('amount_centavos');
      final entry = <String, dynamic>{
        ...jsonDecode(row.read<String>('payload_json')) as Map<String, dynamic>,
        'id': row.read<int>('id'),
        'kind': kind,
        'amount': amount
      };
      entries.add(entry);
      switch (kind) {
        case 'opening':
          opening = amount;
          movement = entry['id'] as int;
        case 'cash_in':
          cashIn += amount;
          movement = entry['id'] as int;
        case 'cash_out':
          cashOut += amount;
          movement = entry['id'] as int;
        case 'refund':
          refunds += amount;
          movement = entry['id'] as int;
        case 'count':
          count = entry;
        case 'review':
          review = entry;
      }
    }
    final expected =
        opening + sales.read<int>('cash') + cashIn - cashOut - refunds;
    final fresh = count != null &&
        count['eventWatermark'] == sales.read<int>('watermark') &&
        count['movement'] == movement;
    return {
      'started': entries.any((e) => e['kind'] == 'opening'),
      'version': rows.isEmpty ? 0 : rows.last.read<int>('id'),
      'movement': movement,
      'eventWatermark': sales.read<int>('watermark'),
      'opening': opening,
      'cashSales': sales.read<int>('cash'),
      'cashIn': cashIn,
      'cashOut': cashOut,
      'refunds': refunds,
      'expected': expected,
      'counted': count?['amount'],
      'variance': count == null ? null : (count['amount'] as int) - expected,
      'countFresh': fresh,
      'countId': count?['id'],
      'reviewed': fresh && review != null && review['countId'] == count['id'],
      'entries': entries
    };
  }

  /// Each command is append-only, authorized and guarded against a stale screen.
  Future<void> recordCash(
      {required String actorId,
      required ReadingSnapshot reading,
      required String kind,
      required int amountCentavos,
      required String note,
      String? creditNoteId,
      String password = ''}) async {
    if (!['opening', 'cash_in', 'cash_out', 'refund', 'count', 'review']
        .contains(kind)) {
      throw ArgumentError('Unknown cash operation.');
    }
    if (amountCentavos < 0 ||
        amountCentavos > 99999999999 ||
        (['cash_in', 'cash_out', 'refund'].contains(kind) &&
            amountCentavos == 0)) {
      throw ArgumentError('Enter a valid cash amount.');
    }
    if (note.length > 1000 ||
        (['cash_in', 'cash_out', 'refund'].contains(kind) &&
            note.trim().isEmpty)) {
      throw ArgumentError('Enter a reason/reference (up to 1000 characters).');
    }
    final permission = kind == 'review'
        ? PosPermission.closeBusinessDay
        : PosPermission.recordCashDrawer;
    final actor = await _authorize(
        actorId, reading.branchId, reading.terminalId, permission);
    if (kind == 'review') {
      final verified = await staff.authenticate(
          email: actor.email, password: password, now: clock());
      if (verified.id != actorId) {
        throw const AuthorizationException('Use your own manager account.');
      }
    }
    await db.transaction(() async {
      if (creditNoteId != null) {
        final credit = await db.customSelect(
            'SELECT * FROM credit_notes WHERE id=?',
            variables: [Variable(creditNoteId)]).getSingle();
        if (kind != 'refund' ||
            credit.read<int>('total_centavos') != amountCentavos ||
            credit.read<String>('terminal_id') != reading.terminalId ||
            credit.read<String>('business_day') != reading.day) {
          throw StateError(
              'The cash refund must match its linked credit note.');
        }
      }
      _validateDay(reading.day);
      await _authorize(
          actorId, reading.branchId, reading.terminalId, permission);
      final history = await _history(reading.terminalId);
      if (reading.isZ ||
          (history.isNotEmpty &&
              reading.day.compareTo(history.first.day) <= 0)) {
        throw StateError('Cash records for this day are closed.');
      }
      final cash =
          await _cashState(reading.branchId, reading.terminalId, reading.day);
      if (cash['version'] != (reading.data['cashDrawer'] as Map?)?['version'] ||
          cash['eventWatermark'] != reading.watermark) {
        throw StateError(
            'Sales or cash records changed. Refresh before continuing.');
      }
      if (kind == 'opening' && cash['started'] == true) {
        throw StateError('Opening float already recorded.');
      }
      if (kind != 'opening' && cash['started'] != true) {
        throw StateError('Record the opening float first.');
      }
      if (kind == 'count' &&
          amountCentavos != cash['expected'] &&
          note.trim().isEmpty) {
        throw ArgumentError('Explain the shortage or overage before saving.');
      }
      if (kind == 'review' && cash['countFresh'] != true) {
        throw StateError('A fresh drawer count is required.');
      }
      if (kind == 'review' && cash['reviewed'] == true) {
        throw StateError('This count is already reviewed.');
      }
      final payload = {
        if (creditNoteId != null) 'creditNoteId': creditNoteId,
        'actorId': actor.id,
        'actorName': actor.displayName,
        'recordedAt': clock().toUtc().toIso8601String(),
        'note': note.trim(),
        'eventWatermark': cash['eventWatermark'],
        'movement': cash['movement'],
        'expected': cash['expected'],
        'countId': cash['countId'],
        if (kind == 'count')
          'variance': amountCentavos - (cash['expected'] as int)
      };
      await db.customStatement(
          'INSERT INTO cash_drawer_events(terminal_id,branch_id,business_day,kind,amount_centavos,payload_json) VALUES(?,?,?,?,?,?)',
          [
            reading.terminalId,
            reading.branchId,
            reading.day,
            kind,
            amountCentavos,
            jsonEncode(payload)
          ]);
      await AuditTrailRepository(db).append(
          branchId: reading.branchId,
          terminalId: reading.terminalId,
          actorId: actor.id,
          eventType: 'cash_drawer.$kind',
          entityType: 'cash_drawer',
          entityId: '${reading.terminalId}:${reading.day}',
          payloadJson: jsonEncode({...payload, 'amount': amountCentavos}),
          occurredAt: clock());
    });
  }
}
