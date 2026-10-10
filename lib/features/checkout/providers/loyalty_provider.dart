import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/loyalty/loyalty_points.dart';
import '../../../local/database.dart';
import '../../../local/database_providers.dart';

/// The customer the cashier attached to the sale being built (null = no loyalty customer).
/// Cleared once the sale is recorded or the cart is cleared.
final selectedLoyaltyCustomerProvider =
    StateProvider<LoyaltyCustomer?>((ref) => null);

/// Active promo periods from the last sync; re-emits when a sync replaces them.
final loyaltyRulesProvider = StreamProvider<List<LoyaltyPromoRule>>(
  (ref) => ref.watch(loyaltyRepositoryProvider).watchRules(),
);
