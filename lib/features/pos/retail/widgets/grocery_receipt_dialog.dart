import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../local/database_providers.dart';
import '../../../../local/repositories/terminal_closeout_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/hardware/pos_hardware.dart';

Future<void> showGroceryReceiptDialog(
        BuildContext context, ReceiptPrintData data) =>
    showDialog<void>(context: context, builder: (_) => _Receipt(data: data));

class _Receipt extends ConsumerStatefulWidget {
  const _Receipt({required this.data});
  final ReceiptPrintData data;
  @override
  ConsumerState<_Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends ConsumerState<_Receipt> {
  bool _printing = false;
  String? _error;
  Future<void> _printCopy() async {
    setState(() {
      _printing = true;
      _error = null;
    });
    try {
      final d = widget.data;
      final actor = ref.read(authProvider).user;
      if (actor == null) {
        throw StateError('Sign in before printing an invoice copy.');
      }
      final requestedAt =
          await TerminalCloseoutRepository(ref.read(appDatabaseProvider))
              .recordInvoicePdfCopy(actorId: actor.id, invoiceId: d.invoice.id);
      final text = const BirReceiptFormatter().format(ReceiptPrintData(
          invoice: d.invoice,
          payment: d.payment,
          cashierName: d.cashierName,
          isReprint: true,
          reprintedAt: requestedAt));
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (_) => [
                pw.Text(text,
                    style: pw.TextStyle(font: pw.Font.courier(), fontSize: 9))
              ]));
      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'The sale is saved. Printing failed: $e');
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Sale saved'),
          content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    SelectableText(
                        const BirReceiptFormatter().format(widget.data),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))
                  ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
            TextButton(
                onPressed: _printing ? null : _printCopy,
                child: Text(_printing ? 'Printing…' : 'Print copy'))
          ]);
}
