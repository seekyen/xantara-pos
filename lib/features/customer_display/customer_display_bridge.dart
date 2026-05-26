import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../checkout/providers/checkout_provider.dart';
import 'customer_display_state.dart';

// CUSTOMER_DISPLAY — method channel bridge between the cashier window and the
// customer display window. All cross-window messages go through here.
//
// Naming convention for method names:
//   cashier → customer display : camelCase, e.g. 'updateOrder'
//   customer display → cashier : prefixed with 'cd_', e.g. 'cd_setTip'
class CustomerDisplayBridge {
  CustomerDisplayBridge._();

  // ── Cashier → Customer display ─────────────────────────────────────────────

  static Future<void> sendUpdateOrder(
      int windowId, CustomerDisplayState state) async {
    await _send(
      windowId,
      'updateOrder',
      jsonEncode({
        'items': state.orderItems
            .map((i) => {
                  'name': i.name,
                  'price': i.price,
                  'quantity': i.quantity,
                  'subtotal': i.subtotal,
                })
            .toList(),
        'subtotal': state.subtotal,
        'tax': state.tax,
        'discount': state.discount,
        'total': state.total,
      }),
    );
  }

  static Future<void> sendProceedToTip(int windowId) =>
      _send(windowId, 'proceedToTip');

  static Future<void> sendProceedToPayment(
    int windowId, {
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
  }) =>
      _send(
        windowId,
        'proceedToPayment',
        jsonEncode({
          'subtotal': subtotal,
          'tax': tax,
          'discount': discount,
          'total': total,
        }),
      );

  static Future<void> sendCompleteTransaction(
      int windowId, CustomerDisplayState state) async {
    await _send(
      windowId,
      'completeTransaction',
      jsonEncode({
        'items': state.orderItems
            .map((i) => {
                  'name': i.name,
                  'price': i.price,
                  'quantity': i.quantity,
                  'subtotal': i.subtotal,
                })
            .toList(),
        'subtotal': state.subtotal,
        'tax': state.tax,
        'discount': state.discount,
        'tip': state.tip,
        'total': state.total,
        'paymentMethod': state.selectedPaymentMethod?.name,
      }),
    );
  }

  static Future<void> sendReset(int windowId) => _send(windowId, 'reset');

  // ── Customer display → Cashier (set up listener in cashier window) ─────────

  // Called once from the cashier window. The provided [onMessage] callback is
  // invoked for every inbound message from the customer display.
  static void listenFromCustomerDisplay({
    required void Function(String method, dynamic args) onMessage,
  }) {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      onMessage(call.method, call.arguments);
      return null;
    });
  }

  // ── Customer display → Cashier (send from customer display window) ─────────

  static Future<void> replySetTip(int cashierWindowId, double amount) =>
      _send(cashierWindowId, 'cd_setTip', jsonEncode({'amount': amount}));

  static Future<void> replySelectPaymentMethod(
          int cashierWindowId, PaymentMethod method) =>
      _send(cashierWindowId, 'cd_selectPaymentMethod',
          jsonEncode({'method': method.name}));

  static Future<void> replySetTenderedAmount(
          int cashierWindowId, double amount) =>
      _send(cashierWindowId, 'cd_setTenderedAmount',
          jsonEncode({'amount': amount}));

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _send(int windowId, String method,
      [dynamic args]) async {
    try {
      await DesktopMultiWindow.invokeMethod(windowId, method, args);
    } catch (_) {
      // Window may have been closed; silently ignore.
    }
  }
}
