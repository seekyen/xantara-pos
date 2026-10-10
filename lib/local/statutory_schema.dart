Future<void> createStatutorySchema(Future<void> Function(String) run) async {
  await run(
      'CREATE TABLE IF NOT EXISTS statutory_product_classes (product_id TEXT PRIMARY KEY REFERENCES products(id), kind TEXT NOT NULL, product_fingerprint TEXT NOT NULL)');
  await run(
      'CREATE TABLE IF NOT EXISTS statutory_policy (id INTEGER PRIMARY KEY CHECK(id=1), food_service INTEGER NOT NULL DEFAULT 0, bnpc INTEGER NOT NULL DEFAULT 0)');
}
