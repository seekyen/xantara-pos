import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/checkout/providers/checkout_provider.dart';
import '../providers/customer_display_providers.dart';

// CUSTOMER_DISPLAY — live order view, synced in real time with the cashier cart.
class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDisplayStateProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _OrderHeader(itemCount: state.orderItems.length),

          // ── Item list ───────────────────────────────────────────────────────
          Expanded(
            child: state.orderItems.isEmpty
                ? const _EmptyOrder()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xl, vertical: AppSizes.lg),
                    itemCount: state.orderItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.gray100),
                    itemBuilder: (_, index) =>
                        _OrderItemRow(item: state.orderItems[index]),
                  ),
          ),

          // ── Price summary ────────────────────────────────────────────────
          _PriceSummary(
            subtotal: state.subtotal,
            tax: state.tax,
            discount: state.discount,
            total: state.total,
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    // CUSTOMER_DISPLAY — matches CartPanel header gradient
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl, vertical: AppSizes.lg + 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            Image.asset(
              'assets/images/xantara-logo.png',
              height: 28,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                'Your Order',
                style: AppTextStyles.displayMd.copyWith(color: Colors.white),
              ),
            ),
            if (itemCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.rPill),
                ),
                child: Text(
                  '$itemCount item${itemCount != 1 ? 's' : ''}',
                  style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Order item row ─────────────────────────────────────────────────────────────

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    // CUSTOMER_DISPLAY — enlarged row for easy customer readability (18-20px text)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        children: [
          // Item avatar — first letter of product name
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.rCard),
            ),
            child: Center(
              child: Text(
                item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                style: AppTextStyles.statNumber
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Name + unit price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.titleLg.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} × ₱${item.price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLg
                      .copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),

          // Line subtotal
          Text(
            '₱${item.subtotal.toStringAsFixed(2)}',
            style: AppTextStyles.statNumber.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyOrder extends StatelessWidget {
  const _EmptyOrder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.rCardLg + 4),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'No items yet',
            style: AppTextStyles.statNumber.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Items will appear here as your cashier adds them.',
            style: AppTextStyles.bodyLg
                .copyWith(fontSize: 16, color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Price summary ──────────────────────────────────────────────────────────────

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
    // CUSTOMER_DISPLAY — large, easy-to-read price breakdown
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Subtotal',
              value: '₱${subtotal.toStringAsFixed(2)}',
              fontSize: 17),
          const SizedBox(height: AppSizes.sm),
          _SummaryRow(
              label: 'VAT (12%)',
              value: '₱${tax.toStringAsFixed(2)}',
              fontSize: 17),
          if (discount > 0) ...[
            const SizedBox(height: AppSizes.sm),
            _SummaryRow(
              label: 'Discount',
              value: '−₱${discount.toStringAsFixed(2)}',
              fontSize: 17,
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: AppSizes.md),
          const Divider(color: AppColors.gray200),
          const SizedBox(height: AppSizes.md),
          // Total — animated so it visually updates when items are added
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.displayMd
                    .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.3), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  '₱${total.toStringAsFixed(2)}',
                  key: ValueKey(total),
                  style: AppTextStyles.heroNumber.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Prompt
          Text(
            'Please review your order. Your cashier will proceed when ready.',
            style: AppTextStyles.bodyMd
                .copyWith(fontSize: 14, color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.fontSize,
    this.valueColor = AppColors.gray600,
  });

  final String label;
  final String value;
  final double fontSize;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMd
                .copyWith(fontSize: fontSize, color: AppColors.gray400)),
        Text(value,
            style: AppTextStyles.bodyMd.copyWith(
                fontSize: fontSize,
                color: valueColor,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
