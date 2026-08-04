import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/grocery_cart_provider.dart';

class GroceryPaymentPanel extends ConsumerStatefulWidget {
  const GroceryPaymentPanel({super.key, required this.onCharge, required this.onSelectMethod});

  final VoidCallback onCharge;
  final void Function(GroceryPaymentMethod method) onSelectMethod;

  @override
  ConsumerState<GroceryPaymentPanel> createState() => _GroceryPaymentPanelState();
}

class _GroceryPaymentPanelState extends ConsumerState<GroceryPaymentPanel> {
  final _couponCtrl = TextEditingController();
  String? _couponError;
  final _customDiscountCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    _customDiscountCtrl.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    final amount = groceryCoupons[code];
    if (amount == null) {
      setState(() => _couponError = 'Invalid coupon code');
      return;
    }
    ref.read(groceryCouponProvider.notifier).state =
        GroceryCoupon(code: code, amountOff: amount);
    setState(() => _couponError = null);
  }

  @override
  Widget build(BuildContext context) {
    final method = ref.watch(groceryPaymentMethodProvider);
    final subtotal = ref.watch(groceryCartSubtotalProvider);
    final coupon = ref.watch(groceryCouponProvider);
    final discountKind = ref.watch(groceryDiscountKindProvider);
    final discountAmount = ref.watch(groceryDiscountAmountProvider);
    final customUnit = ref.watch(groceryCustomDiscountUnitProvider);
    final totalDue = ref.watch(groceryFinalTotalProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Center(child: Text('Payment Options', style: AppTextStyles.titleLg)),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECT METHOD',
                      style: AppTextStyles.labelCaps.copyWith(color: AppColors.gray400)),
                  const SizedBox(height: AppSizes.sm),
                  for (final m in GroceryPaymentMethod.values) ...[
                    _PaymentMethodRow(
                      method: m,
                      selected: method == m,
                      onTap: () => widget.onSelectMethod(m),
                    ),
                    if (m != GroceryPaymentMethod.values.last)
                      const SizedBox(height: AppSizes.sm),
                  ],
                  const SizedBox(height: AppSizes.lg),
                  Text('COUPON',
                      style: AppTextStyles.labelCaps.copyWith(color: AppColors.gray400)),
                  const SizedBox(height: AppSizes.sm),
                  if (coupon == null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCtrl,
                            textCapitalization: TextCapitalization.characters,
                            style: AppTextStyles.bodyMd,
                            decoration: InputDecoration(
                              hintText: 'Enter coupon code',
                              errorText: _couponError,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md, vertical: AppSizes.sm),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.rInput),
                                  borderSide: const BorderSide(color: AppColors.gray200)),
                            ),
                            onSubmitted: (_) => _applyCoupon(),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        ElevatedButton(
                          onPressed: _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gray800,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.rInput)),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(AppSizes.rPill),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_outlined,
                              size: 16, color: AppColors.success),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(coupon.code,
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.success, fontWeight: FontWeight.w600)),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(groceryCouponProvider.notifier).state = null;
                              _couponCtrl.clear();
                            },
                            child: const Text('Remove',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSizes.lg),
                  Text('DISCOUNT',
                      style: AppTextStyles.labelCaps.copyWith(color: AppColors.gray400)),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _DiscountButton(
                          label: 'Senior / PWD',
                          subtitle: '20% off',
                          selected: discountKind == GroceryDiscountKind.seniorPwd,
                          onTap: () => ref.read(groceryDiscountKindProvider.notifier).state =
                              discountKind == GroceryDiscountKind.seniorPwd
                                  ? null
                                  : GroceryDiscountKind.seniorPwd,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _DiscountButton(
                          label: 'Others',
                          subtitle: null,
                          selected: discountKind == GroceryDiscountKind.custom,
                          onTap: () => ref.read(groceryDiscountKindProvider.notifier).state =
                              discountKind == GroceryDiscountKind.custom
                                  ? null
                                  : GroceryDiscountKind.custom,
                        ),
                      ),
                    ],
                  ),
                  if (discountKind == GroceryDiscountKind.custom) ...[
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customDiscountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.bodyMd,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Amount',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md, vertical: AppSizes.sm),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.rInput)),
                            ),
                            onChanged: (v) =>
                                ref.read(groceryCustomDiscountAmountProvider.notifier).state = v,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        DropdownButton<GroceryDiscountUnit>(
                          value: customUnit,
                          items: const [
                            DropdownMenuItem(
                                value: GroceryDiscountUnit.percent, child: Text('%')),
                            DropdownMenuItem(value: GroceryDiscountUnit.peso, child: Text('₱')),
                          ],
                          onChanged: (v) =>
                              ref.read(groceryCustomDiscountUnitProvider.notifier).state = v!,
                        ),
                      ],
                    ),
                  ],
                  if (discountKind != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          discountKind == GroceryDiscountKind.seniorPwd
                              ? 'Senior / PWD (20%)'
                              : 'Discount',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.success),
                        ),
                        Text('— ₱${discountAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSizes.lg),
                  const Divider(color: AppColors.gray200),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
                      Text('₱${subtotal.toStringAsFixed(2)}', style: AppTextStyles.bodyMd),
                    ],
                  ),
                  if (coupon != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Coupon',
                            style:
                                AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
                        Text('— ₱${coupon.amountOff.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.gray800,
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total due',
                                  style: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.whiteOverlay60)),
                              const SizedBox(height: 2),
                              Text('₱${totalDue.toStringAsFixed(2)}',
                                  style: AppTextStyles.titleLg
                                      .copyWith(color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),
                        const Icon(Icons.receipt_long_rounded,
                            color: AppColors.whiteOverlay60, size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: subtotal <= 0 ? null : widget.onCharge,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray800,
                        side: const BorderSide(color: AppColors.gray800),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.rButton)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 18),
                          SizedBox(width: AppSizes.xs),
                          Text('Charge', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountButton extends StatelessWidget {
  const _DiscountButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryLight : null,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.gray200),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.rButton)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(subtitle!,
                style: AppTextStyles.caption.copyWith(
                    color: selected ? AppColors.primary : AppColors.gray400)),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final GroceryPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (method) {
        GroceryPaymentMethod.cash => Icons.payments_rounded,
        GroceryPaymentMethod.card => Icons.credit_card_rounded,
        GroceryPaymentMethod.gcash => Icons.smartphone_rounded,
        GroceryPaymentMethod.qrph => Icons.qr_code_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.rCard),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          border: Border.all(color: selected ? AppColors.gray800 : AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? AppColors.white20 : AppColors.gray50,
                borderRadius: BorderRadius.circular(AppSizes.rInput),
              ),
              child: Icon(_icon,
                  size: 16, color: selected ? Colors.white : AppColors.gray800),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                method.label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: selected ? Colors.white : AppColors.gray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? AppColors.white20 : AppColors.gray50,
                borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
              ),
              child: Text(
                method.shortcutLabel,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? AppColors.whiteOverlay60 : AppColors.gray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
