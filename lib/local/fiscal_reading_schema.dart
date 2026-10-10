Future<void> createFiscalReadingSchema(
    Future<void> Function(String) sql) async {
  await sql('''CREATE TABLE IF NOT EXISTS fiscal_reading_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_id TEXT NOT NULL REFERENCES invoices(id),
    kind TEXT NOT NULL CHECK(kind IN ('sale','void')),
    business_day TEXT NOT NULL, UNIQUE(invoice_id, kind))''');
  await sql(
      'CREATE INDEX IF NOT EXISTS fiscal_events_day ON fiscal_reading_events(business_day,invoice_id)');
  await sql('''CREATE TABLE IF NOT EXISTS fiscal_z_readings (
    terminal_id TEXT NOT NULL REFERENCES terminals(id),
    branch_id TEXT NOT NULL REFERENCES branches(id), z_no INTEGER NOT NULL,
    business_day TEXT NOT NULL, snapshot_json TEXT NOT NULL,
    PRIMARY KEY(terminal_id, z_no), UNIQUE(terminal_id, business_day))''');
  await sql(
      '''INSERT OR IGNORE INTO fiscal_reading_events(invoice_id,kind,business_day)
    SELECT invoice_id,kind,strftime('%Y-%m-%d',event_at,'unixepoch','+8 hours') FROM (
      SELECT id AS invoice_id,'sale' AS kind,issued_at AS event_at FROM invoices
      UNION ALL SELECT id AS invoice_id,'void' AS kind,voided_at AS event_at FROM invoices
        WHERE status='voided' AND voided_at IS NOT NULL
    ) ORDER BY event_at,kind,invoice_id''');
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS fiscal_sale_day_guard BEFORE INSERT ON invoices
    WHEN EXISTS(SELECT 1 FROM fiscal_z_readings z WHERE z.terminal_id=NEW.terminal_id
      AND z.business_day >= strftime('%Y-%m-%d',NEW.issued_at,'unixepoch','+8 hours'))
    BEGIN SELECT RAISE(ABORT,'This business day is closed. Sales cannot be backdated into a closed day.'); END''');
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS fiscal_void_day_guard BEFORE UPDATE OF status ON invoices
    WHEN NEW.status='voided' AND OLD.status!='voided' AND EXISTS(
      SELECT 1 FROM fiscal_z_readings z WHERE z.terminal_id=NEW.terminal_id
      AND z.business_day >= strftime('%Y-%m-%d',NEW.voided_at,'unixepoch','+8 hours'))
    BEGIN SELECT RAISE(ABORT,'This business day is closed. Record the void on an open business day.'); END''');
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS fiscal_sale_event AFTER INSERT ON invoices
    BEGIN INSERT INTO fiscal_reading_events(invoice_id,kind,business_day)
      VALUES(NEW.id,'sale',strftime('%Y-%m-%d',NEW.issued_at,'unixepoch','+8 hours')); END''');
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS fiscal_void_event AFTER UPDATE OF status ON invoices
    WHEN NEW.status='voided' AND OLD.status!='voided'
    BEGIN INSERT INTO fiscal_reading_events(invoice_id,kind,business_day)
      VALUES(NEW.id,'void',strftime('%Y-%m-%d',NEW.voided_at,'unixepoch','+8 hours')); END''');
  for (final table in ['fiscal_reading_events', 'fiscal_z_readings']) {
    for (final operation in ['UPDATE', 'DELETE']) {
      await sql(
          '''CREATE TRIGGER IF NOT EXISTS ${table}_${operation.toLowerCase()}_guard
        BEFORE $operation ON $table BEGIN SELECT RAISE(ABORT,'Fiscal readings and events are immutable.'); END''');
    }
  }
}
