import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/pricing/statutory_discount.dart';
import '../../../local/database.dart';
import '../../../local/database_providers.dart';
import '../../../local/database_seed.dart';
import '../../../local/repositories/statutory_discount_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/fnb/providers/pos_provider.dart' show activeBranchProvider;
import '../../setup/company_setup_screen.dart';
import '../../reports/save_report.dart';

class StatutorySettingsScreen extends ConsumerStatefulWidget {
  const StatutorySettingsScreen({super.key});
  @override
  ConsumerState<StatutorySettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<StatutorySettingsScreen> {
  final _email = TextEditingController(), _password = TextEditingController();
  final _day = TextEditingController(
      text: DateTime.now()
          .toUtc()
          .add(const Duration(hours: 8))
          .toIso8601String()
          .substring(0, 10));
  List<Product> _products = [];
  Map<String, BenefitProductKind> _classes = {};
  Set<StatutoryScheme> _schemes = {};
  bool _busy = true, _reviewed = false;
  String? _message;
  StatutoryDiscountRepository get _repo =>
      StatutoryDiscountRepository(ref.read(appDatabaseProvider));
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _day.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final products = await (ref
              .read(appDatabaseProvider)
              .select(ref.read(appDatabaseProvider).products)
            ..where((p) => p.isActive.equals(true)))
          .get();
      final classes = await _repo.classifications();
      final schemes = await _repo.enabledSchemes();
      if (mounted) {
        setState(() {
          _products = products;
          _classes = classes;
          _schemes = schemes;
          _busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e.toString();
          _busy = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _repo.configure(
          email: _email.text,
          password: _password.text,
          branchId: branchIdForCode(ref.read(activeBranchProvider)),
          schemes: _schemes,
          classes: _classes);
      if (mounted) {
        setState(() {
          _message = 'Eligibility configuration saved.';
          _password.clear();
          _reviewed = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final actor = ref.read(authProvider).user;
      if (actor == null) throw StateError('Sign in to export.');
      final branch = branchIdForCode(ref.read(activeBranchProvider));
      final terminal = ref.read(companyRegistrationProvider)?.terminalId ??
          terminalIdForBranch(branch);
      final csv = await _repo.exportCsv(
          actorId: actor.id,
          branchId: branch,
          terminalId: terminal,
          day: _day.text.trim());
      final message =
          await saveReport('beneficiary-sales-${_day.text.trim()}.csv', csv);
      if (mounted) setState(() => _message = message);
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Senior / PWD settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Supporting beneficiary sales register',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
            'Exports this terminal’s invoices issued on the chosen Philippine business date, including their current void status. Internal supporting report; official format acceptance is separate.'),
        TextField(
            controller: _day,
            enabled: !_busy,
            decoration:
                const InputDecoration(labelText: 'Business date (YYYY-MM-DD)')),
        OutlinedButton(
            onPressed: _busy ? null : _export,
            child: const Text('Download beneficiary sales CSV')),
        const Divider(),
        const Text('Owner eligibility configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
            'Enable only benefits applicable to this business. Classify products from their actual description, origin and composition. A catalog name, SKU or tax-category change requires review again. Price changes alone retain classification.'),
        const SizedBox(height: 8),
        const Text(
            'Food service covers qualifying prepared food and beverages for personal consumption. Retail BNPC is a separate scheme; BMBE and CDA-registered cooperative exemptions must be reviewed before enabling it.'),
        const Text(
            'BNPC classifications must follow JAO 24-02 (2024), section 2: observe local-origin and product-specific restrictions. Examples: bread excludes cakes/pastries, rice excludes imported specialty rice, meat excludes premium grades, coffee has at most three main ingredients, candles exclude decorative/scented variants. LPG and kerosene are not supported here; leave them excluded. Do not classify medicine under general grocery goods.'),
        const SelectableText(
            'Source: https://ncda.gov.ph/wp-content/uploads/2024/04/JAO-DTI-DA-DOE-No.-240-02-S2024.pdf'),
        for (final scheme in StatutoryScheme.values)
          CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(scheme == StatutoryScheme.foodService
                  ? 'Qualifying food service — 20% and applicable VAT relief'
                  : 'Qualifying basic goods — 5%, weekly purchase cap'),
              value: _schemes.contains(scheme),
              onChanged: _busy
                  ? null
                  : (v) => setState(() {
                        v! ? _schemes.add(scheme) : _schemes.remove(scheme);
                        _reviewed = false;
                      })),
        for (final product in _products)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DropdownButtonFormField<BenefitProductKind>(
                  key: ValueKey('${product.id}:${_classes[product.id]}'),
                  initialValue:
                      _classes[product.id] ?? BenefitProductKind.unclassified,
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: '${product.name} (${product.sku})'),
                  items: BenefitProductKind.values
                      .map((k) => DropdownMenuItem(
                          value: k,
                          child:
                              Text(_label(k), overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _classes[product.id] = v!;
                            _reviewed = false;
                          }))),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _reviewed,
            title: const Text(
                'I reviewed the applicable rules, business coverage and each product’s eligibility. Unclassified products will block benefit checkout.'),
            onChanged: _busy ? null : (v) => setState(() => _reviewed = v!)),
        TextField(
            controller: _email,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'Owner email')),
        TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Owner password')),
        FilledButton(
            onPressed: _busy || !_reviewed ? null : _save,
            child: const Text('Save eligibility configuration')),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null) SelectableText(_message!),
      ]));
}

String _label(BenefitProductKind kind) => kind.name
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]!.toLowerCase()}');
