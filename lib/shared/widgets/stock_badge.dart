import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum StockLevel { inStock, low, outOfStock }

StockLevel stockLevelFor(int stock) {
  if (stock <= 0) return StockLevel.outOfStock;
  if (stock <= 10) return StockLevel.low;
  return StockLevel.inStock;
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final level = stockLevelFor(stock);

    final bg = switch (level) {
      StockLevel.inStock    => AppColors.successLight,
      StockLevel.low        => AppColors.warningLight,
      StockLevel.outOfStock => AppColors.errorLight,
    };
    final fg = switch (level) {
      StockLevel.inStock    => AppColors.success,
      StockLevel.low        => AppColors.warning,
      StockLevel.outOfStock => AppColors.error,
    };
    final label = switch (level) {
      StockLevel.inStock    => '$stock',
      StockLevel.low        => 'LOW $stock',
      StockLevel.outOfStock => 'OUT',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.rBadgeSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
