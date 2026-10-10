import 'bir_invoice.dart';

/// Cumulative allocation preserves every original centavo across split returns.
/// Tax is apportioned from the saved line, never today's product or tax setup.
Map<String, int> creditPortion(BirInvoiceLine line, int prior, int quantity) {
  if (quantity <= 0 || prior < 0 || prior + quantity > line.quantity) {
    throw ArgumentError(
        'Return quantity exceeds the remaining original quantity.');
  }
  int allocated(int amount, int count) =>
      (amount * count + line.quantity ~/ 2) ~/ line.quantity;
  int delta(int amount) =>
      allocated(amount, prior + quantity) - allocated(amount, prior);
  final tax = const BirInvoiceCalculator().summarize([line]);
  final net = delta(line.netCentavos);
  // Base and VAT must always sum to the refunded amount, including tiny lines.
  int baseAt(int count) => line.netCentavos == 0
      ? 0
      : (tax.vatableSalesCentavos * allocated(line.netCentavos, count) +
              line.netCentavos ~/ 2) ~/
          line.netCentavos;
  final base = baseAt(prior + quantity) - baseAt(prior);
  return {
    'total': net,
    'discount': delta(line.discountCentavos),
    'vatRelief': delta(line.vatReliefCentavos),
    'vatable': base,
    'vat': line.taxCategory == TaxCategory.vat12 ? net - base : 0,
    'exempt': line.taxCategory == TaxCategory.vatExempt ? net : 0,
    'zero': line.taxCategory == TaxCategory.zeroRated ? net : 0,
    'nonVat': line.taxCategory == TaxCategory.nonVat ? net : 0
  };
}

String formatCreditNote(Map<String, dynamic> note, {bool copy = false}) {
  String money(dynamic n) => ((n as int) / 100).toStringAsFixed(2);
  final b = StringBuffer(copy ? 'CREDIT NOTE COPY\n' : 'CREDIT NOTE\n');
  final seller = note['seller'] as Map;
  b.writeln('${seller['name']}\nTIN: ${seller['tin']}\n${seller['address']}');
  b.writeln(
      'Branch: ${seller['branchCode']} / Terminal: ${seller['terminalCode']}');
  b.writeln('MIN: ${seller['min']} / PTU: ${seller['ptu']}');
  b.writeln(
      'Credit note: ${note['number']}\nOriginal invoice: ${note['invoiceNumber']}');
  b.writeln(
      'Issued UTC: ${note['issuedAt']}\nBusiness date: ${note['businessDay']}');
  if (note['buyer'] != null) b.writeln('Buyer: ${note['buyer']}');
  b.writeln(
      'Reason: ${note['reason']}\nOperator: ${note['actorName']}\nAuthorized by: ${note['supervisorName']}');
  for (final line in note['lines'] as List) {
    b.writeln(
        '${line['quantity']} x ${line['description']} | PHP ${money((line['amounts'] as Map)['total'])} | ${line['restock'] == true ? 'Restocked' : 'Not restocked'}');
  }
  final totals = note['totals'] as Map;
  b.writeln('CASH REFUND RECORDED: PHP ${money(totals['total'])}');
  for (final key in [
    'vatable',
    'vat',
    'exempt',
    'zero',
    'nonVat',
    'discount',
    'vatRelief'
  ]) {
    b.writeln('$key reversal: PHP ${money(totals[key])}');
  }
  b.writeln('Linked cash refund; do not record a second manual payout.');
  b.writeln('Original invoice remains unchanged. No new sale invoice issued.');
  return b.toString();
}
