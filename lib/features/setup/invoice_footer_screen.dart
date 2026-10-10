import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local/database_providers.dart';
import '../../local/repositories/invoice_particulars_repository.dart';
import '../auth/providers/auth_provider.dart';

class InvoiceFooterScreen extends ConsumerStatefulWidget {
  const InvoiceFooterScreen({super.key});
  @override
  ConsumerState<InvoiceFooterScreen> createState() =>
      _InvoiceFooterScreenState();
}

class _InvoiceFooterScreenState extends ConsumerState<InvoiceFooterScreen> {
  final fields = {
    for (final key in supplierFooterFields.keys) key: TextEditingController()
  };
  final password = TextEditingController();
  bool busy = true;
  String? message;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  InvoiceParticularsRepository get repo =>
      InvoiceParticularsRepository(ref.read(appDatabaseProvider));
  Future<void> load() async {
    try {
      final saved = await repo.footer();
      if (!mounted) return;
      for (final e in saved.entries) {
        fields[e.key]?.text = e.value;
      }
      loaded = true;
    } catch (e) {
      message = 'Could not load supplier particulars: $e';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      await repo.saveFooter(
          email: ref.read(authProvider).user!.email,
          password: password.text,
          values: {for (final e in fields.entries) e.key: e.value.text});
      if (!mounted) return;
      password.clear();
      message = 'Supplier particulars saved for future invoices.';
    } catch (e) {
      if (mounted) message = '$e';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Invoice supplier particulars')),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: ListView(padding: const EdgeInsets.all(24), children: [
                const Text(
                    'Copy the supplier and accreditation details from the approved documents. Saving applies to future invoices; earlier invoices retain their saved details.'),
                const SizedBox(height: 20),
                for (final e in supplierFooterFields.entries)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextField(
                          controller: fields[e.key],
                          enabled: loaded && !busy,
                          maxLength: 400,
                          decoration: InputDecoration(
                              labelText: e.value,
                              counterText: '',
                              border: const OutlineInputBorder()))),
                TextField(
                    controller: password,
                    enabled: loaded && !busy,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Owner password',
                        border: OutlineInputBorder())),
                if (message != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(message!)),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: loaded && !busy ? save : null,
                    child: Text(
                        busy ? 'Please wait...' : 'Save supplier particulars')),
              ]))));
}
