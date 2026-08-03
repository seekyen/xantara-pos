import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/providers/cart_provider.dart';
import '../../pos/providers/pos_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/receipt_preview.dart';
import '../../../core/auth/pos_authorization.dart';
import '../../../core/payments/payment.dart';
import '../../../local/database_providers.dart';
import '../../../local/database_seed.dart';
import '../../../local/repositories/offline_sale_repository.dart';
import '../../../shared/widgets/supervisor_authorization_dialog.dart';
import '../../customer_display/customer_display_bridge.dart';
import '../../customer_display/providers/customer_display_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _onPaymentPage = false;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _promoController = TextEditingController();
  final _paymentReferenceController = TextEditingController();
  double _discount = 0;
  double _tendered = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _promoController.dispose();
    _paymentReferenceController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    setState(() => _discount = code == 'DISC200' ? 200.0 : 0.0);
  }

  List<_TenderedOption> _tenderedOptions(double total) {
    final a1 = (total / 500).ceil() * 500.0;
    final a2 = (total / 1000).ceil() * 1000.0 + 500;
    final a3 = (total / 5000).ceil() * 5000.0;
    return [
      _TenderedOption(a1, '₱${a1.toStringAsFixed(0)}'),
      _TenderedOption(a2, '₱${a2.toStringAsFixed(0)}'),
      _TenderedOption(a3, '₱${a3.toStringAsFixed(0)}'),
      _TenderedOption(total, 'Exact'),
    ];
  }

  bool _canConfirm(double total) {
    if (_selectedMethod == PaymentMethod.cash) return _tendered >= total;
    return _paymentReferenceController.text.trim().isNotEmpty;
  }

  void _showVoidDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirmed,
  }) {
    final branchId = branchIdForCode(ref.read(activeBranchProvider));
    showSupervisorAuthorizationDialog(
      context,
      title: title,
      message: message,
      permission: PosPermission.voidInvoice,
      branchId: branchId,
    ).then((supervisor) {
      if (supervisor != null) onConfirmed();
    });
  }

  List<OfflineSaleLineRequest> _buildSaleLines(List<CartItem> cartItems) {
    var remainingDiscount = (_discount * 100).round();
    return cartItems.map((item) {
      final unitPriceCentavos = (item.product.price * 100).round();
      final gross = unitPriceCentavos * item.quantity;
      final lineDiscount = remainingDiscount.clamp(0, gross);
      remainingDiscount -= lineDiscount;
      return OfflineSaleLineRequest(
        productId: item.product.id,
        quantity: item.quantity,
        discountCentavos: lineDiscount,
      );
    }).toList(growable: false);
  }

  Future<void> _confirmPayment(List<CartItem> cartItems, double total) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Only cash is wired to a real payment path today — see
    // docs/PAYMENT_ARCHITECTURE.md.
    final cashReceived = _tendered > 0 ? _tendered : total;
    final totalCentavos = (total * 100).round();
    final issuedAt = DateTime.now();
    final branchId = branchIdForCode(ref.read(activeBranchProvider));
    final terminalId = terminalIdForBranch(branchId);
    final actor = ref.read(authProvider).user;

    try {
      if (actor == null) {
        throw StateError('You must be signed in to complete a sale.');
      }
      final payment = await CashPaymentGateway(
        createEvidenceId: () => const Uuid().v4(),
      ).capture(PaymentRequest(
        idempotencyKey: const Uuid().v4(),
        amountCentavos: totalCentavos,
        provider: PaymentProvider.cash,
        requestedAt: issuedAt,
        cashTenderedCentavos: (cashReceived * 100).round(),
      ));

      final invoice = await ref.read(offlineSaleRepositoryProvider).issueSale(
            OfflineSaleRequest(
              branchId: branchId,
              terminalId: terminalId,
              actorId: actor.id,
              issuedAt: issuedAt,
              payment: payment,
              sellerName: trainingMerchantProfile.registeredName,
              sellerTin: trainingMerchantProfile.tin,
              sellerAddress: trainingMerchantProfile.registeredAddress,
              registrationType: trainingMerchantProfile.registrationType,
              softwareName: trainingMerchantProfile.softwareName,
              softwareVersion: trainingMerchantProfile.softwareVersion,
              lines: _buildSaleLines(cartItems),
            ),
          );
      await drainHardwareJobQueue(ref.read(hardwareJobProcessorProvider));

      final order = buildOrder(
        id: invoice.id,
        timestamp: issuedAt,
        cartItems: cartItems,
        total: total,
        method: PaymentMethod.cash,
        cashReceived: cashReceived,
        birReceipt: birReceiptFromInvoice(invoice),
        paymentReference: payment.reference,
      );

      ref.read(lastOrderProvider.notifier).state = order;
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReceiptPreview(order: order),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale was not recorded: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = cartItems.fold(0.0, (s, i) => s + i.subtotal);
    final total = (subtotal - _discount).clamp(0.0, double.infinity);
    final totalCentavos = (total * 100).round();
    final vatableCentavos = (totalCentavos * 10000 / 11200).round();
    final vat = (totalCentavos - vatableCentavos) / 100;

    // Sync customer display payment selection back to the cashier screen.
    ref.listen<PaymentMethod?>(
      customerDisplayStateProvider.select((s) => s.selectedPaymentMethod),
      (_, method) {
        if (method != null && _onPaymentPage) {
          setState(() {
            _selectedMethod = method;
            _tendered = 0;
          });
        }
      },
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.gray50,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizes.rPhone)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: AppSizes.sm + 2),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: AppSizes.xs),
            Expanded(
              child: _onPaymentPage
                  ? _PaymentPage(
                      total: total,
                      selectedMethod: _selectedMethod,
                      tendered: _tendered,
                      tenderedOptions: _tenderedOptions(total),
                      paymentReferenceController: _paymentReferenceController,
                      canConfirm: !_isProcessing && _canConfirm(total),
                      onBack: () => setState(() => _onPaymentPage = false),
                      onMethodSelected: (m) => setState(() {
                        _selectedMethod = m;
                        _tendered = 0;
                        _paymentReferenceController.clear();
                      }),
                      onReferenceChanged: (_) => setState(() {}),
                      onTenderedSelected: (t) => setState(() => _tendered = t),
                      onConfirm: () => _confirmPayment(cartItems, total),
                      scrollController: controller,
                    )
                  : _CartPage(
                      cartItems: cartItems,
                      subtotal: subtotal,
                      vat: vat,
                      discount: _discount,
                      total: total,
                      promoController: _promoController,
                      onApplyPromo: _applyPromo,
                      onProceed: cartItems.isNotEmpty
                          ? () {
                              setState(() => _onPaymentPage = true);
                              final windowId =
                                  ref.read(customerDisplayWindowIdProvider);
                              if (windowId != null) {
                                CustomerDisplayBridge.sendProceedToPayment(
                                  windowId,
                                  subtotal: subtotal,
                                  tax: vat,
                                  discount: _discount,
                                  total: total,
                                ).ignore();
                              }
                            }
                          : null,
                      onClose: () => Navigator.pop(context),
                      onClear: () => _showVoidDialog(
                        context: context,
                        title: 'Clear Cart',
                        message:
                            'Clearing the cart requires supervisor permission.',
                        onConfirmed: () =>
                            ref.read(cartProvider.notifier).clear(),
                      ),
                      onDecrement: (item) {
                        if (item.quantity == 1) {
                          _showVoidDialog(
                            context: context,
                            title: 'Remove Item',
                            message:
                                'Removing "${item.product.name}" requires supervisor permission.',
                            onConfirmed: () => ref
                                .read(cartProvider.notifier)
                                .decrement(item.product.id),
                          );
                        } else {
                          ref
                              .read(cartProvider.notifier)
                              .decrement(item.product.id);
                        }
                      },
                      onIncrement: (item) => ref
                          .read(cartProvider.notifier)
                          .increment(item.product.id),
                      scrollController: controller,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart page ─────────────────────────────────────────────────────────────────

class _CartPage extends StatelessWidget {
  const _CartPage({
    required this.cartItems,
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.total,
    required this.promoController,
    required this.onApplyPromo,
    required this.onProceed,
    required this.onClose,
    required this.onClear,
    required this.onDecrement,
    required this.onIncrement,
    required this.scrollController,
  });

  final List<CartItem> cartItems;
  final double subtotal;
  final double vat;
  final double discount;
  final double total;
  final TextEditingController promoController;
  final VoidCallback onApplyPromo;
  final VoidCallback? onProceed;
  final VoidCallback onClose;
  final VoidCallback onClear;
  final void Function(CartItem) onDecrement;
  final void Function(CartItem) onIncrement;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────
        Padding(
          padding:
              const EdgeInsets.fromLTRB(AppSizes.xs, 0, AppSizes.screenH, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.gray800),
                onPressed: onClose,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cart', style: AppTextStyles.titleLg),
                  Text(
                    '${cartItems.length} item${cartItems.length != 1 ? 's' : ''}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppSizes.rPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('Synced',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              if (cartItems.isNotEmpty) ...[
                const SizedBox(width: AppSizes.sm),
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(AppSizes.rPill),
                    ),
                    child: Text('Clear',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.gray600)),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Scrollable body ───────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.screenH, AppSizes.sm, AppSizes.screenH, AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cartItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.rCard),
                            ),
                            child: const Icon(Icons.shopping_cart_outlined,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text('Cart is empty',
                              style: AppTextStyles.labelMd
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Add items from the product grid',
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.gray400)),
                        ],
                      ),
                    ),
                  )
                else
                  ...cartItems.map((item) => _CartItemCard(
                        item: item,
                        onDecrement: () => onDecrement(item),
                        onIncrement: () => onIncrement(item),
                      )),

                const SizedBox(height: AppSizes.lg),

                // ── Discount ─────────────────────────────────────────
                const Text('DISCOUNT', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: promoController,
                  decoration: InputDecoration(
                    hintText: 'Promo code...',
                    hintStyle: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.gray400),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: AppColors.gray400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg, vertical: AppSizes.md),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => onApplyPromo(),
                ),

                if (discount > 0) ...[
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppSizes.rPill),
                    ),
                    child: Text(
                      'Promo applied: -₱${discount.toStringAsFixed(0)}',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.lg),

                // ── Summary card ──────────────────────────────────────
                if (cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        _SummaryLine(
                            'Subtotal', '₱${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _SummaryLine(
                            'VAT included (12%)', '₱${vat.toStringAsFixed(2)}'),
                        if (discount > 0) ...[
                          const SizedBox(height: 8),
                          _SummaryLine(
                              'Discount', '-₱${discount.toStringAsFixed(2)}',
                              valueColor: AppColors.success),
                        ],
                        const SizedBox(height: AppSizes.md),
                        const Divider(height: 1, color: AppColors.gray100),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: [
                            const Text('Total', style: AppTextStyles.titleMd),
                            const Spacer(),
                            Text(
                              '₱${total.toStringAsFixed(2)}',
                              style: AppTextStyles.displayMd
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Proceed button ────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.screenH,
            AppSizes.sm,
            AppSizes.screenH,
            MediaQuery.of(context).padding.bottom + AppSizes.md,
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.gray200,
                disabledForegroundColor: AppColors.gray400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.rButton)),
              ),
              child: Text('Proceed to Payment',
                  style: AppTextStyles.titleMd.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Cart item card ────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
  });
  final CartItem item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'beverages':
        return Icons.local_cafe_rounded;
      case 'food':
        return Icons.fastfood_rounded;
      case 'snacks':
        return Icons.cookie_rounded;
      case 'desserts':
        return Icons.cake_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  String _categoryLabel(String categoryId) =>
      categoryId[0].toUpperCase() + categoryId.substring(1);

  @override
  Widget build(BuildContext context) {
    final priceLabel = item.quantity > 1
        ? '₱${item.product.price.toStringAsFixed(0)} × ${item.quantity}'
        : '₱${item.product.price.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.product.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.rInput),
            ),
            child: Icon(_categoryIcon(item.product.categoryId),
                size: 20, color: item.product.color),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _categoryLabel(item.product.categoryId),
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  priceLabel,
                  style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrement, filled: false),
              SizedBox(
                width: 30,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSm.copyWith(fontSize: 14),
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: onIncrement, filled: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton(
      {required this.icon, required this.onTap, required this.filled});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
        ),
        child: Icon(icon,
            size: 14, color: filled ? Colors.white : AppColors.gray800),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
        Text(value,
            style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.gray800)),
      ],
    );
  }
}

// ── Payment page ──────────────────────────────────────────────────────────────

class _PaymentPage extends StatelessWidget {
  const _PaymentPage({
    required this.total,
    required this.selectedMethod,
    required this.tendered,
    required this.tenderedOptions,
    required this.paymentReferenceController,
    required this.canConfirm,
    required this.onBack,
    required this.onMethodSelected,
    required this.onTenderedSelected,
    required this.onReferenceChanged,
    required this.onConfirm,
    required this.scrollController,
  });

  final double total;
  final PaymentMethod selectedMethod;
  final double tendered;
  final List<_TenderedOption> tenderedOptions;
  final TextEditingController paymentReferenceController;
  final bool canConfirm;
  final VoidCallback onBack;
  final void Function(PaymentMethod) onMethodSelected;
  final void Function(double) onTenderedSelected;
  final ValueChanged<String> onReferenceChanged;
  final VoidCallback onConfirm;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final change = tendered - total;

    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────
        Padding(
          padding:
              const EdgeInsets.fromLTRB(AppSizes.xs, 0, AppSizes.screenH, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.gray800),
                onPressed: onBack,
              ),
              const Text('Payment', style: AppTextStyles.titleLg),
            ],
          ),
        ),

        // ── Scrollable body ───────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.screenH, AppSizes.sm, AppSizes.screenH, AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Due card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg, vertical: AppSizes.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.rCard),
                  ),
                  child: Column(
                    children: [
                      Text('Amount Due',
                          style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        '₱${total.toStringAsFixed(2)}',
                        style: AppTextStyles.heroNumber
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Payment methods
                const Text('PAYMENT METHOD', style: AppTextStyles.labelCaps),
                const SizedBox(height: AppSizes.sm),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.rCard),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    children: [
                      _PaymentMethodTile(
                        icon: Icons.credit_card_outlined,
                        label: 'Credit / Debit Card',
                        subtitle: 'Requires a configured payment gateway',
                        selected: selectedMethod == PaymentMethod.card,
                        enabled: false,
                        onTap: () => onMethodSelected(PaymentMethod.card),
                      ),
                      const Divider(
                          height: 1,
                          color: AppColors.gray100,
                          indent: AppSizes.screenH),
                      _PaymentMethodTile(
                        icon: Icons.attach_money_rounded,
                        label: 'Cash',
                        subtitle: 'Manual entry',
                        selected: selectedMethod == PaymentMethod.cash,
                        onTap: () => onMethodSelected(PaymentMethod.cash),
                      ),
                      const Divider(
                          height: 1,
                          color: AppColors.gray100,
                          indent: AppSizes.screenH),
                      _PaymentMethodTile(
                        icon: Icons.phone_android_rounded,
                        label: 'GCash',
                        subtitle: 'Requires a configured payment gateway',
                        selected: selectedMethod == PaymentMethod.gcash,
                        enabled: false,
                        onTap: () => onMethodSelected(PaymentMethod.gcash),
                      ),
                      const Divider(
                          height: 1,
                          color: AppColors.gray100,
                          indent: AppSizes.screenH),
                      _PaymentMethodTile(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Maya',
                        subtitle: 'Requires a configured payment gateway',
                        selected: selectedMethod == PaymentMethod.maya,
                        enabled: false,
                        onTap: () => onMethodSelected(PaymentMethod.maya),
                      ),
                      const Divider(
                          height: 1,
                          color: AppColors.gray100,
                          indent: AppSizes.screenH),
                      _PaymentMethodTile(
                        icon: Icons.account_balance_outlined,
                        label: 'Bank Transfer',
                        subtitle: 'Requires a configured payment gateway',
                        selected: selectedMethod == PaymentMethod.bank,
                        enabled: false,
                        onTap: () => onMethodSelected(PaymentMethod.bank),
                      ),
                    ],
                  ),
                ),

                // Tendered amount — cash only
                if (selectedMethod == PaymentMethod.cash) ...[
                  const SizedBox(height: AppSizes.lg),
                  const Text('TENDERED AMOUNT', style: AppTextStyles.labelCaps),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: tenderedOptions.map((opt) {
                      final isSelected = tendered == opt.amount;
                      return GestureDetector(
                        onTap: () => onTenderedSelected(opt.amount),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md, vertical: AppSizes.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.white,
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.gray200),
                            borderRadius: BorderRadius.circular(AppSizes.rPill),
                          ),
                          child: Text(
                            opt.label,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.gray800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Change',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.gray400)),
                      Text(
                        tendered >= total
                            ? '₱${change.toStringAsFixed(0)}'
                            : '—',
                        style: AppTextStyles.titleMd.copyWith(
                          color: tendered >= total
                              ? AppColors.success
                              : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ],

                // QR panel — GCash / Maya
                if (selectedMethod != PaymentMethod.cash) ...[
                  const SizedBox(height: AppSizes.lg),
                  TextField(
                    controller: paymentReferenceController,
                    onChanged: onReferenceChanged,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: '${selectedMethod.label} reference',
                      hintText: 'Enter confirmed transaction reference',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      helperText: 'Required. Verify payment before confirming.',
                    ),
                  ),
                ],
                if (selectedMethod == PaymentMethod.gcash ||
                    selectedMethod == PaymentMethod.maya) ...[
                  const SizedBox(height: AppSizes.lg),
                  _QrPhPanel(total: total, method: selectedMethod),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Confirm button ────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.screenH,
            AppSizes.sm,
            AppSizes.screenH,
            MediaQuery.of(context).padding.bottom + AppSizes.md,
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: canConfirm ? onConfirm : null,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Confirm Payment · ₱${total.toStringAsFixed(0)}',
                style: AppTextStyles.titleMd.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.gray200,
                disabledForegroundColor: AppColors.gray400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.rButton)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Payment method tile ───────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenH, vertical: AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppSizes.rInput),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.primary : AppColors.gray600,
                  size: 18),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.primary : AppColors.gray800),
                  ),
                  Text(subtitle,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.gray400)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.gray200,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.circle, color: Colors.white, size: 8)
                  : null,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Tendered option ───────────────────────────────────────────────────────────

class _TenderedOption {
  const _TenderedOption(this.amount, this.label);
  final double amount;
  final String label;
}

// ── QRPh panel ────────────────────────────────────────────────────────────────

class _QrPhPanel extends StatelessWidget {
  const _QrPhPanel({required this.total, required this.method});
  final double total;
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final qrData =
        'QRPH|${method.name.toUpperCase()}|XANTARA-TRAINING|AMOUNT:${total.toStringAsFixed(2)}|REF:${DateTime.now().millisecondsSinceEpoch}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCardLg),
            border: Border.all(color: AppColors.gray200),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/xantara-logo.png',
                height: 24,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              Text('Scan to Pay',
                  style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.gray400, fontWeight: FontWeight.w500)),
              const SizedBox(height: AppSizes.md),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryDark,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style:
                    AppTextStyles.displayMd.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSizes.rCard),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Training QR only. Verify the ${method.label} payment independently, enter its reference, then confirm.',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
