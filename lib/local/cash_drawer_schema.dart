Future<void> createCashDrawerSchema(Future<void> Function(String) sql) async {
  await sql('''CREATE TABLE IF NOT EXISTS cash_drawer_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    terminal_id TEXT NOT NULL REFERENCES terminals(id),
    branch_id TEXT NOT NULL REFERENCES branches(id),
    business_day TEXT NOT NULL,
    kind TEXT NOT NULL CHECK(kind IN ('opening','cash_in','cash_out','refund','count','review')),
    amount_centavos INTEGER NOT NULL CHECK(amount_centavos >= 0),
    payload_json TEXT NOT NULL)''');
  await sql(
      'CREATE INDEX IF NOT EXISTS cash_drawer_day ON cash_drawer_events(terminal_id,business_day)');
  await sql(
      "CREATE UNIQUE INDEX IF NOT EXISTS cash_drawer_opening ON cash_drawer_events(terminal_id,business_day) WHERE kind='opening'");
  for (final op in ['UPDATE', 'DELETE']) {
    await sql(
        '''CREATE TRIGGER IF NOT EXISTS cash_drawer_${op.toLowerCase()}_guard
      BEFORE $op ON cash_drawer_events BEGIN SELECT RAISE(ABORT,'Cash drawer events are immutable.'); END''');
  }
  await sql(
      '''CREATE TRIGGER IF NOT EXISTS cash_drawer_closed_guard BEFORE INSERT ON cash_drawer_events
    WHEN EXISTS(SELECT 1 FROM fiscal_z_readings z WHERE z.terminal_id=NEW.terminal_id AND z.business_day>=NEW.business_day)
    BEGIN SELECT RAISE(ABORT,'This business day is closed.'); END''');
}
