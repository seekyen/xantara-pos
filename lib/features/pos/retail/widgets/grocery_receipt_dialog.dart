import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/grocery_cart_provider.dart';

const _storeName = 'SUPERMART GROCERY';
const _storeAddress = '123 Rizal St., Tayabas City';
const _storeTel = 'Tel: (042) 123-4567';
const _divider = '****************************************';
const _thinDivider = '────────────────────────────────────────';

/// Shows the post-payment thermal-style receipt. Awaits until dismissed.
Future<void> showGroceryReceiptDialog(BuildContext context, GroceryReceiptData data) {
  return showDialog<void>(
    context: context,
    builder: (_) => _GroceryReceiptDialog(data: data),
  );
}

class _GroceryReceiptDialog extends StatelessWidget {
  const _GroceryReceiptDialog({required this.data});

  final GroceryReceiptData data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 320,
                child: Text(
                  _buildReceiptText(data),
                  style: AppTextStyles.monoSm.copyWith(color: AppColors.gray800, height: 1.4),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray800,
                        side: const BorderSide(color: AppColors.gray200),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.rButton)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _print(data),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.rButton)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _print(GroceryReceiptData data) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Text(
          _buildReceiptText(data),
          style: pw.TextStyle(font: pw.Font.courier(), fontSize: 9),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }
}

String _peso(double v) => '₱${v.toStringAsFixed(2)}';

String _buildReceiptText(GroceryReceiptData data) {
  final buffer = StringBuffer();
  buffer.writeln(_centered(_storeName));
  buffer.writeln(_centered(_storeAddress));
  buffer.writeln(_centered(_storeTel));
  buffer.writeln(_divider);
  buffer.writeln(_kv('DATE', DateFormat('MM/dd/yyyy').format(data.dateTime)));
  buffer.writeln(_kv('TIME', DateFormat('hh:mm a').format(data.dateTime)));
  buffer.writeln(_kv('CASHIER', data.cashierName.toUpperCase()));
  buffer.writeln(_kv('TXN#', data.txnNumber.toString().padLeft(4, '0')));
  buffer.writeln(_divider);
  for (final item in data.items) {
    buffer.writeln(item.name.toUpperCase());
    buffer.writeln(_kv('  ${item.quantity} x ${_peso(item.unitPrice)}', _peso(item.lineTotal)));
  }
  buffer.writeln(_divider);
  buffer.writeln(_kv('SUBTOTAL', _peso(data.subtotal)));
  if (data.coupon != null) {
    buffer.writeln(_kv('COUPON (${data.coupon!.code})', '-${_peso(data.coupon!.amountOff)}'));
  }
  if (data.discountLabel != null) {
    buffer.writeln(_kv(data.discountLabel!, '-${_peso(data.discountAmount)}'));
  }
  buffer.writeln(_thinDivider);
  buffer.writeln(_kv('TOTAL', _peso(data.total)));
  buffer.writeln(_thinDivider);
  if (data.cashReceived != null) {
    buffer.writeln(_kv('CASH', _peso(data.cashReceived!)));
    buffer.writeln(_kv('CHANGE', _peso(data.change ?? 0)));
  } else {
    buffer.writeln(_kv(data.method.label.toUpperCase(), ''));
    buffer.writeln(_kv('REF#', data.referenceNumber ?? ''));
  }
  buffer.writeln(_divider);
  buffer.writeln(_centered('VAT-inclusive prices'));
  buffer.writeln(_centered('THANK YOU! COME AGAIN!'));
  buffer.writeln(_centered('Please keep this receipt'));
  buffer.writeln(_centered('*** END OF RECEIPT ***'));
  return buffer.toString().trimRight();
}

const _lineWidth = 40;

String _centered(String text) {
  if (text.length >= _lineWidth) return text;
  final padding = (_lineWidth - text.length) ~/ 2;
  return ' ' * padding + text;
}

String _kv(String label, String value) {
  final spaces = _lineWidth - label.length - value.length;
  return label + (spaces > 0 ? ' ' * spaces : ' ') + value;
}
