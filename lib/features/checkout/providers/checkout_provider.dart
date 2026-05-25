import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../pos/providers/cart_provider.dart';

enum PaymentMethod { card, cash, qrph }

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final double? cashReceived;
  final double? change;
  final DateTime timestamp;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
    this.cashReceived,
    this.change,
  });
}

const _uuid = Uuid();

Order buildOrder({
  required List<CartItem> cartItems,
  required double total,
  required PaymentMethod method,
  double? cashReceived,
}) {
  return Order(
    id: _uuid.v4().substring(0, 8).toUpperCase(),
    items: cartItems
        .map((i) => OrderItem(
              name: i.product.name,
              price: i.product.price,
              quantity: i.quantity,
              subtotal: i.subtotal,
            ))
        .toList(),
    total: total,
    paymentMethod: method,
    cashReceived: cashReceived,
    change: cashReceived != null ? cashReceived - total : null,
    timestamp: DateTime.now(),
  );
}

final lastOrderProvider = StateProvider<Order?>((ref) => null);
