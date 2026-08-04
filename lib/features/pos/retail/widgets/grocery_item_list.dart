import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/grocery_cart_provider.dart';

class GroceryItemList extends ConsumerWidget {
  const GroceryItemList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(groceryCartProvider);
    final subtotal = ref.watch(groceryCartSubtotalProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        border: Border.all(color: AppColors.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Text('List of Grocery', style: AppTextStyles.titleLg),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Row(
              children: [
                SizedBox(width: 36, child: Text('Qty', style: AppTextStyles.labelCaps)),
                Expanded(child: Text('Description', style: AppTextStyles.labelCaps)),
                SizedBox(
                    width: 90,
                    child: Text('Per pc',
                        textAlign: TextAlign.right, style: AppTextStyles.labelCaps)),
                SizedBox(
                    width: 100,
                    child: Text('Total',
                        textAlign: TextAlign.right, style: AppTextStyles.labelCaps)),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Scan an item to begin', style: AppTextStyles.bodyMd),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => ref
                            .read(groceryCartProvider.notifier)
                            .removeItem(item.product.id),
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md, vertical: AppSizes.sm),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 36,
                                  child: Text('${item.quantity}',
                                      style: AppTextStyles.bodyMd)),
                              Expanded(
                                  child: Text(item.product.name,
                                      style: AppTextStyles.bodyMd
                                          .copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis)),
                              SizedBox(
                                  width: 90,
                                  child: Text(
                                      '₱${item.product.price.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: AppTextStyles.bodyMd
                                          .copyWith(color: AppColors.gray600))),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      '₱${item.lineTotal.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: AppTextStyles.bodyMd
                                          .copyWith(fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1, color: AppColors.gray200),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray400)),
                Text('₱${subtotal.toStringAsFixed(2)}', style: AppTextStyles.titleMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
