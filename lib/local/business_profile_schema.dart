Future<void> createBusinessProfileSchema(
    Future<void> Function(String) run) async {
  await run('''CREATE TABLE IF NOT EXISTS business_profile_type (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    checkout_type TEXT NOT NULL CHECK (checkout_type IN ('fnb','retail'))
  )''');
  for (final operation in ['UPDATE', 'DELETE']) {
    await run(
        '''CREATE TRIGGER IF NOT EXISTS business_profile_no_${operation.toLowerCase()}
      BEFORE $operation ON business_profile_type BEGIN
      SELECT RAISE(ABORT, 'Business checkout type is fixed; switch profiles instead.'); END''');
  }
}
