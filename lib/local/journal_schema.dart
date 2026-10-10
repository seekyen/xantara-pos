Future<void> createJournalSchema(Future<void> Function(String) sql) async {
  await sql('''CREATE TABLE IF NOT EXISTS journal_documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT, source_id TEXT NOT NULL UNIQUE,
    branch_id TEXT NOT NULL, terminal_id TEXT NOT NULL, business_day TEXT NOT NULL,
    event_type TEXT NOT NULL, occurred_at TEXT NOT NULL,
    snapshot_json TEXT NOT NULL, sha256 TEXT NOT NULL)''');
  await sql(
      'CREATE INDEX IF NOT EXISTS journal_day ON journal_documents(terminal_id,business_day,id)');
  for (final op in ['UPDATE', 'DELETE']) {
    await sql(
        '''CREATE TRIGGER IF NOT EXISTS journal_${op.toLowerCase()}_guard BEFORE $op ON journal_documents
      BEGIN SELECT RAISE(ABORT,'Journal documents are immutable.'); END''');
  }
}
