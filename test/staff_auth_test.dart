import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/auth/password_hasher.dart';
import 'package:pos_app/core/auth/pos_authorization.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/repositories/audit_trail_repository.dart';
import 'package:pos_app/local/repositories/staff_auth_repository.dart';

void main() {
  late AppDatabase database;
  late Pbkdf2PasswordHasher hasher;
  late StaffAuthRepository auth;
  final now = DateTime(2026, 7, 11, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    hasher = Pbkdf2PasswordHasher(iterations: 1000);
    auth = StaffAuthRepository(database, passwordHasher: hasher);
    for (final branch in [('branch-1', '001'), ('branch-2', '002')]) {
      await database.into(database.branches).insert(
            BranchesCompanion.insert(
              id: branch.$1,
              code: branch.$2,
              name: 'Branch ${branch.$2}',
              createdAt: now,
            ),
          );
    }
  });

  tearDown(() => database.close());

  test('password policy rejects short and context-specific passwords', () {
    expect(
      () => hasher.hashPassword('short-password'),
      throwsA(isA<PasswordPolicyException>()),
    );
    expect(
      () => hasher.hashPassword('xantara123456789'),
      throwsA(isA<PasswordPolicyException>()),
    );
  });

  test('stores unique salted hashes and never plaintext passwords', () async {
    const password = 'correct horse battery staple';
    await auth.createStaff(_staff(
      email: 'manager1@example.com',
      password: password,
      at: now,
    ));
    await auth.createStaff(_staff(
      email: 'manager2@example.com',
      password: password,
      at: now.add(const Duration(seconds: 1)),
    ));

    final users = await database.select(database.staffUsers).get();
    expect(users, hasLength(2));
    expect(users.every((user) => user.passwordHash != password), isTrue);
    expect(users[0].passwordSalt, isNot(users[1].passwordSalt));
    expect(users[0].passwordHash, isNot(users[1].passwordHash));
    expect(
        users.every(
            (user) => user.passwordAlgorithm == Pbkdf2PasswordHasher.algorithm),
        isTrue);
  });

  test('authenticates offline and returns branch-scoped principal', () async {
    const password = 'correct horse battery staple';
    final id = await auth.createStaff(_staff(
      email: 'MANAGER@EXAMPLE.COM',
      password: password,
      at: now,
    ));

    final principal = await auth.authenticate(
      email: ' manager@example.com ',
      password: password,
      now: now.add(const Duration(minutes: 1)),
    );

    expect(principal.id, id);
    expect(principal.email, 'manager@example.com');
    expect(principal.role, StaffRole.manager);
    expect(principal.branchIds, {'branch-1'});
    final stored = await database.select(database.staffUsers).getSingle();
    expect(stored.lastLoginAt, now.add(const Duration(minutes: 1)));
    expect(stored.failedLoginAttempts, 0);
    expect(
        (await AuditTrailRepository(database).verifyBranch('branch-1')).isValid,
        isTrue);
  });

  test('rate limits repeated invalid passwords', () async {
    const password = 'correct horse battery staple';
    await auth.createStaff(_staff(
      email: 'manager@example.com',
      password: password,
      at: now,
    ));

    for (var attempt = 1; attempt < 5; attempt++) {
      await expectLater(
        auth.authenticate(
          email: 'manager@example.com',
          password: 'incorrect password attempt',
          now: now.add(Duration(seconds: attempt)),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    }
    await expectLater(
      auth.authenticate(
        email: 'manager@example.com',
        password: 'incorrect password attempt',
        now: now.add(const Duration(seconds: 5)),
      ),
      throwsA(isA<AuthenticationLockedException>()),
    );
    await expectLater(
      auth.authenticate(
        email: 'manager@example.com',
        password: password,
        now: now.add(const Duration(minutes: 1)),
      ),
      throwsA(isA<AuthenticationLockedException>()),
    );
  });

  test('role policy enforces both permission and branch assignment', () {
    const policy = PosAuthorizationPolicy();
    const cashier = StaffPrincipal(
      id: 'cashier-1',
      displayName: 'Cashier',
      email: 'cashier@example.com',
      role: StaffRole.cashier,
      branchIds: {'branch-1'},
    );
    const manager = StaffPrincipal(
      id: 'manager-1',
      displayName: 'Manager',
      email: 'manager@example.com',
      role: StaffRole.manager,
      branchIds: {'branch-1'},
    );

    expect(
      policy.allows(cashier, PosPermission.createSale, branchId: 'branch-1'),
      isTrue,
    );
    expect(
      policy.allows(cashier, PosPermission.voidInvoice, branchId: 'branch-1'),
      isFalse,
    );
    expect(
      policy.allows(manager, PosPermission.voidInvoice, branchId: 'branch-1'),
      isTrue,
    );
    expect(
      policy.allows(manager, PosPermission.voidInvoice, branchId: 'branch-2'),
      isFalse,
    );
  });
}

CreateStaffRequest _staff({
  required String email,
  required String password,
  required DateTime at,
}) {
  return CreateStaffRequest(
    displayName: 'Store Manager',
    email: email,
    role: StaffRole.manager,
    password: password,
    branchIds: const {'branch-1'},
    createdBy: 'owner-1',
    createdAt: at,
  );
}
