import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local/database_providers.dart';
import '../../local/repositories/business_profile_repository.dart';
import '../pos/fnb/providers/cart_provider.dart';
import '../pos/retail/providers/grocery_cart_provider.dart';
import '../../shared/providers/sync_provider.dart';
import 'business_profile.dart';
import '../customer_display/providers/customer_display_providers.dart';
import '../customer_display/customer_display_bridge.dart';

final activeBusinessProfileProvider = Provider<BusinessProfile?>((ref) => null);
final businessProfileCatalogProvider = Provider<BusinessProfileCatalog>(
    (ref) => throw StateError('Profile catalog unavailable.'));
final businessCheckoutTypeProvider =
    StateProvider<BusinessCheckoutType?>((ref) => null);
final switchBusinessHostProvider =
    Provider<Future<void> Function(String)>((ref) => (_) async {});
final switchBusinessProvider =
    Provider<Future<void> Function(String)>((ref) => (id) async {
          ref.read(ensureBusinessSwitchAllowedProvider)();
          final window = ref.read(customerDisplayWindowIdProvider);
          if (window != null) await CustomerDisplayBridge.sendReset(window);
          await ref.read(switchBusinessHostProvider)(id);
        });
final ensureBusinessSwitchAllowedProvider =
    Provider<void Function()>((ref) => () {
          if (ref.read(cartProvider).isNotEmpty ||
              ref.read(groceryCartProvider).isNotEmpty) {
            throw StateError(
                'Finish or clear the current sale before switching businesses.');
          }
          if (ref.read(syncProvider).status == SyncStatus.syncing) {
            throw StateError(
                'Wait for cloud sync to finish before switching businesses.');
          }
        });
final businessTypeRepositoryProvider = Provider(
    (ref) => BusinessProfileRepository(ref.watch(appDatabaseProvider)));
