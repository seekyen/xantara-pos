import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/checkout_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/status_banner.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final bir = order.birReceipt;
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
              const Text('Payment Successful!', style: AppTextStyles.titleLg),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM dd, yyyy  hh:mm a').format(order.timestamp),
                style: AppTextStyles.caption,
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
                    if (bir?.isTraining ?? false) ...[
                      const StatusBanner(
                        text: 'TRAINING / NOT AN OFFICIAL BIR INVOICE',
                        tone: BannerTone.warning,
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                    Row(
                      children: [
                        Image.asset('assets/images/xantara-logo.png',
                            height: 20,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                        const SizedBox(width: AppSizes.sm),
                        Text('Xantara POS',
                            style: AppTextStyles.bodyMd
                                .copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      bir == null
                          ? 'TXN: $txnId'
                          : 'INVOICE: ${bir.invoiceNumber}',
                      style: AppTextStyles.monoSm.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray400),
                    ),
                    if (bir != null) ...[
                      const SizedBox(height: 4),
                      Text(bir.sellerName,
                          style: AppTextStyles.titleSm.copyWith(fontSize: 10)),
                      Text('TIN: ${bir.sellerTin}',
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 9, color: AppColors.gray600)),
                      Text(bir.sellerAddress,
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 9, color: AppColors.gray600)),
                    ],
                    const SizedBox(height: AppSizes.md),
                    _DashedDivider(),
                    const SizedBox(height: AppSizes.md),

                    // Items
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity}×',
                                  style: AppTextStyles.bodySm
                                      .copyWith(color: AppColors.gray400)),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(item.name,
                                    style: AppTextStyles.bodySm),
                              ),
                              Text(
                                '₱${item.subtotal.toStringAsFixed(2)}',
                                style: AppTextStyles.bodySm
                                    .copyWith(fontWeight: FontWeight.w500),
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
                        Text('TOTAL',
                            style: AppTextStyles.bodyMd
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text('₱${order.total.toStringAsFixed(2)}',
                            style: AppTextStyles.titleMd.copyWith(
                                fontSize: 16, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    if (bir != null) ...[
                      _ReceiptRow(
                        label: 'VATable Sales',
                        value: _money(bir.vatableSalesCentavos),
                      ),
                      _ReceiptRow(
                        label: 'VAT (12%)',
                        value: _money(bir.vatAmountCentavos),
                      ),
                      if (bir.zeroRatedSalesCentavos > 0)
                        _ReceiptRow(
                          label: 'Zero-rated Sales',
                          value: _money(bir.zeroRatedSalesCentavos),
                        ),
                      if (bir.vatExemptSalesCentavos > 0)
                        _ReceiptRow(
                          label: 'VAT-exempt Sales',
                          value: _money(bir.vatExemptSalesCentavos),
                        ),
                    ],

                    // Payment details
                    _ReceiptRow(
                      label: 'Payment',
                      value: order.paymentMethod.label,
                    ),
                    _ReceiptRow(
                      label: 'Reference',
                      value: order.paymentReference,
                    ),
                    if (order.paymentMethod == PaymentMethod.cash) ...[
                      _ReceiptRow(
                        label: 'Cash Received',
                        value:
                            '₱${order.cashReceived?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      _ReceiptRow(
                        label: 'Change',
                        value: '₱${order.change?.toStringAsFixed(2) ?? '0.00'}',
                        valueColor: AppColors.success,
                      ),
                    ],
                    if (bir != null) ...[
                      const SizedBox(height: AppSizes.sm),
                      Text('MIN: ${bir.machineIdentificationNumber}',
                          style: AppTextStyles.caption.copyWith(fontSize: 8)),
                      Text('PTU: ${bir.permitToUseNumber}',
                          style: AppTextStyles.caption.copyWith(fontSize: 8)),
                      Text('Serial: ${bir.machineSerialNumber}',
                          style: AppTextStyles.caption.copyWith(fontSize: 8)),
                    ],

                    const SizedBox(height: AppSizes.md),
                    Center(
                      child: Text(
                        'Thank you for your purchase!',
                        style: AppTextStyles.caption
                            .copyWith(fontStyle: FontStyle.italic),
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
                        borderRadius: BorderRadius.circular(AppSizes.rButton)),
                  ),
                  child: Text('New Sale',
                      style: AppTextStyles.titleMd.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _money(int centavos) => 'PHP ${(centavos / 100).toStringAsFixed(2)}';

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
                style: AppTextStyles.bodySm.copyWith(color: AppColors.gray600)),
            Text(value,
                style: AppTextStyles.bodySm.copyWith(
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
