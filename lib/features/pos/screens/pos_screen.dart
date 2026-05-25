import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../providers/cart_provider.dart';
import '../widgets/category_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/offline_banner.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: isTablet
                ? _TabletLayout(onCheckout: () => _showCheckout(context))
                : _PhoneLayout(onCheckout: () => _showCheckout(context)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final itemCount = ref.watch(cartItemCountProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Image.asset('assets/images/xantara-logo.png', height: 30),
      actions: [
        if (user != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.gray800,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (!isTablet)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.gray800),
                onPressed: () => _showCheckout(context),
              ),
              if (itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSizes.sm),
          child: CategoryBar(),
        ),
      ),
    );
  }

  void _showCheckout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CheckoutScreen(),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.onCheckout});
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 6, child: ProductGrid()),
        SizedBox(
          width: 320,
          child: CartPanel(onCheckout: onCheckout),
        ),
      ],
    );
  }
}

class _PhoneLayout extends ConsumerWidget {
  const _PhoneLayout({required this.onCheckout});
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);

    return Stack(
      children: [
        const ProductGrid(),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          bottom: itemCount > 0 ? 16 : -100,
          left: AppSizes.screenH,
          right: AppSizes.screenH,
          child: _FloatingCheckoutBar(
            itemCount: itemCount,
            total: total,
            onTap: onCheckout,
          ),
        ),
      ],
    );
  }
}

class _FloatingCheckoutBar extends StatelessWidget {
  const _FloatingCheckoutBar({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.rCardLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.rPill),
              ),
              child: Text(
                '$itemCount item${itemCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            const Expanded(
              child: Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
