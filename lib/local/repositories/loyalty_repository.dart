import 'package:drift/drift.dart';

import '../../core/loyalty/loyalty_points.dart';
import '../database.dart';

extension LoyaltyPromoRuleRow on LoyaltyPromo {
  LoyaltyPromoRule toRule() => LoyaltyPromoRule(
        name: name,
        startDate: startDate,
        endDate: endDate,
        spendPerPointCentavos: spendPerPointCentavos,
      );
}

/// The on-device copy of Xantara Cloud's customers and loyalty promos. Points themselves are
/// awarded by the cloud when an invoice syncs; here they are only estimated for the cashier.
class LoyaltyRepository {
  LoyaltyRepository(this.database);

  final AppDatabase database;

  static final _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Replaces the cache with the cloud's `loyalty/pos-sync/` answer, all or nothing: a response
  /// of the wrong shape throws and leaves the previous cache untouched, while single malformed
  /// rows (no id/name, a bad date or rate) are skipped. Returns how many customers were stored.
  Future<int> replaceFromCloud(Object? response, {DateTime? now}) async {
    if (response is! Map ||
        response['customers'] is! List ||
        response['promos'] is! List) {
      throw const FormatException('Unexpected loyalty download.');
    }
    final at = now ?? DateTime.now();

    final customers = <LoyaltyCustomersCompanion>[];
    for (final raw in response['customers'] as List) {
      if (raw is! Map) continue;
      final id = '${raw['id'] ?? ''}'.trim();
      final name = '${raw['name'] ?? ''}'.trim();
      if (id.isEmpty || name.isEmpty) continue;
      final points = raw['loyalty_points'];
      final email = '${raw['email'] ?? ''}'.trim();
      customers.add(LoyaltyCustomersCompanion.insert(
        id: id,
        name: name,
        phone: Value('${raw['phone'] ?? ''}'.trim()),
        email: Value(email.isEmpty ? null : email),
        points: Value(points is num && points > 0 ? points.toInt() : 0),
        syncedAt: at,
      ));
    }

    final promos = <LoyaltyPromosCompanion>[];
    for (final raw in response['promos'] as List) {
      if (raw is! Map) continue;
      final id = '${raw['id'] ?? ''}'.trim();
      final name = '${raw['name'] ?? ''}'.trim();
      final start = '${raw['start_date'] ?? ''}';
      final end = '${raw['end_date'] ?? ''}';
      final spend = pesosToCentavos(raw['spend_per_point']);
      if (id.isEmpty ||
          name.isEmpty ||
          !_day.hasMatch(start) ||
          !_day.hasMatch(end) ||
          end.compareTo(start) < 0 ||
          spend == null ||
          spend <= 0 ||
          raw['is_active'] == false) {
        continue;
      }
      promos.add(LoyaltyPromosCompanion.insert(
        id: id,
        name: name,
        startDate: start,
        endDate: end,
        spendPerPointCentavos: spend,
        syncedAt: at,
      ));
    }

    await database.transaction(() async {
      await database.delete(database.loyaltyCustomers).go();
      await database.delete(database.loyaltyPromos).go();
      await database.batch((batch) {
        batch.insertAll(database.loyaltyCustomers, customers);
        batch.insertAll(database.loyaltyPromos, promos);
      });
    });
    return customers.length;
  }

  /// Customers whose name or phone contains [query] (all of them when empty), alphabetically.
  /// Filtered in Dart on purpose: the cache is one shop's customer list, and plain string
  /// matching has no SQL LIKE wildcards to escape.
  Future<List<LoyaltyCustomer>> searchCustomers(String query,
      {int limit = 40}) async {
    final text = query.trim().toLowerCase();
    final rows = await (database.select(database.loyaltyCustomers)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rows
        .where((row) =>
            text.isEmpty ||
            row.name.toLowerCase().contains(text) ||
            row.phone.toLowerCase().contains(text))
        .take(limit)
        .toList(growable: false);
  }

  /// The active promo periods, re-emitted whenever a sync replaces them.
  Stream<List<LoyaltyPromoRule>> watchRules() {
    final select = database.select(database.loyaltyPromos)
      ..where((row) => row.isActive.equals(true))
      ..orderBy([(row) => OrderingTerm.asc(row.startDate)]);
    return select
        .watch()
        .map((rows) => rows.map((row) => row.toRule()).toList(growable: false));
  }

  Future<InvoiceLoyaltyData?> loyaltyForInvoice(String invoiceId) {
    return (database.select(database.invoiceLoyalty)
          ..where((row) => row.invoiceId.equals(invoiceId)))
        .getSingleOrNull();
  }
}
