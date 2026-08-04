import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  return ref.watch(groceryCartProvider).fold(0.0, (sum, i) => sum + i.lineTotal);
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
  final subtotal = ref.watch(groceryCartSubtotalProvider);
  final coupon = ref.watch(groceryCouponProvider);
  final afterCoupon = subtotal - (coupon?.amountOff ?? 0);
  return afterCoupon < 0 ? 0 : afterCoupon;
});

// ── Discount ─────────────────────────────────────────────────────────────

enum GroceryDiscountKind { seniorPwd, custom }

enum GroceryDiscountUnit { percent, peso }

final groceryDiscountKindProvider = StateProvider<GroceryDiscountKind?>((ref) => null);
final groceryCustomDiscountAmountProvider = StateProvider<String>((ref) => '');
final groceryCustomDiscountUnitProvider =
    StateProvider<GroceryDiscountUnit>((ref) => GroceryDiscountUnit.percent);

final groceryDiscountAmountProvider = Provider<double>((ref) {
  final base = ref.watch(groceryAmountAfterCouponProvider);
  switch (ref.watch(groceryDiscountKindProvider)) {
    case GroceryDiscountKind.seniorPwd:
      return base * 0.20;
    case GroceryDiscountKind.custom:
      final raw = double.tryParse(ref.watch(groceryCustomDiscountAmountProvider)) ?? 0;
      if (raw <= 0) return 0;
      final unit = ref.watch(groceryCustomDiscountUnitProvider);
      return unit == GroceryDiscountUnit.percent ? base * (raw / 100) : raw;
    case null:
      return 0;
  }
});

final groceryFinalTotalProvider = Provider<double>((ref) {
  final total =
      ref.watch(groceryAmountAfterCouponProvider) - ref.watch(groceryDiscountAmountProvider);
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

/// Simple per-session transaction counter for the TXN# printed on receipts.
final groceryTxnCounterProvider = StateProvider<int>((ref) => 1);

class GroceryReceiptItem {
  const GroceryReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
}

/// Snapshot of a completed transaction — captured before the cart/coupon/
/// discount/method state gets cleared, so the receipt keeps showing the
/// right figures after checkout resets.
class GroceryReceiptData {
  const GroceryReceiptData({
    required this.items,
    required this.subtotal,
    required this.coupon,
    required this.discountLabel,
    required this.discountAmount,
    required this.total,
    required this.method,
    required this.cashReceived,
    required this.change,
    required this.referenceNumber,
    required this.cashierName,
    required this.txnNumber,
    required this.dateTime,
  });

  final List<GroceryReceiptItem> items;
  final double subtotal;
  final GroceryCoupon? coupon;
  final String? discountLabel;
  final double discountAmount;
  final double total;
  final GroceryPaymentMethod method;
  final double? cashReceived;
  final double? change;
  final String? referenceNumber;
  final String cashierName;
  final int txnNumber;
  final DateTime dateTime;
}
