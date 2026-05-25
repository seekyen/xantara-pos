import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pos/providers/pos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/bottom_tab_bar.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      bottomNavigationBar: const BottomTabBar(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.gray800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenH),
        children: const [
          _StockSection(),
          SizedBox(height: AppSizes.md),
          _ItemsSection(),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: AppSizes.sm),
          child: Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: AppSizes.xs),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCard),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Stock Management ──────────────────────────────────────────────────────────

class _StockSection extends ConsumerWidget {
  const _StockSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return _SectionCard(
      title: 'Stock Management',
      icon: Icons.inventory_2_outlined,
      children: products.asMap().entries.map((e) {
        return Column(
          children: [
            _StockTile(product: e.value),
            if (e.key < products.length - 1)
              const Divider(
                  height: 1,
                  color: AppColors.gray100,
                  indent: AppSizes.lg),
          ],
        );
      }).toList(),
    );
  }
}

class _StockTile extends ConsumerWidget {
  const _StockTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productsProvider.notifier);
    final isLow = product.stock <= 5;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: product.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.rInput),
        ),
        child: Icon(_categoryIcon(product.categoryId),
            size: 18, color: product.color),
      ),
      title: Text(product.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.gray800)),
      subtitle: isLow
          ? const Text('Low stock!',
              style:
                  TextStyle(color: AppColors.error, fontSize: 12))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: product.stock > 0
                ? () => notifier.updateStock(
                    product.id, product.stock - 1)
                : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: product.stock > 0
                    ? AppColors.gray100
                    : AppColors.gray50,
                borderRadius:
                    BorderRadius.circular(AppSizes.rBadgeSm),
              ),
              child: Icon(Icons.remove,
                  size: 16,
                  color: product.stock > 0
                      ? AppColors.gray800
                      : AppColors.gray200),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${product.stock}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color:
                    isLow ? AppColors.error : AppColors.gray800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                notifier.updateStock(product.id, product.stock + 1),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(AppSizes.rBadgeSm),
              ),
              child: const Icon(Icons.add,
                  size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String id) {
    switch (id) {
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

// ── Item Controls ─────────────────────────────────────────────────────────────

class _ItemsSection extends ConsumerWidget {
  const _ItemsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return _SectionCard(
      title: 'Item Controls',
      icon: Icons.tune_rounded,
      trailing: GestureDetector(
        onTap: () => _showItemDialog(context, ref, null),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSizes.rPill),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
        ),
      ),
      children: products.asMap().entries.map((e) {
        return Column(
          children: [
            _ItemControlTile(
              product: e.value,
              onEdit: () => _showItemDialog(context, ref, e.value),
            ),
            if (e.key < products.length - 1)
              const Divider(
                  height: 1,
                  color: AppColors.gray100,
                  indent: AppSizes.lg),
          ],
        );
      }).toList(),
    );
  }

  void _showItemDialog(
      BuildContext context, WidgetRef ref, Product? existing) {
    showDialog(
      context: context,
      builder: (_) => _ItemDialog(existing: existing, ref: ref),
    );
  }
}

class _ItemControlTile extends ConsumerWidget {
  const _ItemControlTile(
      {required this.product, required this.onEdit});
  final Product product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productsProvider.notifier);

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: product.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.rInput),
        ),
        child: Icon(_categoryIcon(product.categoryId),
            size: 18, color: product.color),
      ),
      title: Text(product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.gray800,
            decoration: product.isAvailable
                ? null
                : TextDecoration.lineThrough,
          )),
      subtitle: Text('₱${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 11, color: AppColors.gray400)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: product.isAvailable,
            onChanged: (_) =>
                notifier.toggleAvailability(product.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: AppColors.gray600),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppSizes.rCardLg)),
        content: Text('Remove "${product.name}" from the menu?',
            style: const TextStyle(
                fontSize: 13, color: AppColors.gray600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(productsProvider.notifier)
                  .deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.rButton)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String id) {
    switch (id) {
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

// ── Item dialog ───────────────────────────────────────────────────────────────

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({required this.existing, required this.ref});
  final Product? existing;
  final WidgetRef ref;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late String _categoryId;
  late Color _color;

  final _formKey = GlobalKey<FormState>();

  static const _colorOptions = [
    Color(0xFF6F4E37), Color(0xFF4A90D9), Color(0xFF5D8A5E),
    Color(0xFFE8821A), Color(0xFF78C1D4), Color(0xFFCC3A3A),
    Color(0xFF6A5ACD), Color(0xFFD4A056), Color(0xFFE8A0C0),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(2) : '');
    _stockCtrl =
        TextEditingController(text: p != null ? '${p.stock}' : '0');
    _categoryId = p?.categoryId ?? 'beverages';
    _color = p?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = widget.ref.read(productsProvider.notifier);

    if (widget.existing != null) {
      notifier.updateProduct(widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        categoryId: _categoryId,
        color: _color,
        stock: int.tryParse(_stockCtrl.text) ?? 0,
      ));
    } else {
      notifier.addProduct(buildNewProduct(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        categoryId: _categoryId,
        color: _color,
        stock: int.tryParse(_stockCtrl.text) ?? 0,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existing != null ? 'Edit Item' : 'Add Item',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Price (₱)',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          double.tryParse(v ?? '') == null
                              ? 'Invalid'
                              : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          int.tryParse(v ?? '') == null
                              ? 'Invalid'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder()),
                items: staticCategories
                    .where((c) => c.id != 'all')
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v!),
              ),
              const SizedBox(height: AppSizes.md),
              const Text('Color',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                children: _colorOptions.map((c) {
                  final selected = c == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: Colors.white, width: 2)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color:
                                        c.withValues(alpha: 0.6),
                                    blurRadius: 6)
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSizes.rButton)),
          ),
          child:
              Text(widget.existing != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
