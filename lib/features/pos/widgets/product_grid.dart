import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pos_provider.dart';
import '../providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/stock_badge.dart';

class ProductGrid extends ConsumerStatefulWidget {
  const ProductGrid({super.key});

  @override
  ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
  final _scrollController = ScrollController();
  String _search = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut);
    }
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(filteredProductsProvider);
    final cartItems = ref.watch(cartProvider);

    final products = _search.isEmpty
        ? all
        : all
            .where((p) =>
                p.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.screenH, AppSizes.sm, AppSizes.screenH, AppSizes.xs),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search or scan barcode…',
              hintStyle: const TextStyle(
                  color: AppColors.gray400, fontSize: 13),
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: AppColors.gray400),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: AppColors.gray400),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg, vertical: AppSizes.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.rInput),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.rInput),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.rInput),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // ── Grid ─────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefresh,
            child: products.isEmpty
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
                          child: const Icon(Icons.search_off_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text('No products found',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800)),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.screenH),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      crossAxisSpacing: AppSizes.sm,
                      mainAxisSpacing: AppSizes.sm,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final cartItem = cartItems
                          .where((i) => i.product.id == product.id);
                      final qty = cartItem.isNotEmpty
                          ? cartItem.first.quantity
                          : 0;
                      return _ProductCard(product: product, qty: qty);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.qty});

  final Product product;
  final int qty;

  int get _remaining => product.stock - qty;
  bool get _isOutOfStock => _remaining <= 0;
  bool get _isLowStock => _remaining > 0 && _remaining < 10;

  void _onTap(BuildContext context, WidgetRef ref) {
    if (_isOutOfStock) return;
    if (_isLowStock) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: AppSizes.sm),
              Text('Low stock: only $_remaining left',
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.rCard)),
        ),
      );
    }
    ref.read(cartProvider.notifier).addItem(product);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = qty > 0;
    final idSlice = product.id.length >= 8
        ? product.id.substring(0, 8)
        : product.id;
    final skuCode = 'XAN-${idSlice.toUpperCase()}';

    return Opacity(
      opacity: _isOutOfStock ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: _isOutOfStock ? null : () => _onTap(context, ref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCard),
            border: Border.all(
              color: inCart && !_isOutOfStock
                  ? AppColors.primary
                  : AppColors.gray100,
              width: inCart && !_isOutOfStock ? 1.5 : 1,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: product.color.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.rCard)),
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: product.color.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.rInput),
                          ),
                          child: Icon(
                            _categoryIcon(product.categoryId),
                            size: 22,
                            color: product.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.cardPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: _isOutOfStock
                                ? AppColors.gray400
                                : AppColors.gray800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          skuCode,
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isOutOfStock
                                    ? AppColors.gray400
                                    : AppColors.primary,
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _isOutOfStock
                                    ? AppColors.gray200
                                    : AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.rInput),
                              ),
                              child: Icon(
                                _isOutOfStock
                                    ? Icons.block_rounded
                                    : Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Stock badge top-right
              Positioned(
                top: AppSizes.sm,
                right: AppSizes.sm,
                child: StockBadge(stock: _remaining),
              ),

              // Cart qty badge top-left
              if (inCart && !_isOutOfStock)
                Positioned(
                  top: AppSizes.sm,
                  left: AppSizes.sm,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
