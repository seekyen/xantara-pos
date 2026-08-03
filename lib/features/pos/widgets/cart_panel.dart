import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';
import '../../../core/auth/pos_authorization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../local/database_seed.dart';
import '../../../shared/widgets/supervisor_authorization_dialog.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key, this.onCheckout});
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg, vertical: AppSizes.md),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Current Order',
                    style: AppTextStyles.titleMd.copyWith(color: Colors.white),
                  ),
                ),
                if (cartItems.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showVoidDialog(
                      context: context,
                      ref: ref,
                      title: 'Clear Cart',
                      message:
                          'Clearing the cart requires supervisor permission.',
                      onConfirmed: () =>
                          ref.read(cartProvider.notifier).clear(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSizes.rPill),
                      ),
                      child: Text(
                        'Clear',
                        style: AppTextStyles.labelMd.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Items
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppSizes.rCard),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text('No items yet',
                            style: AppTextStyles.bodyMd
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Tap a product to add',
                            style: AppTextStyles.bodySm
                                .copyWith(fontSize: 11, color: AppColors.gray400)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: AppColors.gray100),
                    itemBuilder: (context, index) =>
                        _CartItemTile(item: cartItems[index]),
                  ),
          ),

          // Footer
          if (cartItems.isNotEmpty)
            _CartFooter(total: total, onCheckout: onCheckout),
        ],
      ),
    );
  }
}

// ── Shared void dialog ────────────────────────────────────────────────────────

void _showVoidDialog({
  required BuildContext context,
  required WidgetRef ref,
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

// ── Cart item tile ────────────────────────────────────────────────────────────

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.product.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.rInput),
            ),
            child: Icon(
              _categoryIcon(item.product.categoryId),
              size: 18,
              color: item.product.color,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₱${item.product.price.toStringAsFixed(0)} each',
                  style: AppTextStyles.bodySm
                      .copyWith(fontSize: 11, color: AppColors.gray400),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: () {
                  if (item.quantity == 1) {
                    _showVoidDialog(
                      context: context,
                      ref: ref,
                      title: 'Remove Item',
                      message:
                          'Removing "${item.product.name}" requires supervisor permission.',
                      onConfirmed: () =>
                          notifier.decrement(item.product.id),
                    );
                  } else {
                    notifier.decrement(item.product.id);
                  }
                },
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSm.copyWith(fontSize: 14),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => notifier.increment(item.product.id),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.sm),
          SizedBox(
            width: 52,
            child: Text(
              '₱${item.subtotal.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMd
                  .copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

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
}

// ── Qty button ────────────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Tappable area meets AppSizes.minTouch (44px) for comfortable all-day
    // cashier use on a touchscreen; the visible glyph stays small.
    return Material(
      color: AppColors.gray100,
      borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
        child: SizedBox(
          width: AppSizes.minTouch,
          height: AppSizes.minTouch,
          child: Icon(icon, size: 16, color: AppColors.gray800),
        ),
      ),
    );
  }
}

// ── Cart footer ───────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.total, this.onCheckout});
  final double total;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray400)),
              Text('₱${total.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600)),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: AppTextStyles.titleMd),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: AppTextStyles.titleLg
                    .copyWith(fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (onCheckout != null)
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(
                  'Charge  ₱${total.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMd.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.rButton)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
