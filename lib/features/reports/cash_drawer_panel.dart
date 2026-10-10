import 'package:flutter/material.dart';
import '../../local/repositories/terminal_closeout_repository.dart';

typedef CashCommand = Future<void> Function(
    String kind, int amount, String note, String password);

class CashDrawerPanel extends StatefulWidget {
  const CashDrawerPanel(
      {super.key,
      required this.reading,
      required this.busy,
      required this.canRecord,
      required this.canReview,
      required this.onSave});
  final ReadingSnapshot reading;
  final bool busy, canRecord, canReview;
  final CashCommand onSave;
  @override
  State<CashDrawerPanel> createState() => _CashDrawerPanelState();
}

class _CashDrawerPanelState extends State<CashDrawerPanel> {
  final _amount = TextEditingController(),
      _note = TextEditingController(),
      _password = TextEditingController();
  String _kind = 'count';
  String? _error;
  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save(String kind) async {
    final text = _amount.text.trim();
    if (kind != 'review' && !RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) {
      setState(() => _error =
          'Enter a non-negative amount with up to two decimal places.');
      return;
    }
    final parts = text.split('.');
    final cents = kind == 'review'
        ? 0
        : int.parse(parts.first) * 100 +
            int.parse(parts.length == 2 ? parts[1].padRight(2, '0') : '0');
    setState(() => _error = null);
    await widget.onSave(kind, cents, _note.text, _password.text);
    if (mounted) _password.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cash = widget.reading.data['cashDrawer'] as Map?;
    if (cash == null) {
      return const Text(
          'No cash reconciliation was recorded with this older report.');
    }
    final started = cash['started'] == true;
    String money(dynamic v) => v == null
        ? 'Not counted'
        : 'PHP ${((v as int) / 100).toStringAsFixed(2)}';
    final status = !started
        ? 'Opening float not recorded'
        : cash['reviewed'] == true
            ? 'Manager reviewed'
            : cash['countFresh'] == true
                ? 'Awaiting manager review'
                : 'Count needed / previous count is stale';
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cash drawer reconciliation',
                  style: Theme.of(context).textTheme.titleLarge),
              Text(status),
              if (!started && !widget.reading.isZ)
                const Text(
                    'Record the opening float, including zero, to start drawer tracking for this day. Manager review will then be required before closing.'),
              const Text(
                  'Expected = opening float + cash sales + cash in − cash out − refund payouts. Record actual cash refunds separately; a void alone does not remove cash.'),
              const SizedBox(height: 12),
              for (final entry in const {
                'opening': 'Opening float',
                'cashSales': 'Cash sales (before void reversals)',
                'cashIn': 'Cash in',
                'cashOut': 'Cash out',
                'refunds': 'Refund payouts',
                'expected': 'Expected drawer cash',
                'counted': 'Actual cash counted',
                'variance': 'Overage (+) / shortage (−)'
              }.entries)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(spacing: 12, children: [
                      Text('${entry.value}:'),
                      Text(money(cash[entry.key]))
                    ])),
              if (!widget.reading.isZ && widget.canRecord) ...[
                const Divider(),
                if (started)
                  DropdownButtonFormField<String>(
                      initialValue: _kind,
                      decoration:
                          const InputDecoration(labelText: 'Cash operation'),
                      items: const [
                        DropdownMenuItem(
                            value: 'count', child: Text('Count drawer')),
                        DropdownMenuItem(
                            value: 'cash_in',
                            child: Text('Cash in / float correction')),
                        DropdownMenuItem(
                            value: 'cash_out',
                            child: Text('Cash out / bank deposit')),
                        DropdownMenuItem(
                            value: 'refund', child: Text('Refund paid in cash'))
                      ],
                      onChanged: widget.busy
                          ? null
                          : (v) => setState(() => _kind = v!)),
                TextField(
                    controller: _amount,
                    enabled: !widget.busy,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText:
                            started ? 'Amount (PHP)' : 'Opening float (PHP)',
                        hintText: '0.00')),
                TextField(
                    controller: _note,
                    enabled: !widget.busy,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                        labelText: 'Reason / reference',
                        helperText:
                            'Required for movements and any shortage or overage.')),
                if (_error != null)
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                FilledButton(
                    onPressed: widget.busy
                        ? null
                        : () => _save(started ? _kind : 'opening'),
                    child: Text(
                        started ? 'Save cash record' : 'Save opening float')),
                if (widget.canReview &&
                    cash['countFresh'] == true &&
                    cash['reviewed'] != true) ...[
                  TextField(
                      controller: _password,
                      enabled: !widget.busy,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          labelText: 'Your manager / owner password')),
                  OutlinedButton(
                      onPressed: widget.busy ? null : () => _save('review'),
                      child: const Text('Review drawer count')),
                ],
              ],
              ExpansionTile(
                  title: const Text('Cash record history'),
                  children: [
                    for (final entry in cash['entries'] as List)
                      ListTile(
                          title: Text(
                              '${entry['kind']} · ${money(entry['amount'])}'),
                          subtitle: Text(
                              '${entry['actorName']} · ${entry['recordedAt']}\n${entry['note']}')),
                  ]),
            ])));
  }
}
