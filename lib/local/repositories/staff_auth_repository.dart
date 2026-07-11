import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/password_hasher.dart';
import '../../core/auth/pos_authorization.dart';
import '../database.dart';
import 'audit_trail_repository.dart';

class CreateStaffRequest {
  const CreateStaffRequest({
    required this.displayName,
    required this.email,
    required this.role,
    required this.password,
    required this.branchIds,
    required this.createdBy,
    required this.createdAt,
  });

  final String displayName;
  final String email;
  final StaffRole role;
  final String password;
  final Set<String> branchIds;
  final String createdBy;
  final DateTime createdAt;
}

class StaffAuthRepository {
  StaffAuthRepository(
    this.database, {
    Pbkdf2PasswordHasher? passwordHasher,
    Uuid uuid = const Uuid(),
    this.maximumFailedAttempts = 5,
    this.lockDuration = const Duration(minutes: 15),
  })  : passwordHasher = passwordHasher ?? Pbkdf2PasswordHasher(),
        _uuid = uuid,
        _audit = AuditTrailRepository(database, uuid: uuid) {
    if (maximumFailedAttempts < 1 || lockDuration <= Duration.zero) {
      throw ArgumentError('Invalid authentication rate-limit settings.');
    }
  }

  final AppDatabase database;
  final Pbkdf2PasswordHasher passwordHasher;
  final int maximumFailedAttempts;
  final Duration lockDuration;
  final Uuid _uuid;
  final AuditTrailRepository _audit;

  Future<String> createStaff(CreateStaffRequest request) {
    return database.transaction(() async {
      final displayName = request.displayName.trim();
      final email = _normalizeEmail(request.email);
      if (displayName.isEmpty ||
          email.isEmpty ||
          request.createdBy.trim().isEmpty) {
        throw ArgumentError('Staff identity fields cannot be empty.');
      }
      if (request.branchIds.isEmpty) {
        throw ArgumentError('Staff must be assigned to at least one branch.');
      }
      for (final branchId in request.branchIds) {
        final branch = await (database.select(database.branches)
              ..where((row) => row.id.equals(branchId)))
            .getSingleOrNull();
        if (branch == null || !branch.isActive) {
          throw StateError('A selected branch is missing or inactive.');
        }
      }
      final existing = await (database.select(database.staffUsers)
            ..where((row) => row.emailNormalized.equals(email)))
          .getSingleOrNull();
      if (existing != null) {
        throw StateError('A staff account already uses this email.');
      }

      final digest = passwordHasher.hashPassword(request.password);
      final userId = _uuid.v4();
      await database.into(database.staffUsers).insert(
            StaffUsersCompanion.insert(
              id: userId,
              displayName: displayName,
              emailNormalized: email,
              role: request.role.name,
              passwordHash: digest.hashBase64,
              passwordSalt: digest.saltBase64,
              passwordAlgorithm: digest.algorithm,
              passwordIterations: digest.iterations,
              createdAt: request.createdAt,
              updatedAt: request.createdAt,
            ),
          );
      for (final branchId in request.branchIds) {
        await database.into(database.staffBranchAccess).insert(
              StaffBranchAccessCompanion.insert(
                staffUserId: userId,
                branchId: branchId,
                grantedAt: request.createdAt,
                grantedBy: request.createdBy.trim(),
              ),
            );
        await _audit.append(
          branchId: branchId,
          actorId: request.createdBy.trim(),
          eventType: 'staff.created',
          entityType: 'staff_user',
          entityId: userId,
          payloadJson: jsonEncode({
            'staffUserId': userId,
            'displayName': displayName,
            'email': email,
            'role': request.role.name,
            'branchId': branchId,
          }),
          occurredAt: request.createdAt,
        );
      }
      return userId;
    });
  }

  Future<StaffPrincipal> authenticate({
    required String email,
    required String password,
    required DateTime now,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final user = await (database.select(database.staffUsers)
          ..where((row) => row.emailNormalized.equals(normalizedEmail)))
        .getSingleOrNull();
    if (user == null || !user.isActive) {
      throw const AuthenticationException('Invalid email or password.');
    }
    if (user.lockedUntil?.isAfter(now) ?? false) {
      throw AuthenticationLockedException(user.lockedUntil!);
    }

    final verified = passwordHasher.verify(
      password: password,
      expectedHashBase64: user.passwordHash,
      saltBase64: user.passwordSalt,
      iterations: user.passwordIterations,
      algorithmName: user.passwordAlgorithm,
    );
    if (!verified) {
      final failures = user.failedLoginAttempts + 1;
      final shouldLock = failures >= maximumFailedAttempts;
      await (database.update(database.staffUsers)
            ..where((row) => row.id.equals(user.id)))
          .write(
        StaffUsersCompanion(
          failedLoginAttempts: Value(shouldLock ? 0 : failures),
          lockedUntil: Value(shouldLock ? now.add(lockDuration) : null),
          updatedAt: Value(now),
        ),
      );
      if (shouldLock) {
        throw AuthenticationLockedException(now.add(lockDuration));
      }
      throw const AuthenticationException('Invalid email or password.');
    }

    final access = await (database.select(database.staffBranchAccess)
          ..where((row) => row.staffUserId.equals(user.id)))
        .get();
    if (access.isEmpty) {
      throw const AuthenticationException('Account has no branch access.');
    }
    var hash = user.passwordHash;
    var salt = user.passwordSalt;
    var iterations = user.passwordIterations;
    var algorithm = user.passwordAlgorithm;
    if (user.passwordIterations < passwordHasher.iterations ||
        user.passwordAlgorithm != Pbkdf2PasswordHasher.algorithm) {
      final upgraded = passwordHasher.hashPassword(password);
      hash = upgraded.hashBase64;
      salt = upgraded.saltBase64;
      iterations = upgraded.iterations;
      algorithm = upgraded.algorithm;
    }
    await (database.update(database.staffUsers)
          ..where((row) => row.id.equals(user.id)))
        .write(
      StaffUsersCompanion(
        passwordHash: Value(hash),
        passwordSalt: Value(salt),
        passwordIterations: Value(iterations),
        passwordAlgorithm: Value(algorithm),
        failedLoginAttempts: const Value(0),
        lockedUntil: const Value(null),
        lastLoginAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return StaffPrincipal(
      id: user.id,
      displayName: user.displayName,
      email: user.emailNormalized,
      role: StaffRole.values.byName(user.role),
      branchIds: Set.unmodifiable(access.map((row) => row.branchId)),
    );
  }

  String _normalizeEmail(String value) => value.trim().toLowerCase();
}

class AuthenticationException implements Exception {
  const AuthenticationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthenticationLockedException implements Exception {
  const AuthenticationLockedException(this.lockedUntil);
  final DateTime lockedUntil;
  @override
  String toString() => 'Account is temporarily locked until $lockedUntil.';
}
