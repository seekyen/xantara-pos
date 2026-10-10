Future<void> createCreditNoteSchema(Future<void> Function(String) sql) async {
  await sql('''CREATE TABLE IF NOT EXISTS credit_notes (
    id TEXT PRIMARY KEY, invoice_id TEXT NOT NULL REFERENCES invoices(id),
    branch_id TEXT NOT NULL REFERENCES branches(id), terminal_id TEXT NOT NULL REFERENCES terminals(id),
    sequence INTEGER NOT NULL CHECK(sequence>0), number TEXT NOT NULL UNIQUE,
    business_day TEXT NOT NULL, issued_at INTEGER NOT NULL,
    total_centavos INTEGER NOT NULL CHECK(total_centavos>0),
    request_key TEXT NOT NULL UNIQUE, request_hash TEXT NOT NULL, snapshot_json TEXT NOT NULL,
    UNIQUE(terminal_id,sequence))''');
  await sql(
      'CREATE INDEX IF NOT EXISTS credit_notes_invoice ON credit_notes(invoice_id)');
  await sql(
      "CREATE UNIQUE INDEX IF NOT EXISTS cash_credit_note_once ON cash_drawer_events(json_extract(payload_json,'\$.creditNoteId')) WHERE json_extract(payload_json,'\$.creditNoteId') IS NOT NULL");
  await sql('''CREATE TABLE IF NOT EXISTS credit_note_sequences (
    terminal_id TEXT PRIMARY KEY REFERENCES terminals(id), next_value INTEGER NOT NULL CHECK(next_value>0))''');
  for (final op in ['UPDATE', 'DELETE']) {
    await sql(
        "CREATE TRIGGER IF NOT EXISTS credit_notes_no_${op.toLowerCase()} BEFORE $op ON credit_notes BEGIN SELECT RAISE(ABORT,'Credit notes are immutable'); END");
  }
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS credit_note_day_guard BEFORE INSERT ON credit_notes
    WHEN EXISTS(SELECT 1 FROM fiscal_z_readings z WHERE z.terminal_id=NEW.terminal_id AND z.business_day>=NEW.business_day)
    BEGIN SELECT RAISE(ABORT,'This business day is closed.'); END''');
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS invoice_return_void_guard BEFORE UPDATE OF status ON invoices
    WHEN NEW.status='voided' AND EXISTS(SELECT 1 FROM credit_notes c WHERE c.invoice_id=NEW.id)
    BEGIN SELECT RAISE(ABORT,'Invoice has credit notes. Return only the remaining items.'); END''');
}
