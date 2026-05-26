import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/providers/checkout_provider.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../customer_display/customer_display_bridge.dart';
import '../../customer_display/providers/customer_display_providers.dart';
import '../providers/cart_provider.dart';
import '../widgets/category_bar.dart';
import '../widgets/product_grid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../utils/platform_utils.dart';
import 'pos_screen_tablet.dart';
import 'pos_screen_desktop.dart';

const _kVat = 0.12;

// Converts the current cart into OrderItems, updates local CustomerDisplayState,
// and sends the payload to the customer display window via method channel.
void _syncCartToDisplay(
    WidgetRef ref, List<CartItem> cartItems, int windowId) {
  final subtotal = cartItems.fold(0.0, (s, i) => s + i.subtotal);
  final tax = subtotal * _kVat;
  final total = subtotal + tax;

  final orderItems = cartItems
      .map((i) => OrderItem(
            name: i.product.name,
            price: i.product.price,
            quantity: i.quantity,
            subtotal: i.subtotal,
          ))
      .toList();

  final state = ref.read(customerDisplayStateProvider);
  state.updateOrder(
    orderItems,
    subtotal: subtotal,
    tax: tax,
    discount: 0,
    total: total,
  );

  CustomerDisplayBridge.sendUpdateOrder(windowId, state).ignore();
}

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = getLayout(context);

    // Sync every cart change to the customer display window in real time.
    // Fires whenever items are added, removed, or qty changes.
    ref.listen<List<CartItem>>(cartProvider, (_, cartItems) {
      final windowId = ref.read(customerDisplayWindowIdProvider);
      if (windowId == null) return;
      _syncCartToDisplay(ref, cartItems, windowId);
    });

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: _buildAppBar(context, ref, layout),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: switch (layout) {
              // DESKTOP — 3-column persistent layout, checkout as dialog
              AppLayout.desktop => PosDesktopLayout(
                  onCheckout: () => _showCheckoutDialog(context)),
              // TABLET — 2-panel layout, checkout as bottom sheet
              AppLayout.tablet => PosTabletLayout(
                  onCheckout: () => _showCheckout(context)),
              // existing mobile layout, untouched
              AppLayout.mobile => _PhoneLayout(
                  onCheckout: () => _showCheckout(context)),
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, AppLayout layout) {
    final user = ref.watch(authProvider).user;
    final itemCount = ref.watch(cartItemCountProvider);
    final isMobile = layout == AppLayout.mobile;

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
        // Open Customer Display button — tablet + desktop only
        if (!isMobile && (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
          _OpenCustomerDisplayButton(),
        // cart icon only on mobile — tablet/desktop show cart in the panel
        if (isMobile)
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
      // DESKTOP — CategoryBar is in the sidebar; hide it from the AppBar
      bottom: layout != AppLayout.desktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(52),
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: CategoryBar(),
              ),
            )
          : null,
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

  // DESKTOP — checkout as a dialog instead of a bottom sheet
  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg),
          child: const CheckoutScreen(),
        ),
      ),
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

// DESKTOP/TABLET — opens the customer-facing display window on a second monitor.
class _OpenCustomerDisplayButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowId = ref.watch(customerDisplayWindowIdProvider);
    final isOpen = windowId != null;

    return Tooltip(
      message: isOpen ? 'Customer Display open' : 'Open Customer Display',
      child: IconButton(
        icon: Icon(
          isOpen ? Icons.monitor_rounded : Icons.monitor_outlined,
          color: isOpen ? AppColors.primary : AppColors.gray800,
        ),
        onPressed: isOpen ? null : () => _openCustomerDisplay(context, ref),
      ),
    );
  }

  Future<void> _openCustomerDisplay(BuildContext context, WidgetRef ref) async {
    try {
      final controller = await DesktopMultiWindow.createWindow(
        jsonEncode({'type': 'customer_display'}),
      );
      await controller.setFrame(const Rect.fromLTWH(0, 0, 1280, 800));
      await controller.center();
      await controller.setTitle('Xantara POS — Customer Display');
      await controller.show();

      ref.read(customerDisplayWindowIdProvider.notifier).state =
          controller.windowId;

      // Initial sync — give the customer display window time to set up its
      // method channel handler before sending the first message.
      Future.delayed(const Duration(milliseconds: 600), () {
        final cartItems = ref.read(cartProvider);
        if (cartItems.isNotEmpty) {
          _syncCartToDisplay(ref, cartItems, controller.windowId);
        }
      });

      // Listen for messages sent back from the customer display window.
      CustomerDisplayBridge.listenFromCustomerDisplay(
        onMessage: (method, args) {
          final state = ref.read(customerDisplayStateProvider);
          switch (method) {
            case 'cd_setTip':
              final data = jsonDecode(args as String) as Map<String, dynamic>;
              state.setTip((data['amount'] as num).toDouble());
            case 'cd_selectPaymentMethod':
              final data = jsonDecode(args as String) as Map<String, dynamic>;
              final methodName = data['method'] as String;
              final matches =
                  PaymentMethod.values.where((e) => e.name == methodName);
              if (matches.isNotEmpty) state.selectPaymentMethod(matches.first);
            case 'cd_setTenderedAmount':
              final data = jsonDecode(args as String) as Map<String, dynamic>;
              state.setTenderedAmount((data['amount'] as num).toDouble());
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open customer display: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
