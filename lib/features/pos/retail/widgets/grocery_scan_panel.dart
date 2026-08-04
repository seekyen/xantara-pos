import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/grocery_cart_provider.dart';

/// Bottom bar of the left panel: a quantity multiplier and the
/// barcode/description scan field. Resets the multiplier back to 1 after
/// every scan and shows the last-scanned item's code, name, and unit price.
class GroceryScanPanel extends StatefulWidget {
  const GroceryScanPanel({
    super.key,
    required this.onScan,
  });

  /// Called with the scanned code and the multiplier in effect at scan time.
  final void Function(String code, int quantity) onScan;

  @override
  State<GroceryScanPanel> createState() => GroceryScanPanelState();
}

class GroceryScanPanelState extends State<GroceryScanPanel> {
  final _multiplierCtrl = TextEditingController(text: '1');
  final _barcodeCtrl = TextEditingController();
  final _barcodeFocus = FocusNode();

  Product? lastScanned;
  String? lastScannedCode;

  @override
  void dispose() {
    _multiplierCtrl.dispose();
    _barcodeCtrl.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  void focusBarcodeField() => _barcodeFocus.requestFocus();

  /// Called by the parent screen once it knows whether the scanned code
  /// matched a product, so the last-scanned line can show a result.
  void reportScanResult(String code, Product? product) {
    setState(() {
      lastScannedCode = code;
      lastScanned = product;
    });
  }

  void _submit(String code) {
    if (code.trim().isEmpty) return;
    final quantity = int.tryParse(_multiplierCtrl.text.trim()) ?? 1;
    widget.onScan(code.trim(), quantity <= 0 ? 1 : quantity);
    _barcodeCtrl.clear();
    _multiplierCtrl.text = '1';
    _barcodeFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MULTIPLIER',
                    style: AppTextStyles.labelCaps.copyWith(color: AppColors.gray400)),
                const SizedBox(height: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppSizes.rInput),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _multiplierCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: AppTextStyles.titleMd,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      Text('×', style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray400)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ITEM CODE · DESCRIPTION',
                    style: AppTextStyles.labelCaps.copyWith(color: AppColors.gray400)),
                const SizedBox(height: AppSizes.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppSizes.rInput),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _barcodeCtrl,
                        focusNode: _barcodeFocus,
                        autofocus: true,
                        style: AppTextStyles.titleMd,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          isCollapsed: true,
                          hintText: 'Scan or type code',
                        ),
                        onSubmitted: _submit,
                      ),
                      if (lastScannedCode != null) ...[
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          lastScanned != null
                              ? '${lastScanned!.name} — ₱${lastScanned!.price.toStringAsFixed(2)}'
                              : 'Not found',
                          style: AppTextStyles.caption.copyWith(
                            color:
                                lastScanned != null ? AppColors.gray600 : AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
