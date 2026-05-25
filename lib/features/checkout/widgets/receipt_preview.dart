import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/checkout_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final txnId = order.id.length >= 12
        ? order.id.substring(0, 12).toUpperCase()
        : order.id.toUpperCase();

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Success check ───────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(height: AppSizes.md),
              const Text('Payment Successful!',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray800)),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM dd, yyyy  hh:mm a')
                    .format(order.timestamp),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.gray400),
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Receipt card ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.rCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/xantara-logo.png',
                            height: 20,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                        const SizedBox(width: AppSizes.sm),
                        const Text('Xantara POS',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.gray800)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'TXN: $txnId',
                      style: GoogleFonts.dmMono(
                          fontSize: 10, color: AppColors.gray400),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _DashedDivider(),
                    const SizedBox(height: AppSizes.md),

                    // Items
                    ...order.items.map((item) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity}×',
                                  style: const TextStyle(
                                      color: AppColors.gray400,
                                      fontSize: 12)),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(item.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray800)),
                              ),
                              Text(
                                '₱${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.gray800),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: AppSizes.md),
                    _DashedDivider(),
                    const SizedBox(height: AppSizes.md),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.gray800)),
                        Text('₱${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // Payment details
                    _ReceiptRow(
                      label: 'Payment',
                      value: order.paymentMethod == PaymentMethod.cash
                          ? 'Cash'
                          : order.paymentMethod == PaymentMethod.card
                              ? 'Card'
                              : 'GCash / Maya',
                    ),
                    if (order.paymentMethod == PaymentMethod.cash) ...[
                      _ReceiptRow(
                        label: 'Cash Received',
                        value:
                            '₱${order.cashReceived?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      _ReceiptRow(
                        label: 'Change',
                        value:
                            '₱${order.change?.toStringAsFixed(2) ?? '0.00'}',
                        valueColor: AppColors.success,
                      ),
                    ],

                    const SizedBox(height: AppSizes.md),
                    const Center(
                      child: Text(
                        'Thank you for your purchase!',
                        style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.gray400),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Done CTA
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.rButton)),
                  ),
                  child: const Text('New Sale',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.gray600, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.gray800)),
          ],
        ),
      );
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      const dashW = 6.0;
      const gap = 4.0;
      final count = (constraints.maxWidth / (dashW + gap)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Container(
            width: dashW,
            height: 1,
            margin: const EdgeInsets.only(right: gap),
            color: AppColors.gray200,
          ),
        ),
      );
    });
  }
}
