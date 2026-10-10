import 'dart:convert';
import '../../features/business_profiles/business_profile.dart';
import '../../core/auth/pos_authorization.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'company_registration_repository.dart';
import 'staff_auth_repository.dart';

class BusinessProfileRepository {
  BusinessProfileRepository(this.db);
  final AppDatabase db;
  Future<BusinessCheckoutType?> readType() async {
    final row = await db
        .customSelect(
            'SELECT checkout_type FROM business_profile_type WHERE id = 1')
        .getSingleOrNull();
    return row == null
        ? null
        : BusinessCheckoutType.values.byName(row.read<String>('checkout_type'));
  }

  Future<void> initializeEmpty(BusinessCheckoutType type) =>
      db.transaction(() async {
        if ((await db.select(db.staffUsers).get()).isNotEmpty ||
            (await db.select(db.invoices).get()).isNotEmpty) {
          throw StateError(
              'An existing business requires owner authorization.');
        }
        await _insert(type);
      });
  Future<void> assign(
      {required BusinessCheckoutType type,
      required String email,
      required String password}) async {
    final actor = await StaffAuthRepository(db)
        .authenticate(email: email, password: password, now: DateTime.now());
    final company = await CompanyRegistrationRepository(db).read();
    if (actor.role != StaffRole.owner ||
        (company != null && company.ownerId != actor.id)) {
      throw const AuthorizationException(
          'Only the business owner can choose its checkout type.');
    }
    await db.transaction(() async {
      await _insert(type);
      await AuditTrailRepository(db).append(
          branchId: company == null
              ? actor.branchIds.first
              : CompanyRegistration.branchId,
          actorId: actor.id,
          eventType: 'business_profile.type_selected',
          entityType: 'business_profile',
          entityId: '1',
          payloadJson: jsonEncode({'checkoutType': type.name}),
          occurredAt: DateTime.now());
    });
  }

  Future<void> _insert(BusinessCheckoutType type) => db.customStatement(
      'INSERT INTO business_profile_type(id,checkout_type) VALUES (1,?)',
      [type.name]);
  Future<void> requireType(String? requested) async {
    final selected = await readType();
    if ((db.requireBusinessProfile && selected == null) ||
        (selected != null && selected.name != requested)) {
      throw StateError('Use the checkout assigned to this business profile.');
    }
  }
}
