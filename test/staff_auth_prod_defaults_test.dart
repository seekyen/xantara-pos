import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';

void main() {
  test('authenticates using the real production hasher defaults (600k iterations)', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final auth = StaffAuthRepository(database); // no override — real defaults
    final now = DateTime(2026, 9, 12, 10);

    await database.into(database.branches).insert(
          BranchesCompanion.insert(
            id: 'branch-main',
            code: 'MAIN',
            name: 'Head Office',
            createdAt: now,
          ),
        );

    const email = 'owner@xantara.com';
    const password = 'XantaraOwner#2026!';

    final stopwatchCreate = Stopwatch()..start();
    await auth.createStaff(CreateStaffRequest(
      displayName: 'Store Owner',
      email: email,
      role: StaffRole.owner,
      password: password,
      branchIds: const {'branch-main'},
      createdBy: 'system-seed',
      createdAt: now,
    ));
    stopwatchCreate.stop();
    // ignore: avoid_print
    print('createStaff took ${stopwatchCreate.elapsedMilliseconds}ms');

    final stored = await database.select(database.staffUsers).getSingle();
    // ignore: avoid_print
    print('stored iterations: ${stored.passwordIterations}, algorithm: ${stored.passwordAlgorithm}');

    final stopwatchAuth = Stopwatch()..start();
    final principal = await auth.authenticate(
      email: email,
      password: password,
      now: now.add(const Duration(seconds: 1)),
    );
    stopwatchAuth.stop();
    // ignore: avoid_print
    print('authenticate took ${stopwatchAuth.elapsedMilliseconds}ms');

    expect(principal.email, email);
    await database.close();
  });
}
