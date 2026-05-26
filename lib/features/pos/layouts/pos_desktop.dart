import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

// DESKTOP — persistent 3-column layout with keyboard shortcuts
class PosDesktopLayout extends ConsumerWidget {
  const PosDesktopLayout({super.key, required this.onCheckout});
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // DESKTOP — keyboard: Enter = confirm order, Escape handled by dialogs
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          final cartItems = ref.read(cartProvider);
          if (cartItems.isNotEmpty) onCheckout();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Row(
        children: [
          // DESKTOP — category sidebar (left, fixed 200px)
          const _CategorySidebar(),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.gray200,
          ),
          // DESKTOP — product grid with 3-4 columns (center, flexible)
          const Expanded(
            flex: 5,
            child: ProductGrid(),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.gray200,
          ),
          // DESKTOP — cart + order summary + checkout action (right, fixed 360px)
          SizedBox(
            width: 360,
            child: CartPanel(onCheckout: onCheckout),
          ),
        ],
      ),
    );
  }
}

// DESKTOP — vertical category list sidebar
class _CategorySidebar extends ConsumerWidget {
  const _CategorySidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DESKTOP — sidebar header
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
            child: Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gray400,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: 0),
              children: staticCategories.map((cat) {
                final isSelected = cat.id == selected;
                // DESKTOP — hover state on category items via MouseRegion
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = cat.id,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSizes.rCard),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray600,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.gray600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
