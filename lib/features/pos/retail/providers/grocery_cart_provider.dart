import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pricing/commercial_discounts.dart';
import '../../fnb/providers/pos_provider.dart' show Product, productsProvider;

export '../../fnb/providers/pos_provider.dart' show Product;

/// One scanned line in the grocery cart. Unit price is VAT-inclusive —
/// no separate VAT line is added at checkout.
class GroceryCartItem {
  const GroceryCartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  GroceryCartItem copyWith({int? quantity}) =>
      GroceryCartItem(product: product, quantity: quantity ?? this.quantity);
}

class GroceryCartNotifier extends StateNotifier<List<GroceryCartItem>> {
  GroceryCartNotifier() : super(const []);

  /// Adds [quantity] units of [product] — called once per barcode scan, with
  /// the pending multiplier (defaults to 1) folded into an existing line.
  void scan(Product product, {int quantity = 1}) {
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final updated = List<GroceryCartItem>.from(state);
      updated[index] =
          updated[index].copyWith(quantity: updated[index].quantity + quantity);
      state = updated;
    } else {
      state = [...state, GroceryCartItem(product: product, quantity: quantity)];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = const [];
}

final groceryCartProvider =
    StateNotifierProvider<GroceryCartNotifier, List<GroceryCartItem>>(
  (ref) => GroceryCartNotifier(),
);

final groceryCartSubtotalProvider = Provider<double>((ref) {
  return grocerySubtotalCentavos(ref.watch(groceryCartProvider)) / 100;
});

/// Finds a product by scanned code — matches SKU/id first, then falls back
/// to a case-insensitive name search so the field is usable without a real
/// barcode scanner attached.
Product? findGroceryProductByCode(WidgetRef ref, String code) {
  final query = code.trim().toLowerCase();
  if (query.isEmpty) return null;
  final products = ref.read(productsProvider);
  for (final p in products) {
    if (p.id.toLowerCase() == query) return p;
  }
  for (final p in products) {
    if (p.name.toLowerCase().contains(query)) return p;
  }
  return null;
}

// ── Coupon ───────────────────────────────────────────────────────────────

class GroceryCoupon {
  const GroceryCoupon({required this.code, required this.amountOff});
  final String code;
  final double amountOff;
}

/// Demo coupon table — mirrors the DISC200 promo used in the F&B checkout.
const Map<String, double> groceryCoupons = {'DISC200': 200.0};

final groceryCouponProvider = StateProvider<GroceryCoupon?>((ref) => null);

final groceryAmountAfterCouponProvider = Provider<double>((ref) {
  final subtotal = grocerySubtotalCentavos(ref.watch(groceryCartProvider));
  return (subtotal -
          groceryCouponCentavos(subtotal, ref.watch(groceryCouponProvider))) /
      100;
});

// ── Discount ─────────────────────────────────────────────────────────────

enum GroceryDiscountKind { seniorPwd, custom }

enum GroceryDiscountUnit { percent, peso }

final groceryDiscountKindProvider =
    StateProvider<GroceryDiscountKind?>((ref) => null);
final groceryCustomDiscountAmountProvider = StateProvider<String>((ref) => '');
final groceryCustomDiscountUnitProvider =
    StateProvider<GroceryDiscountUnit>((ref) => GroceryDiscountUnit.percent);

final groceryDiscountAmountProvider = Provider<double>((ref) {
  return groceryDiscountCentavos(
          (ref.watch(groceryAmountAfterCouponProvider) * 100).round(),
          ref.watch(groceryDiscountKindProvider),
          ref.watch(groceryCustomDiscountAmountProvider),
          ref.watch(groceryCustomDiscountUnitProvider)) /
      100;
});

final groceryFinalTotalProvider = Provider<double>((ref) {
  final total = ref.watch(groceryAmountAfterCouponProvider) -
      ref.watch(groceryDiscountAmountProvider);
  return total < 0 ? 0 : total;
});

// ── Payment method ───────────────────────────────────────────────────────

enum GroceryPaymentMethod {
  cash('Cash', 'F1'),
  card('Card', 'F2'),
  gcash('GCash', 'F3'),
  qrph('QR Ph', 'F4');

  const GroceryPaymentMethod(this.label, this.shortcutLabel);
  final String label;
  final String shortcutLabel;
}

final groceryPaymentMethodProvider =
    StateProvider<GroceryPaymentMethod?>((ref) => null);

// ── Receipt ──────────────────────────────────────────────────────────────

int grocerySubtotalCentavos(List<GroceryCartItem> items) => items.fold(
    0, (sum, item) => sum + (item.product.price * 100).round() * item.quantity);

int groceryCouponCentavos(int subtotal, GroceryCoupon? coupon) =>
    ((coupon?.amountOff ?? 0) * 100).round().clamp(0, subtotal);

int groceryDiscountCentavos(int base, GroceryDiscountKind? kind, String custom,
    GroceryDiscountUnit unit) {
  if (kind != GroceryDiscountKind.custom) return 0;
  try {
    return commercialDiscountAmount(base, custom,
        percentage: unit == GroceryDiscountUnit.percent);
  } on ArgumentError {
    return 0;
  }
}
