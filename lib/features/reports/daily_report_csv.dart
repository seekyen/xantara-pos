import '../../local/repositories/terminal_closeout_repository.dart';

/// CSV amounts remain numeric; untrusted text cannot become spreadsheet formulas.
String dailyReportCsv(ReadingSnapshot reading) {
  final rows = <List<String>>[];
  void text(String label, Object? value) {
    var s = '${value ?? ''}';
    if (RegExp(r'^[\s]*[=+@-]').hasMatch(s) ||
        s.startsWith('\t') ||
        s.startsWith('\r') ||
        s.startsWith('\n')) {
      s = "'$s";
    }
    rows.add([label, s, '']);
  }

  void money(String label, dynamic cents) =>
      rows.add([label, ((cents as int) / 100).toStringAsFixed(2), 'PHP']);
  rows.add(['End-of-day report', 'Value', 'Unit']);
  text('Business date (Asia/Manila)', reading.day);
  text('Status',
      reading.isZ ? 'Closed / Z #${reading.zNumber}' : 'Open / X snapshot');
  text('Generated at (UTC)', reading.data['generatedAt']);
  final seller = reading.data['seller'] as Map;
  text('Company', seller['name']);
  for (final field in const {
    'tin': 'TIN',
    'address': 'Registered address',
    'min': 'MIN',
    'ptu': 'PTU number',
    'ptuDate': 'PTU issued',
    'serial': 'Machine serial',
    'rdo': 'RDO'
  }.entries) {
    text(field.value, seller[field.key]);
  }
  text('Branch', seller['branchCode']);
  text('Terminal', seller['terminalCode']);
  text('Operator', reading.data['actorName']);
  if (seller['training'] == true) text('Mode', 'TRAINING - NOT FOR TAX FILING');
  text('Sales count', reading.data['saleCount']);
  text('Void count', reading.data['voidCount']);
  text('First invoice', reading.data['firstInvoice']);
  text('Last invoice', reading.data['lastInvoice']);
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
  for (final e in labels.entries) {
    money(e.value, reading.totals[e.key]);
  }
  for (final e in (reading.data['payments'] as Map).entries) {
    money('Net payments: ${e.key}', e.value);
  }
  for (final e in (reading.data['statutoryTotals'] as Map? ?? {}).entries) {
    money('Statutory ${e.key} (net of voids)', e.value);
  }
  money('Previously closed cumulative net', reading.data['oldGrandTotal']);
  money('Returns / credit notes', reading.data['creditNoteTotal'] ?? 0);
  for (final number in reading.data['creditNotes'] as List? ?? []) {
    text('Credit note reference', number);
  }
  money('Closed total plus this reading', reading.data['newGrandTotal']);
  for (final invoice in reading.data['voidInvoices'] as List) {
    text('Void invoice reference', invoice);
  }
  text('Scope',
      'Active business and selected terminal only; includes retained historical sales.');
  final cash = reading.data['cashDrawer'] as Map?;
  if (cash != null && cash['started'] == true) {
    text(
        'Drawer status',
        cash['reviewed'] == true
            ? 'Manager reviewed'
            : cash['countFresh'] == true
                ? 'Awaiting manager review'
                : 'Count required');
    for (final e in const {
      'opening': 'Opening float',
      'cashSales': 'Drawer cash sales before void reversals',
      'cashIn': 'Cash in',
      'cashOut': 'Cash out',
      'refunds': 'Cash refund payouts',
      'expected': 'Expected cash',
      'counted': 'Counted cash',
      'variance': 'Overage (+) / shortage (-)'
    }.entries) {
      if (cash[e.key] != null) money(e.value, cash[e.key]);
    }
    for (final event in cash['entries'] as List) {
      text('Cash record',
          '${event['kind']} / ${event['actorName']} / ${event['recordedAt']}');
      money('Recorded amount', event['amount']);
      text('Reason / reference', event['note']);
      if (event['kind'] == 'count') {
        money('Expected at count', event['expected']);
        money('Variance at count', event['variance']);
      }
    }
  } else {
    text('Cash drawer', 'Not reconciled');
  }
  text('Notes',
      'Voids appear on the adjustment day. Net payments are not a counted cash drawer balance.');
  text('Report copy',
      'Export does not close the day. Internal operational report.');
  String cell(String v) => '"${v.replaceAll('"', '""')}"';
  return '\uFEFF${rows.map((r) => r.map(cell).join(',')).join('\r\n')}\r\n';
}
