import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'customer_display_state.dart';
import 'providers/customer_display_providers.dart';
import 'screens/idle_screen.dart';
import 'screens/order_screen.dart';
import 'screens/payment_screen.dart';

// CUSTOMER_DISPLAY — root widget for the secondary customer-facing window.
class CustomerDisplayApp extends ConsumerWidget {
  const CustomerDisplayApp({super.key, required this.windowId});
  final int windowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Customer Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
      ),
      home: _CustomerDisplayShell(windowId: windowId),
    );
  }
}

// CUSTOMER_DISPLAY — routes to the correct screen based on CustomerDisplayState.
// Also wires the incoming method channel from the cashier window.
class _CustomerDisplayShell extends ConsumerStatefulWidget {
  const _CustomerDisplayShell({required this.windowId});
  final int windowId;

  @override
  ConsumerState<_CustomerDisplayShell> createState() =>
      _CustomerDisplayShellState();
}

class _CustomerDisplayShellState
    extends ConsumerState<_CustomerDisplayShell> {
  @override
  void initState() {
    super.initState();
    _setupMethodChannelHandler();
  }

  void _setupMethodChannelHandler() {
    // CUSTOMER_DISPLAY — listen for commands sent from the cashier window.
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      final state = ref.read(customerDisplayStateProvider);
      switch (call.method) {
        case 'updateOrder':
          final data =
              jsonDecode(call.arguments as String) as Map<String, dynamic>;
          state.applyUpdateOrderPayload(data);
        case 'proceedToTip':
          state.proceedToTip();
        case 'proceedToPayment':
          final pd =
              jsonDecode(call.arguments as String) as Map<String, dynamic>;
          state.proceedToPayment(
            subtotal: (pd['subtotal'] as num).toDouble(),
            tax: (pd['tax'] as num).toDouble(),
            discount: (pd['discount'] as num).toDouble(),
            total: (pd['total'] as num).toDouble(),
          );
        case 'completeTransaction':
          state.completeTransaction();
        case 'reset':
          state.reset();
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen =
        ref.watch(customerDisplayStateProvider.select((s) => s.currentScreen));

    // CUSTOMER_DISPLAY — screen router
    return switch (screen) {
      CustomerDisplayScreen.idle => const IdleScreen(),
      // Remaining screens added after confirmation:
      CustomerDisplayScreen.order => const OrderScreen(),
      CustomerDisplayScreen.tip => const IdleScreen(), // placeholder
      CustomerDisplayScreen.payment => const PaymentScreen(),
      CustomerDisplayScreen.confirmation => const IdleScreen(), // placeholder
    };
  }
}
