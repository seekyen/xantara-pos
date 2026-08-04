import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../local/database_providers.dart';
import '../../../../local/database_seed.dart';
import '../../../../local/local_pos_store.dart';
import '../../../../local/repositories/catalog_repository.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;

  const Category({required this.id, required this.name, required this.icon});
}

class RetailBranch {
  const RetailBranch({required this.code, required this.name});
  final String code;
  final String name;
}

const retailBranches = [
  RetailBranch(code: 'MAIN', name: 'Main Branch'),
  RetailBranch(code: 'BR002', name: 'Branch 2'),
  RetailBranch(code: 'BR003', name: 'Branch 3'),
];

RetailBranch retailBranchFor(String code) =>
    retailBranches.firstWhere((branch) => branch.code == code);

class Product {
  final String id;
  final String name;
  final double price;
  final String categoryId;
  final Color color;
  final int stock;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.color,
    this.stock = 99,
    this.isAvailable = true,
  });

  Product copyWith({
    String? name,
    double? price,
    String? categoryId,
    Color? color,
    int? stock,
    bool? isAvailable,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      color: color ?? this.color,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

const staticCategories = [
  Category(id: 'all', name: 'All', icon: Icons.grid_view_rounded),
  Category(id: 'beverages', name: 'Beverages', icon: Icons.local_cafe_rounded),
  Category(id: 'food', name: 'Food', icon: Icons.fastfood_rounded),
  Category(id: 'snacks', name: 'Snacks', icon: Icons.cookie_rounded),
  Category(id: 'desserts', name: 'Desserts', icon: Icons.cake_rounded),
];

/// Branch-scoped product catalog and stock, backed by [CatalogRepository]
/// (Drift). Reactively re-subscribes whenever the active branch changes.
class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier(this._repository, {required this.branchId}) : super(const []) {
    _subscription = _repository.watchBranchProducts(branchId).listen((rows) {
      state = rows.map(_toProduct).toList(growable: false);
    });
  }

  final CatalogRepository _repository;
  final String branchId;
  late final StreamSubscription<List<CatalogProduct>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void toggleAvailability(String id) {
    final current = state.where((p) => p.id == id).firstOrNull;
    if (current == null) return;
    _repository.setAvailability(id, !current.isAvailable);
  }

  void updateStock(String id, int stock) {
    _repository.adjustStock(
      branchId: branchId,
      productId: id,
      stock: stock.clamp(0, 9999),
    );
  }

  void addProduct(Product product) {
    _repository.createProduct(
      branchId: branchId,
      name: product.name,
      unitPriceCentavos: (product.price * 100).round(),
      categoryId: product.categoryId,
      colorArgb: product.color.toARGB32(),
      stock: product.stock,
    );
  }

  void updateProduct(Product updated) {
    _repository.updateProduct(
      productId: updated.id,
      branchId: branchId,
      name: updated.name,
      unitPriceCentavos: (updated.price * 100).round(),
      categoryId: updated.categoryId,
      colorArgb: updated.color.toARGB32(),
      stock: updated.stock,
      isAvailable: updated.isAvailable,
    );
  }

  void deleteProduct(String id) {
    _repository.deleteProduct(branchId: branchId, productId: id);
  }
}

Product _toProduct(CatalogProduct row) => Product(
      id: row.product.id,
      name: row.product.name,
      price: row.product.unitPriceCentavos / 100,
      categoryId: row.product.categoryId,
      color: Color(row.product.colorArgb),
      stock: row.inventory.stockOnHand,
      isAvailable: row.product.isActive,
    );

final localPosStoreProvider = Provider<LocalPosStore>(
  (ref) => MemoryPosStore(),
);

class ActiveBranchNotifier extends StateNotifier<String> {
  ActiveBranchNotifier(this._store) : super('MAIN') {
    restored = _restore();
  }

  static const storageKey = 'xantara.active-branch.v1';
  final LocalPosStore _store;
  late final Future<void> restored;

  Future<void> _restore() async {
    final saved = await _store.read(storageKey);
    if (saved != null && retailBranches.any((branch) => branch.code == saved)) {
      state = saved;
    }
  }

  Future<void> select(String branchCode) async {
    if (!retailBranches.any((branch) => branch.code == branchCode)) {
      throw ArgumentError.value(branchCode, 'branchCode');
    }
    state = branchCode;
    await _store.write(storageKey, branchCode);
  }
}

final activeBranchProvider =
    StateNotifierProvider<ActiveBranchNotifier, String>(
  (ref) => ActiveBranchNotifier(ref.watch(localPosStoreProvider)),
);

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) => ProductsNotifier(
    ref.watch(catalogRepositoryProvider),
    branchId: branchIdForCode(ref.watch(activeBranchProvider)),
  ),
);

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final selected = ref.watch(selectedCategoryProvider);
  final products = ref.watch(productsProvider);
  final available = products.where((p) => p.isAvailable);
  if (selected == 'all') return available.toList();
  return available.where((p) => p.categoryId == selected).toList();
});

const _uuid = Uuid();

Product buildNewProduct({
  required String name,
  required double price,
  required String categoryId,
  required Color color,
  int stock = 0,
}) {
  return Product(
    id: _uuid.v4(),
    name: name,
    price: price,
    categoryId: categoryId,
    color: color,
    stock: stock,
    isAvailable: true,
  );
}
