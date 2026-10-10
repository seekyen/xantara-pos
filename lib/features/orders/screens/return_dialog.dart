import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/compliance/bir_invoice.dart';
import '../../../core/compliance/credit_note.dart';
import '../../../local/database_providers.dart';
import '../../../local/repositories/credit_note_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reports/save_report.dart';

Future<void> showReturnDialog(BuildContext context, String invoiceId) =>
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ReturnDialog(invoiceId: invoiceId));

class _ReturnDialog extends ConsumerStatefulWidget {
  const _ReturnDialog({required this.invoiceId});
  final String invoiceId;
  @override
  ConsumerState<_ReturnDialog> createState() => _ReturnState();
}

class _ReturnState extends ConsumerState<_ReturnDialog> {
  final _reason = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController();
  final _quantities = <String, TextEditingController>{};
  final _restock = <String, bool>{};
  final _requestKey = const Uuid().v4();
  ReturnContext? _context;
  Map<String, dynamic>? _saved;
  String? _message;
  bool _busy = true, _paid = false;
  CreditNoteRepository get _repo =>
      CreditNoteRepository(ref.read(appDatabaseProvider));
  String get _actor => ref.read(authProvider).user?.id ?? '';
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    for (final c in [_reason, _email, _password, ..._quantities.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final value =
          await _repo.inspect(invoiceId: widget.invoiceId, actorId: _actor);
      if (!mounted) return;
      setState(() {
        _context = value;
        for (final l in value.lines) {
          _quantities[l.id] = TextEditingController(text: '0');
          _restock[l.id] = false;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<ReturnLineRequest> get _lines => [
        for (final entry in _quantities.entries)
          if ((int.tryParse(entry.value.text) ?? 0) > 0)
            ReturnLineRequest(entry.key, int.parse(entry.value.text),
                restock: _restock[entry.key] ?? false)
      ];
  Map<String, dynamic>? get _quote {
    try {
      return _context == null ? null : _repo.quote(_context!, _lines);
    } catch (_) {
      return null;
    }
  }

  Future<void> _issue() async {
    final quote = _quote;
    if (quote == null || _busy || !_paid) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final note = await _repo.issue(
          invoiceId: widget.invoiceId,
          actorId: _actor,
          supervisorEmail: _email.text,
          supervisorPassword: _password.text,
          requestKey: _requestKey,
          reason: _reason.text,
          lines: _lines,
          expectedTotalCentavos: (quote['totals'] as Map)['total'] as int,
          cashRefundConfirmed: _paid);
      if (mounted) {
        setState(() {
          _saved = note;
          _password.clear();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Return was not completed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(Map<String, dynamic> note) async {
    setState(() => _busy = true);
    try {
      final text =
          await _repo.copyText(noteId: note['id'] as String, actorId: _actor);
      final message = await saveReport('${note['number']}-copy.txt', text);
      if (mounted) setState(() => _message = message);
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Credit note is saved; copy failed: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    return PopScope(
        canPop: !_busy,
        child: AlertDialog(
            title: Text(_saved == null
                ? 'Returns / credit notes'
                : 'Credit note saved'),
            content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      if (_busy) const LinearProgressIndicator(),
                      if (_saved != null) ...[
                        SelectableText(formatCreditNote(_saved!)),
                        OutlinedButton(
                            onPressed: _busy ? null : () => _download(_saved!),
                            child: const Text('Download credit note copy')),
                      ] else if (_context != null) ...[
                        Text('Original: ${_context!.invoice.invoiceNumber}'),
                        const Text(
                            'Select returned quantities and whether each item goes back into sellable stock. The original invoice stays unchanged. Cash refunds require an opened drawer and supervisor authorization.'),
                        for (final note in _context!.notes)
                          ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(note['number'] as String),
                              subtitle: Text(
                                  'Refund PHP ${(((note['totals'] as Map)['total'] as int) / 100).toStringAsFixed(2)}'),
                              trailing: IconButton(
                                  tooltip: 'Download credit note copy',
                                  icon: const Icon(Icons.download),
                                  onPressed:
                                      _busy ? null : () => _download(note))),
                        for (final line in _context!.lines) ...[
                          const Divider(),
                          Text(
                              '${line.description} — remaining ${line.quantity - (_context!.returned[line.id] ?? 0)}'),
                          TextField(
                              key:
                                  ValueKey('return-quantity-${line.productId}'),
                              controller: _quantities[line.id],
                              enabled: !_busy &&
                                  _context!.invoice.status ==
                                      InvoiceStatus.issued,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                  labelText: 'Quantity to return'),
                              onChanged: (_) => setState(() {})),
                          CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                  'Return these units to sellable stock'),
                              value: _restock[line.id]!,
                              onChanged: _busy
                                  ? null
                                  : (v) =>
                                      setState(() => _restock[line.id] = v!)),
                        ],
                        if (quote == null)
                          const Text(
                              'Choose valid quantities within the remaining balance.')
                        else
                          Text(
                              'Cash refund: PHP ${(((quote['totals'] as Map)['total'] as int) / 100).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium),
                        TextField(
                            controller: _reason,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                                labelText: 'Return reason'),
                            onChanged: (_) => setState(() {})),
                        TextField(
                            controller: _email,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                                labelText: 'Supervisor email')),
                        TextField(
                            controller: _password,
                            enabled: !_busy,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Supervisor password')),
                        CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                                'Record this cash refund once. Do not add a separate manual cash payout.'),
                            value: _paid,
                            onChanged: _busy
                                ? null
                                : (v) => setState(() => _paid = v!)),
                      ],
                      if (_message != null) Text(_message!),
                    ]))),
            actions: [
              TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: Text(_saved == null ? 'Cancel' : 'Done')),
              if (_saved == null)
                FilledButton(
                    onPressed: _busy ||
                            !_paid ||
                            quote == null ||
                            _reason.text.trim().isEmpty ||
                            _context?.invoice.status != InvoiceStatus.issued
                        ? null
                        : _issue,
                    child: const Text('Record return and cash refund')),
            ]));
  }
}
