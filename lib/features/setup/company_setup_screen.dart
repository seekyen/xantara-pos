import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/compliance/bir_invoice.dart';
import '../../local/database_providers.dart';
import '../../local/repositories/company_registration_repository.dart';
import '../auth/providers/auth_provider.dart';
import 'terminal_enrollment_screen.dart';
import 'invoice_footer_screen.dart';
import '../business_profiles/business_profiles_screen.dart';

final companyRegistrationProvider =
    StateProvider<CompanyRegistration?>((ref) => null);
final isDemoInstallationProvider = Provider<bool>((ref) => true);
final switchInstallationProvider =
    Provider<Future<void> Function(bool)>((ref) => (_) async {});

class CompanySetupScreen extends ConsumerStatefulWidget {
  const CompanySetupScreen({super.key, this.initial});
  final CompanyRegistration? initial;
  @override
  ConsumerState<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends ConsumerState<CompanySetupScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  TaxRegistrationType _tax = TaxRegistrationType.vat;
  bool _busy = false, _reviewed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final key in [
      'Company name',
      'TIN',
      'Registered address',
      'Branch code',
      'RDO code',
      'Terminal code',
      'Machine serial',
      'MIN',
      'PTU number',
      'PTU issue date',
      'Starting serial',
      'Owner name',
      'Owner email',
      'Owner password',
      'Confirm password',
      'Cloud business ID'
    ]) {
      _fields[key] = TextEditingController();
    }
    _fields['Terminal code']!.text =
        'POS${const Uuid().v4().replaceAll('-', '').substring(0, 10).toUpperCase()}';
    _fields['Starting serial']!.text = '1';
    final p = widget.initial;
    if (p != null) {
      _tax = p.registrationType;
      final owner = ref.read(authProvider).user;
      final values = {
        'Company name': p.registeredName,
        'TIN': p.tin,
        'Registered address': p.address,
        'Branch code': p.branchCode,
        'RDO code': p.rdo,
        'Terminal code': p.terminalCode,
        'Machine serial': p.machineSerial,
        'MIN': p.min,
        'PTU number': p.ptu,
        'PTU issue date': p.ptuIssuedOn,
        'Starting serial': '${p.startingSerial}',
        'Owner name': owner?.name ?? '',
        'Owner email': owner?.email ?? '',
        'Cloud business ID': p.cloudBusinessId
      };
      for (final entry in values.entries) {
        _fields[entry.key]!.text = entry.value;
      }
    }
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  String _value(String key) => _fields[key]!.text;
  Widget _field(String label,
          {String? hint, bool secret = false, bool optional = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
            controller: _fields[label],
            obscureText: secret,
            enabled: !_busy &&
                !(widget.initial != null &&
                    ['Owner name', 'Owner email'].contains(label)),
            autocorrect: !secret,
            enableSuggestions: !secret,
            maxLines: label == 'Registered address' ? 2 : 1,
            decoration: InputDecoration(
                labelText: optional ? '$label (optional)' : label,
                helperText: hint,
                helperMaxLines: 3,
                border: const OutlineInputBorder()),
            validator: (value) {
              if (!optional && (value == null || value.trim().isEmpty)) {
                return 'Required';
              }
              if (label == 'Owner password' && (value?.length ?? 0) < 15) {
                return 'Use at least 15 characters';
              }
              if (label == 'Confirm password' &&
                  value != _value('Owner password')) {
                return 'Passwords do not match';
              }
              return null;
            }),
      );

  Future<void> _save() async {
    if (!_reviewed || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final request = CompanySetupRequest(
        registeredName: _value('Company name'),
        tin: _value('TIN'),
        address: _value('Registered address'),
        branchCode: _value('Branch code'),
        rdo: _value('RDO code'),
        registrationType: _tax,
        terminalCode: _value('Terminal code'),
        machineSerial: _value('Machine serial'),
        min: _value('MIN'),
        ptu: _value('PTU number'),
        ptuIssuedOn: _value('PTU issue date').trim(),
        startingSerial: int.tryParse(_value('Starting serial')) ?? 0,
        ownerName: _value('Owner name'),
        ownerEmail: _value('Owner email'),
        ownerPassword: _value('Owner password'),
        cloudBusinessId: _value('Cloud business ID'),
      );
      final repository =
          CompanyRegistrationRepository(ref.read(appDatabaseProvider));
      if (widget.initial != null) {
        final next = await repository.updateDraft(request);
        if (!mounted) return;
        ref.read(companyRegistrationProvider.notifier).state = next;
        Navigator.of(context).pop();
        return;
      }
      await repository.register(request);
      if (!mounted) return;
      await ref.read(switchInstallationProvider)(false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Set up your company')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Form(
                    key: _form,
                    child:
                        ListView(padding: const EdgeInsets.all(24), children: [
                      const BusinessProfilesTile(),
                      Text('Company and terminal registration',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      const Text(
                          'Use the details on your company and terminal documents. Setup saves a separate company workspace and creates your local owner account. It does not register your business with BIR.'),
                      const SizedBox(height: 12),
                      if (widget.initial == null)
                        FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const TerminalEnrollmentScreen())),
                            icon: const Icon(Icons.link),
                            label: const Text('Enroll from admin dashboard')),
                      if (widget.initial == null)
                        OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () =>
                                    ref.read(switchInstallationProvider)(true),
                            child: const Text('Use demo workspace instead')),
                      const SizedBox(height: 24),
                      _field('Company name'),
                      _field('TIN',
                          hint:
                              'Nine digits; enter the branch code separately'),
                      _field('Registered address'),
                      _field('Branch code',
                          hint: 'Five digits, for example 00000'),
                      _field('RDO code', hint: 'Three digits'),
                      DropdownButtonFormField<TaxRegistrationType>(
                          isExpanded: true,
                          initialValue: _tax,
                          decoration: const InputDecoration(
                              labelText: 'Tax registration',
                              border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: TaxRegistrationType.vat,
                                child: Text('VAT registered')),
                            DropdownMenuItem(
                                value: TaxRegistrationType.nonVat,
                                child: Text('Non-VAT registered'))
                          ],
                          onChanged: _busy
                              ? null
                              : (value) => setState(() => _tax = value!)),
                      const SizedBox(height: 24),
                      Text('This terminal',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _field('Terminal code',
                          hint:
                              'Unique within your company; included in invoice numbers'),
                      _field('Machine serial'),
                      _field('MIN'),
                      _field('PTU number'),
                      _field('PTU issue date', hint: 'YYYY-MM-DD'),
                      _field('Starting serial',
                          hint:
                              'Confirmed starting point for this new terminal; existing invoice series must not restart'),
                      _field('Cloud business ID',
                          optional: true,
                          hint:
                              'Must match your existing admin deployment. Leave blank for offline setup.'),
                      Text('Owner account',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      const Text(
                          'This account signs in to this POS. Your web admin account remains separate.'),
                      const SizedBox(height: 12),
                      _field('Owner name'),
                      _field('Owner email'),
                      if (widget.initial != null)
                        const Text(
                            'Enter your current owner password to authorize these changes.'),
                      _field('Owner password', secret: true),
                      _field('Confirm password', secret: true),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _reviewed,
                          title: const Text(
                              'I have checked these details and confirmed this terminal code and invoice series are not used by another device.'),
                          onChanged: _busy
                              ? null
                              : (value) =>
                                  setState(() => _reviewed = value ?? false)),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(_error!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error))),
                      FilledButton(
                          onPressed: _busy || !_reviewed ? null : _save,
                          child: Text(_busy
                              ? 'Saving company…'
                              : widget.initial == null
                                  ? 'Save company and owner'
                                  : 'Save registration changes')),
                      const SizedBox(height: 12),
                      const Text(
                          'Sign in as the owner after saving, then review and activate in Settings → Company & terminal. Demo records are kept separately.'),
                    ])))),
      );
}

class CompanyRegistrationTile extends ConsumerWidget {
  const CompanyRegistrationTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(companyRegistrationProvider);
    final owner = ref.watch(authProvider).user?.role == 'owner';
    return Card(
        child: ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Company & terminal'),
            subtitle: Text(company == null
                ? 'Demo workspace • separate from company records'
                : '${company.registeredName} • ${company.isActive ? "Activated" : "Awaiting activation"}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => company == null
                    ? Scaffold(
                        appBar: AppBar(title: const Text('Demo workspace')),
                        body: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Demo sales and credentials remain in this workspace. Company setup creates a separate database and owner account.'),
                                  const SizedBox(height: 16),
                                  if (owner)
                                    FilledButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await ref.read(
                                                  switchInstallationProvider)(
                                              false);
                                        },
                                        child: const Text('Set up company'))
                                  else
                                    const Text(
                                        'Sign in as the owner to set up the company.'),
                                ])))
                    : const CompanyRegistrationScreen()))));
  }
}

class CompanyRegistrationScreen extends ConsumerStatefulWidget {
  const CompanyRegistrationScreen({super.key});
  @override
  ConsumerState<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState
    extends ConsumerState<CompanyRegistrationScreen> {
  final _password = TextEditingController();
  bool _confirmed = false, _busy = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile =
          await CompanyRegistrationRepository(ref.read(appDatabaseProvider))
              .activate(
                  email: ref.read(authProvider).user!.email,
                  password: _password.text);
      if (!mounted) return;
      ref.read(companyRegistrationProvider.notifier).state = profile;
      _password.clear();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(companyRegistrationProvider)!;
    final isOwner = ref.watch(authProvider).user?.id == p.ownerId;
    final details = {
      'Company': p.registeredName,
      'TIN': p.tin,
      'Address': p.address,
      'Branch code': p.branchCode,
      'RDO': p.rdo,
      'Tax registration':
          p.registrationType == TaxRegistrationType.vat ? 'VAT' : 'Non-VAT',
      'Terminal': p.terminalCode,
      'Machine serial': p.machineSerial,
      'MIN': p.min,
      'PTU': p.ptu,
      'PTU issued': p.ptuIssuedOn,
      'First invoice':
          '${p.branchCode}-${p.terminalCode}-${p.startingSerial.toString().padLeft(8, '0')}',
      'Cloud business':
          p.cloudBusinessId.isEmpty ? 'Not linked' : p.cloudBusinessId,
      if (p.serverTerminalId.isNotEmpty)
        'Assigned cloud branch': p.cloudBranchCode,
      if (p.serverTerminalId.isNotEmpty) 'Server terminal': p.serverTerminalId,
    };
    return Scaffold(
        appBar: AppBar(title: const Text('Company & terminal')),
        body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: ListView(padding: const EdgeInsets.all(24), children: [
                Text(
                    p.isActive
                        ? 'Terminal activated'
                        : 'Review before activation',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                    'Registration details can be corrected before activation and are locked afterward. Historical invoices keep their original details. No reset or deletion of live records is provided.'),
                const SizedBox(height: 12),
                for (final entry in details.entries)
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.key),
                      subtitle: SelectableText(entry.value)),
                if (isOwner)
                  OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const InvoiceFooterScreen())),
                      child: const Text('Invoice supplier particulars')),
                if (!p.isActive && isOwner) ...[
                  OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      CompanySetupScreen(initial: p))),
                      child: const Text('Edit registration details')),
                  const Text(
                      'Activation enables this terminal’s saved-invoice checkout. BIR accreditation, X/Z reporting and inspection readiness are separate work. Grocery checkout remains unavailable until its permanent sales flow is completed.'),
                  CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _confirmed,
                      title: const Text(
                          'I confirm the registration details and unique invoice series for this terminal.'),
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _confirmed = v ?? false)),
                  TextField(
                      controller: _password,
                      obscureText: true,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                          labelText: 'Owner password',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  FilledButton(
                      onPressed: _busy || !_confirmed ? null : _activate,
                      child: Text(
                          _busy ? 'Activating…' : 'Activate this terminal')),
                ] else if (!p.isActive)
                  const Text(
                      'The registered owner must activate this terminal.'),
              ])),
        ));
  }
}
