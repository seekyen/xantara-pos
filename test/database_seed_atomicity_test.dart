import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_seed.dart';

void main() {
  test('seedDatabaseIfEmpty actually creates the owner/cashier staff accounts',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    await seedDatabaseIfEmpty(database);

    final staff = await database.select(database.staffUsers).get();
    final emails = staff.map((s) => s.emailNormalized).toSet();
    expect(emails, {seedOwnerEmail, seedCashierEmail});

    final branches = await database.select(database.branches).get();
    expect(branches, isNotEmpty);

    // Re-running on an already-seeded database must be a safe no-op, not a
    // duplicate-key crash.
    await seedDatabaseIfEmpty(database);
    final staffAfterRerun = await database.select(database.staffUsers).get();
    expect(staffAfterRerun.length, staff.length);

    await database.close();
  });
}
