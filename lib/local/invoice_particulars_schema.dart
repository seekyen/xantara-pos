Future<void> createInvoiceParticularsSchema(
    Future<void> Function(String) run) async {
  await run(
      'CREATE TABLE IF NOT EXISTS invoice_footer_config (id INTEGER PRIMARY KEY CHECK(id=1), data_json TEXT NOT NULL)');
  await run(
      'CREATE TABLE IF NOT EXISTS invoice_particulars (invoice_id TEXT PRIMARY KEY REFERENCES invoices(id), data_json TEXT NOT NULL)');
  for (final operation in ['UPDATE', 'DELETE']) {
    await run(
        "CREATE TRIGGER IF NOT EXISTS invoice_particulars_no_${operation.toLowerCase()} BEFORE $operation ON invoice_particulars BEGIN SELECT RAISE(ABORT, 'Invoice particulars are immutable'); END");
  }
}
