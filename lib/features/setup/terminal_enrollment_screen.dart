import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/sync/terminal_enrollment.dart';
import '../../local/database_providers.dart';
import '../../local/local_pos_store.dart';
import '../../local/repositories/company_registration_repository.dart';
import 'company_setup_screen.dart';

class TerminalEnrollmentScreen extends ConsumerStatefulWidget {
  const TerminalEnrollmentScreen({super.key});
  @override
  ConsumerState<TerminalEnrollmentScreen> createState() => _EnrollmentState();
}

class _EnrollmentState extends ConsumerState<TerminalEnrollmentScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = {
    for (final key in [
      'Terminal ID',
      'Enrollment code',
      'Admin email',
      'Admin password',
      'Local owner name',
      'Local owner email',
      'Local owner password',
      'Confirm local password'
    ])
      key: TextEditingController()
  };
  bool _busy = false, _reviewed = false;
  String? _error;
  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enroll() async {
    if (!_reviewed || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository =
          CompanyRegistrationRepository(ref.read(appDatabaseProvider));
      final preferences = await SharedPreferences.getInstance();
      await TerminalEnrollment(
              repository: repository,
              store: SharedPreferencesPosStore(preferences))
          .enroll(
              terminalId: _fields['Terminal ID']!.text,
              code: _fields['Enrollment code']!.text,
              adminEmail: _fields['Admin email']!.text,
              adminPassword: _fields['Admin password']!.text,
              ownerName: _fields['Local owner name']!.text,
              ownerEmail: _fields['Local owner email']!.text,
              ownerPassword: _fields['Local owner password']!.text);
      if (!mounted) return;
      await ref.read(switchInstallationProvider)(false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Enroll POS terminal')),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Form(
                  key: _form,
                  child: ListView(padding: const EdgeInsets.all(24), children: [
                    const Text(
                        'Activate the terminal in Admin → Settings → Company & BIR Details, then enter its ID and enrollment code here. This binds the terminal to this installation and saves its company and branch details for offline use.'),
                    const SizedBox(height: 16),
                    const Text(
                        'Use the administrator account that will connect cloud sync. The local owner account is separate and works offline.'),
                    const SizedBox(height: 16),
                    for (final entry in _fields.entries)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TextFormField(
                              controller: entry.value,
                              enabled: !_busy,
                              obscureText: entry.key.contains('password') ||
                                  entry.key == 'Enrollment code',
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                  labelText: entry.key,
                                  border: const OutlineInputBorder()),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (entry.key == 'Local owner password' &&
                                    v.length < 15) {
                                  return 'Use at least 15 characters';
                                }
                                if (entry.key == 'Confirm local password' &&
                                    v !=
                                        _fields['Local owner password']!.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              })),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _reviewed,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _reviewed = v ?? false),
                        title: const Text(
                            'I verified this terminal assignment and invoice series in the admin dashboard.')),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(_error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    FilledButton(
                        onPressed: _busy || !_reviewed ? null : _enroll,
                        child: Text(_busy
                            ? 'Enrolling…'
                            : 'Enroll and create local owner')),
                    const SizedBox(height: 14),
                    const Text(
                        'After enrollment, sign in locally and connect the same cloud administrator in Settings to synchronize stock. Enrollment does not constitute BIR approval.'),
                  ])))));
}
