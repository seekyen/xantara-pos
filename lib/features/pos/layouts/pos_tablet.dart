import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../../../core/constants/app_colors.dart';

// TABLET — two-panel layout: product browser (left) + cart/order summary (right)
class PosTabletLayout extends StatelessWidget {
  const PosTabletLayout({super.key, required this.onCheckout});
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    // TABLET — Row with left product grid and right cart panel
    return Row(
      children: [
        // TABLET — scrollable product/category browser (left, ~60% width)
        const Expanded(
          flex: 6,
          child: ProductGrid(),
        ),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: AppColors.gray200,
        ),
        // TABLET — order summary / cart panel (right, fixed 320px)
        SizedBox(
          width: 320,
          child: CartPanel(onCheckout: onCheckout),
        ),
      ],
    );
  }
}
