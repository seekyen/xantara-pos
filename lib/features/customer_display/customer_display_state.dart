import 'package:flutter/foundation.dart';
import '../checkout/providers/checkout_provider.dart';

enum CustomerDisplayScreen { idle, order, tip, payment, confirmation }

// CUSTOMER_DISPLAY — shared ChangeNotifier state for both windows.
// Main window (cashier) drives: updateOrder, proceedToTip, completeTransaction, reset.
// Customer window drives: setTip, selectPaymentMethod, setTenderedAmount.
class CustomerDisplayState extends ChangeNotifier {
  List<OrderItem> orderItems = [];
  double subtotal = 0;
  double tax = 0;
  double discount = 0;
  double tip = 0;
  double total = 0;
  double tenderedAmount = 0;
  double get changeDue => (tenderedAmount - total).clamp(0, double.infinity);
  PaymentMethod? selectedPaymentMethod;
  CustomerDisplayScreen currentScreen = CustomerDisplayScreen.idle;

  void updateOrder(
    List<OrderItem> items, {
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
  }) {
    orderItems = items;
    this.subtotal = subtotal;
    this.tax = tax;
    this.discount = discount;
    this.total = total;
    currentScreen = CustomerDisplayScreen.order;
    notifyListeners();
  }

  void proceedToTip() {
    currentScreen = CustomerDisplayScreen.tip;
    notifyListeners();
  }

  void setTip(double amount) {
    tip = amount;
    total = subtotal + tax - discount + amount;
    notifyListeners();
  }

  void proceedToPayment({
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
  }) {
    if (subtotal != null) this.subtotal = subtotal;
    if (tax != null) this.tax = tax;
    if (discount != null) this.discount = discount;
    if (total != null) this.total = total;
    currentScreen = CustomerDisplayScreen.payment;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void setTenderedAmount(double amount) {
    tenderedAmount = amount;
    notifyListeners();
  }

  void completeTransaction() {
    currentScreen = CustomerDisplayScreen.confirmation;
    notifyListeners();
  }

  void reset() {
    orderItems = [];
    subtotal = 0;
    tax = 0;
    discount = 0;
    tip = 0;
    total = 0;
    tenderedAmount = 0;
    selectedPaymentMethod = null;
    currentScreen = CustomerDisplayScreen.idle;
    notifyListeners();
  }

  // Deserialise an updateOrder payload received via method channel.
  void applyUpdateOrderPayload(Map<String, dynamic> data) {
    final rawItems = data['items'] as List<dynamic>;
    updateOrder(
      rawItems
          .map((i) => OrderItem(
                name: i['name'] as String,
                price: (i['price'] as num).toDouble(),
                quantity: i['quantity'] as int,
                subtotal: (i['subtotal'] as num).toDouble(),
              ))
          .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      discount: (data['discount'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
    );
  }
}
