import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../../../features/orders/providers/orders_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

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
                const Expanded(
                  child: Text(
                    'Current Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
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
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
                        const Text('No items yet',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800)),
                        const SizedBox(height: 4),
                        const Text('Tap a product to add',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.gray400)),
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
  showDialog(
    context: context,
    builder: (_) => _VoidPermissionDialog(
      title: title,
      message: message,
      onConfirmed: onConfirmed,
    ),
  );
}

class _VoidPermissionDialog extends StatefulWidget {
  const _VoidPermissionDialog({
    required this.title,
    required this.message,
    required this.onConfirmed,
  });
  final String title;
  final String message;
  final VoidCallback onConfirmed;

  @override
  State<_VoidPermissionDialog> createState() =>
      _VoidPermissionDialogState();
}

class _VoidPermissionDialogState extends State<_VoidPermissionDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_controller.text != voidPermissionCode) {
      setState(() => _error = 'Incorrect code. Try again.');
      return;
    }
    Navigator.pop(context);
    widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSizes.sm),
          Text(widget.title),
        ],
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.gray600)),
          const SizedBox(height: AppSizes.lg),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Supervisor Code',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSizes.rButton)),
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.gray800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₱${item.product.price.toStringAsFixed(0)} each',
                  style: const TextStyle(
                      color: AppColors.gray400, fontSize: 11),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.gray800),
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
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primary,
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
        ),
        child: Icon(icon, size: 14, color: AppColors.gray800),
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
              const Text('Subtotal',
                  style: TextStyle(
                      color: AppColors.gray400, fontSize: 13)),
              Text('₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray600)),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.gray800)),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.primary),
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
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
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
