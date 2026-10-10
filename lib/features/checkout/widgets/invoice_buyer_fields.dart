import 'package:flutter/material.dart';
import '../../../core/compliance/bir_invoice.dart';

/// Owned by checkout so text survives payment-page navigation and failed saves.
class InvoiceBuyerController {
  final name = TextEditingController();
  final tin = TextEditingController();
  final address = TextEditingController();
  bool isBusiness = false;
  BirBuyerDetails? get value {
    if (!isBusiness &&
        [name.text, tin.text, address.text].every((v) => v.trim().isEmpty)) {
      return null;
    }
    return BirBuyerDetails(
            registeredName: name.text,
            tin: tin.text,
            address: address.text,
            isBusiness: isBusiness)
        .normalized();
  }

  String? get error {
    final errors = value?.validate() ?? [];
    return errors.isEmpty ? null : errors.first;
  }

  void dispose() {
    name.dispose();
    tin.dispose();
    address.dispose();
  }
}

class InvoiceBuyerFields extends StatelessWidget {
  const InvoiceBuyerFields(
      {super.key,
      required this.controller,
      required this.onChanged,
      this.enabled = true});
  final InvoiceBuyerController controller;
  final VoidCallback onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Invoice buyer',
            style: TextStyle(fontWeight: FontWeight.w600)),
        Material(
            color: Colors.transparent,
            child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Business purchase'),
                subtitle: const Text(
                    'Use the registered buyer name, TIN and address.'),
                value: controller.isBusiness,
                onChanged: enabled
                    ? (v) {
                        controller.isBusiness = v;
                        onChanged();
                      }
                    : null)),
        TextField(
            key: const ValueKey('invoice-buyer-name'),
            controller: controller.name,
            enabled: enabled,
            maxLength: 200,
            decoration: InputDecoration(
                labelText: controller.isBusiness
                    ? 'Buyer registered name'
                    : 'Buyer name (optional)',
                counterText: ''),
            onChanged: (_) => onChanged()),
        const SizedBox(height: 8),
        TextField(
            key: const ValueKey('invoice-buyer-tin'),
            controller: controller.tin,
            enabled: enabled,
            maxLength: 30,
            decoration: InputDecoration(
                labelText: controller.isBusiness
                    ? 'Buyer TIN'
                    : 'Buyer TIN (optional)',
                counterText: ''),
            onChanged: (_) => onChanged()),
        const SizedBox(height: 8),
        TextField(
            key: const ValueKey('invoice-buyer-address'),
            controller: controller.address,
            enabled: enabled,
            maxLength: 400,
            decoration: InputDecoration(
                labelText: controller.isBusiness
                    ? 'Buyer registered address'
                    : 'Buyer address (optional)',
                counterText: ''),
            onChanged: (_) => onChanged()),
        if (controller.error != null)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(controller.error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 16),
      ]);
}
