import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/grocery_cart_provider.dart';

/// Opens the payment dialog for [amountDue] (already net of coupon and any
/// discount picked in the payment panel). Shows a cash-received/change field
/// for the Cash method, or a reference number field for Card/GCash/QR Ph.
/// Returns a receipt snapshot if confirmed, or null if cancelled.
Future<GroceryReceiptData?> showGroceryPaymentDialog(
  BuildContext context, {
  required double amountDue,
}) {
  return showDialog<GroceryReceiptData>(
    context: context,
    builder: (_) => _GroceryPaymentDialog(amountDue: amountDue),
  );
}

class _GroceryPaymentDialog extends ConsumerStatefulWidget {
  const _GroceryPaymentDialog({required this.amountDue});

  final double amountDue;

  @override
  ConsumerState<_GroceryPaymentDialog> createState() => _GroceryPaymentDialogState();
}

class _GroceryPaymentDialogState extends ConsumerState<_GroceryPaymentDialog> {
  final _cashCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();

  double get _cashReceived => double.tryParse(_cashCtrl.text.trim()) ?? 0;

  double get _change => _cashReceived - widget.amountDue;

  @override
  void dispose() {
    _cashCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final method = ref.watch(groceryPaymentMethodProvider) ?? GroceryPaymentMethod.cash;
    final isCash = method == GroceryPaymentMethod.cash;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment', style: AppTextStyles.titleLg),
              const SizedBox(height: 2),
              Text('Confirm the transaction',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.gray600)),
              const SizedBox(height: AppSizes.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.rCard),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total due',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
                    Text('₱${widget.amountDue.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMd),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              if (isCash) ...[
                const Text('CASH RECEIVED', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _cashCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                  ],
                  style: AppTextStyles.titleMd,
                  decoration: InputDecoration(
                    prefixText: '₱  ',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.rInput)),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _confirm(),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppSizes.rCard),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Change', style: AppTextStyles.bodyMd),
                      Text(
                        _cashReceived <= 0 ? '—' : '₱${_change.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMd.copyWith(
                          color: _change >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text('REFERENCE NUMBER', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _referenceCtrl,
                  autofocus: true,
                  style: AppTextStyles.titleMd,
                  decoration: InputDecoration(
                    hintText: 'Enter reference number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.rInput)),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _confirm(),
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.rButton)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canConfirm ? _confirm : null,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.rButton)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canConfirm {
    final method = ref.read(groceryPaymentMethodProvider) ?? GroceryPaymentMethod.cash;
    if (method == GroceryPaymentMethod.cash) return _change >= 0;
    return _referenceCtrl.text.trim().isNotEmpty;
  }

  void _confirm() {
    if (!_canConfirm) return;
    final method = ref.read(groceryPaymentMethodProvider) ?? GroceryPaymentMethod.cash;
    final isCash = method == GroceryPaymentMethod.cash;
    final discountKind = ref.read(groceryDiscountKindProvider);
    final txn = ref.read(groceryTxnCounterProvider);

    final receipt = GroceryReceiptData(
      items: ref
          .read(groceryCartProvider)
          .map((i) => GroceryReceiptItem(
                name: i.product.name,
                quantity: i.quantity,
                unitPrice: i.product.price,
                lineTotal: i.lineTotal,
              ))
          .toList(),
      subtotal: ref.read(groceryCartSubtotalProvider),
      coupon: ref.read(groceryCouponProvider),
      discountLabel: switch (discountKind) {
        GroceryDiscountKind.seniorPwd => 'SENIOR / PWD DISC (20%)',
        GroceryDiscountKind.custom => 'OTHERS DISC',
        null => null,
      },
      discountAmount: ref.read(groceryDiscountAmountProvider),
      total: widget.amountDue,
      method: method,
      cashReceived: isCash ? _cashReceived : null,
      change: isCash ? _change : null,
      referenceNumber: isCash ? null : _referenceCtrl.text.trim(),
      cashierName: ref.read(authProvider).user?.name ?? 'Cashier',
      txnNumber: txn,
      dateTime: DateTime.now(),
    );

    ref.read(groceryTxnCounterProvider.notifier).state = txn + 1;
    ref.read(groceryCartProvider.notifier).clear();
    ref.read(groceryCouponProvider.notifier).state = null;
    ref.read(groceryDiscountKindProvider.notifier).state = null;
    ref.read(groceryCustomDiscountAmountProvider.notifier).state = '';
    ref.read(groceryPaymentMethodProvider.notifier).state = null;
    Navigator.pop(context, receipt);
  }
}
