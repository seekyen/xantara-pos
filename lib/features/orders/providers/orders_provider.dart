import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../checkout/providers/checkout_provider.dart';

class OrderRecord {
  final Order order;
  final bool isVoided;

  const OrderRecord({required this.order, this.isVoided = false});

  OrderRecord copyWith({bool? isVoided}) =>
      OrderRecord(order: order, isVoided: isVoided ?? this.isVoided);
}

class OrdersNotifier extends StateNotifier<List<OrderRecord>> {
  OrdersNotifier() : super([]);

  void addOrder(Order order) {
    state = [OrderRecord(order: order), ...state];
  }

  void voidOrder(String orderId) {
    state = state.map((r) {
      return r.order.id == orderId ? r.copyWith(isVoided: true) : r;
    }).toList();
  }

  void clear() => state = [];
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderRecord>>(
  (ref) => OrdersNotifier(),
);

// Void permission PIN — static for now, configurable from admin later
const voidPermissionCode = '1234';
