import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;

  const Category({required this.id, required this.name, required this.icon});
}

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

final _initialProducts = [
  const Product(id: 'b1', name: 'Hot Coffee', price: 85, categoryId: 'beverages', color: Color(0xFF6F4E37), stock: 50),
  const Product(id: 'b2', name: 'Iced Coffee', price: 95, categoryId: 'beverages', color: Color(0xFF4A90D9), stock: 40),
  const Product(id: 'b3', name: 'Green Tea', price: 75, categoryId: 'beverages', color: Color(0xFF5D8A5E), stock: 30),
  const Product(id: 'b4', name: 'Orange Juice', price: 80, categoryId: 'beverages', color: Color(0xFFE8821A), stock: 25),
  const Product(id: 'b5', name: 'Mineral Water', price: 25, categoryId: 'beverages', color: Color(0xFF78C1D4), stock: 100),
  const Product(id: 'b6', name: 'Lemonade', price: 70, categoryId: 'beverages', color: Color(0xFFD4C026), stock: 20),
  const Product(id: 'f1', name: 'Chicken Sandwich', price: 120, categoryId: 'food', color: Color(0xFFD4A056), stock: 15),
  const Product(id: 'f2', name: 'Cheeseburger', price: 150, categoryId: 'food', color: Color(0xFFBE4B26), stock: 10),
  const Product(id: 'f3', name: 'Pepperoni Pizza', price: 180, categoryId: 'food', color: Color(0xFFCC3A3A), stock: 8),
  const Product(id: 'f4', name: 'Caesar Salad', price: 110, categoryId: 'food', color: Color(0xFF6FAE6F), stock: 12),
  const Product(id: 'f5', name: 'Pasta Carbonara', price: 160, categoryId: 'food', color: Color(0xFFD4BE8A), stock: 9),
  const Product(id: 'f6', name: 'Fish & Chips', price: 145, categoryId: 'food', color: Color(0xFFD4A826), stock: 11),
  const Product(id: 's1', name: 'Potato Chips', price: 45, categoryId: 'snacks', color: Color(0xFFD4B44A), stock: 60),
  const Product(id: 's2', name: 'Choco Cookie', price: 55, categoryId: 'snacks', color: Color(0xFF7B5C3E), stock: 45),
  const Product(id: 's3', name: 'Blueberry Muffin', price: 65, categoryId: 'snacks', color: Color(0xFF6A5ACD), stock: 20),
  const Product(id: 's4', name: 'Pretzel', price: 50, categoryId: 'snacks', color: Color(0xFFC4924A), stock: 30),
  const Product(id: 'd1', name: 'Ice Cream', price: 75, categoryId: 'desserts', color: Color(0xFFE8A0C0), stock: 35),
  const Product(id: 'd2', name: 'Chocolate Cake', price: 95, categoryId: 'desserts', color: Color(0xFF5C3D2E), stock: 15),
  const Product(id: 'd3', name: 'Brownie', price: 85, categoryId: 'desserts', color: Color(0xFF4A2F1A), stock: 22),
  const Product(id: 'd4', name: 'Cheesecake', price: 110, categoryId: 'desserts', color: Color(0xFFE8D5A0), stock: 10),
];

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super(_initialProducts);

  void toggleAvailability(String id) {
    state = state.map((p) {
      return p.id == id ? p.copyWith(isAvailable: !p.isAvailable) : p;
    }).toList();
  }

  void updateStock(String id, int stock) {
    state = state.map((p) {
      return p.id == id ? p.copyWith(stock: stock.clamp(0, 9999)) : p;
    }).toList();
  }

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void decrementStock(String id, int qty) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(stock: (p.stock - qty).clamp(0, 9999));
      }
      return p;
    }).toList();
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) => ProductsNotifier(),
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
