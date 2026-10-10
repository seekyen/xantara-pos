import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../local/database_providers.dart';
import '../../local/database_seed.dart';
import '../../local/repositories/terminal_closeout_repository.dart';
import '../auth/providers/auth_provider.dart';
import '../pos/fnb/providers/pos_provider.dart';
import '../setup/company_setup_screen.dart';
import 'daily_report_csv.dart';
import 'save_report.dart';
import 'cash_drawer_panel.dart';

class TerminalReadingsTile extends StatelessWidget {
  const TerminalReadingsTile({super.key});
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('End-of-day reports'),
          subtitle: const Text('X / Z readings, Excel download and PDF'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const TerminalReadingsScreen()))));
}

class TerminalReadingsScreen extends ConsumerStatefulWidget {
  const TerminalReadingsScreen({super.key});
  @override
  ConsumerState<TerminalReadingsScreen> createState() => _ReadingsState();
}

class _ReadingsState extends ConsumerState<TerminalReadingsScreen> {
  ReadingSnapshot? _reading;
  List<ReadingSnapshot> _history = [];
  List<String> _days = [];
  String? _day, _error;
  bool _busy = false;
  final _password = TextEditingController();
  bool _reviewed = false;
  String? _journalDay;
  TerminalCloseoutRepository get _repository =>
      TerminalCloseoutRepository(ref.read(appDatabaseProvider));
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _reading = null;
      _reviewed = false;
      _password.clear();
    });
    try {
      final actor = ref.read(authProvider).user;
      if (actor == null) throw StateError('Sign in to view readings.');
      final branch = branchIdForCode(ref.read(activeBranchProvider));
      final terminal = ref.read(companyRegistrationProvider)?.terminalId ??
          terminalIdForBranch(branch);
      final repo = _repository;
      final history = await repo.history(
          actorId: actor.id, branchId: branch, terminalId: terminal);
      final days = await repo.openDays(
          actorId: actor.id, branchId: branch, terminalId: terminal);
      final day = days.contains(_day) ? _day : days.firstOrNull;
      final reading = day == null
          ? null
          : await repo.xReading(
              actorId: actor.id,
              branchId: branch,
              terminalId: terminal,
              day: day);
      if (mounted) {
        setState(() {
          _days = days;
          _day = day;
          _history = history;
          _reading = reading;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    final reading = _reading;
    if (_busy || reading == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repository.recordOutputRequest(
          actorId: ref.read(authProvider).user!.id, reading: reading);
      final terminal =
          reading.terminalId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final name =
          'daily-report-$terminal-${reading.day}-${reading.isZ ? 'Z${reading.zNumber}' : 'X'}-${DateTime.now().microsecondsSinceEpoch}.csv';
      final message = await saveReport(name, dailyReportCsv(reading));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error =
            'Export failed: $e. The report is unchanged; you can retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportJournal() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actor = ref.read(authProvider).user;
      if (actor == null) throw StateError('Sign in to export a journal.');
      final branch = branchIdForCode(ref.read(activeBranchProvider));
      final terminal = ref.read(companyRegistrationProvider)?.terminalId ??
          terminalIdForBranch(branch);
      final day =
          _journalDay ?? _reading?.day ?? manilaBusinessDay(DateTime.now());
      final journal = await _repository.exportJournal(
          actorId: actor.id, branchId: branch, terminalId: terminal, day: day);
      final safeTerminal = terminal.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final message = await saveReport(
          'electronic-journal-$safeTerminal-$day-${DateTime.now().microsecondsSinceEpoch}.txt',
          journal.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '$message ${journal.documentCount} documents; ${journal.reconstructedCount} reconstructed.')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Journal export stopped: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseJournalDay() async {
    final today = DateTime.parse(manilaBusinessDay(DateTime.now()));
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(
            _journalDay ?? _reading?.day ?? manilaBusinessDay(DateTime.now())),
        firstDate: DateTime(2000),
        lastDate: today);
    if (date != null && mounted) {
      setState(() => _journalDay = date.toIso8601String().substring(0, 10));
    }
  }

  Future<void> _close() async {
    final reading = _reading;
    if (_busy || reading == null || reading.isZ || !_reviewed) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actor = ref.read(authProvider).user!;
      final z = await _repository.closeDay(
          actorId: actor.id, password: _password.text, reviewed: reading);
      final history = await _repository.history(
          actorId: actor.id, branchId: z.branchId, terminalId: z.terminalId);
      if (mounted) {
        setState(() {
          _reading = z;
          _history = history;
          _days.remove(z.day);
          _day = null;
          _password.clear();
          _reviewed = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveCash(
      String kind, int amount, String note, String password) async {
    if (_busy || _reading == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repository.recordCash(
          actorId: ref.read(authProvider).user!.id,
          reading: _reading!,
          kind: kind,
          amountCentavos: amount,
          note: note,
          password: password);
      await _load();
    } catch (e) {
      if (mounted) {
        final message = e is ArgumentError
            ? '${e.message}'
            : e is StateError
                ? e.message
                : '$e';
        setState(() => _error = message);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _output({required bool copy}) async {
    if (_busy || _reading == null) return;
    setState(() => _busy = true);
    try {
      await _repository.recordOutputRequest(
          actorId: ref.read(authProvider).user!.id, reading: _reading!);
      final text = _reading!.format(reprint: true);
      if (copy) {
        await Clipboard.setData(ClipboardData(text: text));
      } else {
        final document = pw.Document();
        document.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (_) => text
                .split('\n')
                .map((line) => pw.Text(line,
                    style: pw.TextStyle(font: pw.Font.courier(), fontSize: 10)))
                .toList()));
        await Printing.layoutPdf(onLayout: (_) => document.save());
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = 'The saved report is unchanged. Output failed: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canClose = ['owner', 'admin', 'manager']
        .contains(ref.watch(authProvider).user?.role);
    return Scaffold(
        appBar: AppBar(title: const Text('End-of-day reports'), actions: [
          IconButton(
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh readings')
        ]),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  const Text(
                      'X shows the selected business day without closing it. Z saves a permanent daily snapshot. Only the active business and selected terminal are included, together with their retained historical sales.'),
                  const Text(
                      'Choose a day, review the totals, then download for Excel or save a PDF. Exporting does not close the day.'),
                  const SizedBox(height: 16),
                  Text('Electronic journal',
                      style: Theme.of(context).textTheme.titleMedium),
                  Wrap(spacing: 8, children: [
                    OutlinedButton(
                        onPressed: _busy ? null : _chooseJournalDay,
                        child: Text(
                            'Journal date: ${_journalDay ?? _reading?.day ?? manilaBusinessDay(DateTime.now())}')),
                    FilledButton.icon(
                        onPressed: _busy ? null : _exportJournal,
                        icon: const Icon(Icons.download),
                        label:
                            const Text('Download electronic journal (.txt)')),
                  ]),
                  const Text(
                      'Full saved documents for this terminal. Older records are labelled reconstructed; copy requests do not confirm printing.'),
                  if (_busy) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  if (_days.isNotEmpty)
                    DropdownButtonFormField<String>(
                        key: ValueKey(_day),
                        initialValue: _day,
                        decoration: const InputDecoration(
                            labelText: 'Open business day (Asia/Manila)',
                            border: OutlineInputBorder()),
                        items: _days
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: _busy
                            ? null
                            : (d) {
                                _day = d;
                                _load();
                              }),
                  if (_reading != null) ...[
                    const SizedBox(height: 16),
                    Text(
                        '${_reading!.day} · ${_reading!.isZ ? 'Closed — Z #${_reading!.zNumber}' : 'Open — X snapshot'}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                        'Generated: ${_reading!.data['generatedAt']} (UTC). Refresh for the latest open-day totals.'),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final metric in const {
                        'gross': 'Gross sales',
                        'discount': 'Discounts',
                        'void': 'Voids',
                        'net': 'Net sales'
                      }.entries)
                        SizedBox(
                            width: 168,
                            child: Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(metric.value),
                                          Text(
                                              'PHP ${(_reading!.totals[metric.key] / 100).toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                        ])))),
                    ]),
                    Text(
                        '${_reading!.data['saleCount']} sales · ${_reading!.data['voidCount']} voids'),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _exportCsv,
                          icon: const Icon(Icons.download),
                          label: const Text('Download for Excel (CSV)'),
                        )),
                    ExpansionTile(
                        title: const Text('Full report / X / Z readings'),
                        children: [
                          SelectableText(_reading!.format(),
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13))
                        ]),
                    Wrap(spacing: 12, children: [
                      TextButton(
                          onPressed: _busy ? null : () => _output(copy: true),
                          child: const Text('Copy report text')),
                      TextButton(
                          onPressed: _busy ? null : () => _output(copy: false),
                          child: const Text('Print / save PDF copy'))
                    ]),
                    CashDrawerPanel(
                        key: ValueKey(
                            '${_reading!.day}:${(_reading!.data['cashDrawer'] as Map?)?['version']}'),
                        reading: _reading!,
                        busy: _busy,
                        canReview: canClose,
                        canRecord: ['owner', 'admin', 'manager', 'cashier']
                            .contains(ref.watch(authProvider).user?.role),
                        onSave: _saveCash),
                    if (!_reading!.isZ && canClose) ...[
                      const Divider(),
                      const Text(
                          'Close only when all sales and adjustments for this day are finished. Closing today prevents further sales and voids on this terminal until the next Manila business day. Earlier unclosed days must be closed first.'),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _reviewed,
                          onChanged: _busy
                              ? null
                              : (v) => setState(() => _reviewed = v ?? false),
                          title: const Text(
                              'I reviewed these totals and want to permanently close this business day.')),
                      TextField(
                          controller: _password,
                          enabled: !_busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                              labelText: 'Your manager / owner password',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _busy ||
                                  !_reviewed ||
                                  ((_reading!.data['cashDrawer']
                                              as Map?)?['started'] ==
                                          true &&
                                      (_reading!.data['cashDrawer']
                                              as Map?)?['reviewed'] !=
                                          true)
                              ? null
                              : _close,
                          child: const Text('Save Z and close day')),
                    ],
                  ],
                  if (!_busy && _days.isEmpty)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                            'No open business day. Saved reports remain available below.')),
                  const Divider(),
                  Text('Saved Z readings',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_history.isEmpty)
                    const Text(
                        'No daily closeouts saved yet. Existing unclosed sales will appear on their original business dates.'),
                  for (final z in _history)
                    ListTile(
                        title: Text('Z #${z.zNumber} · ${z.day}'),
                        subtitle: Text(
                            'Net sales: PHP ${(z.totals['net'] / 100).toStringAsFixed(2)}'),
                        onTap: _busy
                            ? null
                            : () => setState(() {
                                  _reading = z;
                                  _reviewed = false;
                                  _password.clear();
                                })),
                ]))));
  }
}
