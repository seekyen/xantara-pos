import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/grocery_cart_provider.dart';
import '../widgets/grocery_item_list.dart';
import '../widgets/grocery_payment_dialog.dart';
import '../widgets/grocery_payment_panel.dart';
import '../widgets/grocery_receipt_dialog.dart';
import '../widgets/grocery_scan_panel.dart';

/// Two-panel Grocery POS: item list + scan bar on the left, payment options
/// and totals on the right. Function keys F1-F4 pick a payment method, F5
/// (or the Charge button) opens the payment dialog. Esc closes the dialog.
class GroceryPosScreen extends ConsumerStatefulWidget {
  const GroceryPosScreen({super.key});

  @override
  ConsumerState<GroceryPosScreen> createState() => _GroceryPosScreenState();
}

class _GroceryPosScreenState extends ConsumerState<GroceryPosScreen> {
  final _scanPanelKey = GlobalKey<GroceryScanPanelState>();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  // Global handler (not focus-chain dependent) so F1-F5 work even while the
  // barcode/coupon/discount fields hold text focus.
  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.f1:
        _selectMethod(GroceryPaymentMethod.cash);
        return true;
      case LogicalKeyboardKey.f2:
        _selectMethod(GroceryPaymentMethod.card);
        return true;
      case LogicalKeyboardKey.f3:
        _selectMethod(GroceryPaymentMethod.gcash);
        return true;
      case LogicalKeyboardKey.f4:
        _selectMethod(GroceryPaymentMethod.qrph);
        return true;
      case LogicalKeyboardKey.f5:
        _openPaymentDialog();
        return true;
      default:
        return false;
    }
  }

  void _onScan(String code, int quantity) {
    final product = findGroceryProductByCode(ref, code);
    _scanPanelKey.currentState?.reportScanResult(code, product);
    if (product != null) {
      ref.read(groceryCartProvider.notifier).scan(product, quantity: quantity);
    }
  }

  void _selectMethod(GroceryPaymentMethod method) {
    ref.read(groceryPaymentMethodProvider.notifier).state = method;
    if (method == GroceryPaymentMethod.cash) _openPaymentDialog();
  }

  Future<void> _openPaymentDialog() async {
    final amountDue = ref.read(groceryFinalTotalProvider);
    if (amountDue <= 0) return;
    final receipt = await showGroceryPaymentDialog(context, amountDue: amountDue);
    if (receipt != null && mounted) {
      await showGroceryReceiptDialog(context, receipt);
    }
    _scanPanelKey.currentState?.focusBarcodeField();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Grocery POS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Expanded(child: GroceryItemList()),
                  const SizedBox(height: AppSizes.md),
                  GroceryScanPanel(key: _scanPanelKey, onScan: _onScan),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.md),
            GroceryPaymentPanel(
              onCharge: _openPaymentDialog,
              onSelectMethod: _selectMethod,
            ),
          ],
        ),
      ),
    );
  }
}
