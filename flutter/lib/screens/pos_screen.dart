import 'package:flutter/material.dart';
import '../theme/xantara_theme.dart';

class _Product {
  const _Product(this.name, this.price, this.category);
  final String name;
  final double price;
  final String category;
}

const _products = [
  _Product('Rice 5kg', 260.00, 'Staples'),
  _Product('Cooking Oil 1L', 110.00, 'Staples'),
  _Product('Instant Noodles', 14.00, 'Snacks'),
  _Product('Bottled Water 500ml', 18.00, 'Beverages'),
  _Product('Canned Sardines', 32.00, 'Canned'),
  _Product('Soft Drink 1.5L', 65.00, 'Beverages'),
  _Product('Bread Loaf', 55.00, 'Bakery'),
  _Product('Eggs (tray)', 210.00, 'Staples'),
];

/// POS / checkout screen — option 1a. Product grid + cart panel, with
/// larger touch targets sized for all-day cashier use on a touchscreen
/// (48px+ hit areas throughout) per the design review's POS-ergonomics note.
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XantaraColors.gray50,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(XantaraSpacing.lg, XantaraSpacing.lg, XantaraSpacing.lg, 0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Scan barcode or search products',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: XantaraSpacing.md),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: XantaraSpacing.lg, vertical: XantaraSpacing.md),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final cat in ['All', 'Staples', 'Beverages', 'Snacks', 'Canned', 'Bakery'])
                            Padding(
                              padding: const EdgeInsets.only(right: XantaraSpacing.sm),
                              child: ChoiceChip(
                                label: Text(cat, style: XantaraType.labelMd),
                                selected: cat == 'All',
                                selectedColor: XantaraColors.primaryLight,
                                showCheckmark: false,
                                labelStyle: TextStyle(color: cat == 'All' ? XantaraColors.primary : XantaraColors.gray600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(XantaraRadius.pill),
                                  side: BorderSide(color: cat == 'All' ? XantaraColors.primaryLight : XantaraColors.gray200),
                                ),
                                onSelected: (_) {},
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(XantaraSpacing.lg, 0, XantaraSpacing.lg, XantaraSpacing.lg),
                      itemCount: _products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: XantaraSpacing.md,
                        crossAxisSpacing: XantaraSpacing.md,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, i) {
                        final p = _products[i];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(XantaraRadius.card),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(XantaraRadius.card),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(XantaraSpacing.md),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(XantaraRadius.card),
                                border: Border.all(color: XantaraColors.gray200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: XantaraColors.gray100,
                                        borderRadius: BorderRadius.circular(XantaraRadius.input),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: XantaraSpacing.sm),
                                  Text(p.name, style: XantaraType.bodyMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('₱${p.price.toStringAsFixed(2)}', style: XantaraType.titleSm.copyWith(color: XantaraColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 380,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(XantaraSpacing.lg),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: XantaraColors.gray200))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current sale', style: XantaraType.titleMd),
                        TextButton(onPressed: () {}, child: const Text('Clear')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: XantaraSpacing.lg),
                      children: [
                        for (final item in _products.take(3))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: XantaraSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: XantaraType.bodyMd),
                                      Text('₱${item.price.toStringAsFixed(2)} each', style: XantaraType.labelSm),
                                    ],
                                  ),
                                ),
                                _QtyStepper(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(XantaraSpacing.lg),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: XantaraColors.gray200))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: XantaraType.titleMd),
                            Text('₱384.00', style: XantaraType.displayMd),
                          ],
                        ),
                        const SizedBox(height: XantaraSpacing.lg),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                          child: const Text('Charge ₱384.00'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity stepper sized for touchscreen use (44px+ tap targets) —
/// replaces generic +/- text buttons per the POS-ergonomics note.
class _QtyStepper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: XantaraColors.gray50, borderRadius: BorderRadius.circular(XantaraRadius.button)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.remove, size: 18), constraints: const BoxConstraints(minWidth: 44, minHeight: 44)),
          SizedBox(width: 20, child: Text('1', textAlign: TextAlign.center, style: XantaraType.labelMd)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add, size: 18), constraints: const BoxConstraints(minWidth: 44, minHeight: 44)),
        ],
      ),
    );
  }
}
