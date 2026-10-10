import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/hardware/pos_hardware.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../fnb/providers/pos_provider.dart';
import '../providers/grocery_cart_provider.dart';
import '../providers/grocery_checkout_provider.dart';
import '../../../checkout/widgets/invoice_buyer_fields.dart';
import '../../../checkout/widgets/statutory_discount_fields.dart';

Future<ReceiptPrintData?> showGroceryPaymentDialog(BuildContext context,
        {required double amountDue}) =>
    showDialog<ReceiptPrintData>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GroceryPaymentDialog(amountDue: amountDue));

class _GroceryPaymentDialog extends ConsumerStatefulWidget {
  const _GroceryPaymentDialog({required this.amountDue});
  final double amountDue;
  @override
  ConsumerState<_GroceryPaymentDialog> createState() => _PaymentState();
}

class _PaymentState extends ConsumerState<_GroceryPaymentDialog> {
  final _cash = TextEditingController();
  final _buyer = InvoiceBuyerController();
  bool _busy = false;
  String? _error;
  StatutorySelection? _statutory;
  double get _due => _statutory == null
      ? widget.amountDue
      : _statutory!.quote.totalCentavos / 100;
  int? get _tendered {
    final value = double.tryParse(_cash.text);
    return value != null && value.isFinite && value >= 0
        ? (value * 100).round()
        : null;
  }

  bool get _canPay =>
      !_busy &&
      (ref.read(groceryDiscountKindProvider) != GroceryDiscountKind.seniorPwd ||
          _statutory != null) &&
      _buyer.error == null &&
      _tendered != null &&
      _tendered! >= (_due * 100).round();
  @override
  void dispose() {
    _cash.dispose();
    _buyer.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_canPay) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    ReceiptPrintData receipt;
    try {
      final actor = ref.read(authProvider).user;
      if (actor == null) throw StateError('Sign in to complete the sale.');
      receipt = await ref.read(groceryCheckoutProvider).submit(
          items: ref.read(groceryCartProvider),
          branchCode: ref.read(activeBranchProvider),
          actorId: actor.id,
          buyer: _buyer.value,
          statutoryClaim: _statutory?.claim,
          tenderedCentavos: _tendered!,
          method: ref.read(groceryPaymentMethodProvider) ??
              GroceryPaymentMethod.cash,
          coupon: ref.read(groceryCouponProvider),
          discountKind: ref.read(groceryDiscountKindProvider),
          customDiscount: ref.read(groceryCustomDiscountAmountProvider),
          unit: ref.read(groceryCustomDiscountUnitProvider));
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Sale was not recorded: $e';
        });
      }
      return;
    }
    // Presentation cannot turn a committed invoice into a retryable sale error.
    if (!mounted) return;
    ref.read(groceryCartProvider.notifier).clear();
    ref.read(groceryCouponProvider.notifier).state = null;
    ref.read(groceryDiscountKindProvider.notifier).state = null;
    ref.read(groceryCustomDiscountAmountProvider.notifier).state = '';
    ref.read(groceryPaymentMethodProvider.notifier).state = null;
    Navigator.of(context).pop(receipt);
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: const Text('Cash payment'),
        content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Total due: ₱${_due.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (ref.watch(groceryDiscountKindProvider) ==
                          GroceryDiscountKind.seniorPwd &&
                      _statutory == null)
                    const Text(
                        'Complete beneficiary details below to apply the selected Senior / PWD benefit.'),
                  StatutoryDiscountFields(
                      checkoutType: 'retail',
                      quantities: {
                        for (final i in ref.watch(groceryCartProvider))
                          i.product.id: i.quantity
                      },
                      selection: _statutory,
                      enabled: !_busy,
                      hasOtherDiscount:
                          ref.watch(groceryCouponProvider) != null ||
                              ref.watch(groceryDiscountKindProvider) ==
                                  GroceryDiscountKind.custom,
                      onChanged: (value) => setState(() {
                            _statutory = value;
                            _cash.clear();
                          })),
                  InvoiceBuyerFields(
                      controller: _buyer,
                      enabled: !_busy,
                      onChanged: () => setState(() {})),
                  TextField(
                      key: const ValueKey('grocery-cash-received'),
                      controller: _cash,
                      enabled: !_busy,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'))
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Cash received',
                          prefixText: '₱ ',
                          border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _confirm()),
                  const SizedBox(height: 12),
                  Text(
                      'Change: ₱${((_tendered ?? 0) / 100 - _due).clamp(0, double.infinity).toStringAsFixed(2)}'),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                ]))),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: _canPay ? _confirm : null,
              child: Text(_busy ? 'Saving…' : 'Confirm'))
        ],
      ));
}
