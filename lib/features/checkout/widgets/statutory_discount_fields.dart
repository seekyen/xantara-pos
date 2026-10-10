import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/pricing/statutory_discount.dart';
import '../../../core/pricing/commercial_discounts.dart';
import '../../../local/database_providers.dart';
import '../../../local/repositories/statutory_discount_repository.dart';

class StatutorySelection {
  const StatutorySelection(this.claim, this.quote);
  final StatutoryClaim claim;
  final StatutoryQuote quote;
}

/// Selection belongs to the payment dialog, never to a global customer profile.
class StatutoryDiscountFields extends ConsumerWidget {
  const StatutoryDiscountFields(
      {super.key,
      required this.checkoutType,
      required this.quantities,
      required this.selection,
      required this.enabled,
      required this.onChanged,
      this.hasOtherDiscount = false});
  final String checkoutType;
  final Map<String, int> quantities;
  final StatutorySelection? selection;
  final bool enabled, hasOtherDiscount;
  final ValueChanged<StatutorySelection?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OutlinedButton.icon(
            icon: const Icon(Icons.badge_outlined),
            label: Text(selection == null
                ? 'Senior / PWD benefit'
                : 'Edit Senior / PWD benefit'),
            onPressed: !enabled
                ? null
                : () async {
                    if (hasOtherDiscount) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Remove the promotion or custom discount before choosing a statutory benefit.')));
                      return;
                    }
                    final chosen = await showDialog<StatutorySelection>(
                        context: context,
                        builder: (_) => _ClaimDialog(
                            checkoutType: checkoutType,
                            quantities: quantities));
                    if (chosen != null) onChanged(chosen);
                  }),
        if (selection != null) ...[
          Text(
              '${selection!.claim.kind.name.toUpperCase()}: ${selection!.claim.name}'),
          Text(
              'Discount: PHP ${(selection!.quote.discountCentavos / 100).toStringAsFixed(2)} • VAT removed: PHP ${(selection!.quote.vatReliefCentavos / 100).toStringAsFixed(2)}'),
          TextButton(
              onPressed: enabled ? () => onChanged(null) : null,
              child: const Text('Remove benefit')),
        ],
      ]));
}

class _ClaimDialog extends ConsumerStatefulWidget {
  const _ClaimDialog({required this.checkoutType, required this.quantities});
  final String checkoutType;
  final Map<String, int> quantities;
  @override
  ConsumerState<_ClaimDialog> createState() => _ClaimState();
}

class _ClaimState extends ConsumerState<_ClaimDialog> {
  final _name = TextEditingController(),
      _id = TextEditingController(),
      _type = TextEditingController(),
      _prior = TextEditingController(),
      _priorDiscount = TextEditingController();
  BeneficiaryKind _kind = BeneficiaryKind.senior;
  bool _verified = false,
      _exclusive = false,
      _personal = false,
      _booklet = false,
      _four = false,
      _busy = false;
  String? _error;
  bool get _bnpc => widget.checkoutType == 'retail';
  @override
  void dispose() {
    for (final c in [_name, _id, _type, _prior, _priorDiscount]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final claim = StatutoryClaim(
          kind: _kind,
          scheme: _bnpc ? StatutoryScheme.bnpc : StatutoryScheme.foodService,
          name: _name.text,
          idNumber: _id.text,
          idType: _type.text,
          identityVerified: _verified,
          exclusiveUse: _exclusive,
          personalPurchase: _personal,
          bookletChecked: _booklet,
          fourKindsConfirmed: _four,
          priorWeekDiscountCentavos:
              _bnpc ? parseDiscountHundredths(_priorDiscount.text) : 0,
          priorWeekSpendCentavos:
              _bnpc ? parseDiscountHundredths(_prior.text) : 0);
      final quote =
          await StatutoryDiscountRepository(ref.read(appDatabaseProvider))
              .preview(
                  claim: claim,
                  quantities: widget.quantities,
                  checkoutType: widget.checkoutType);
      if (mounted) Navigator.pop(context, StatutorySelection(claim, quote));
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: Text(_bnpc
              ? 'Senior / PWD — basic goods'
              : 'Senior / PWD — food service'),
          content: SizedBox(
              width: 470,
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_bnpc
                        ? '5% on classified basic necessities and prime commodities. VAT treatment stays unchanged. Check purchases at every store this Sunday–Saturday week.'
                        : '20% on classified food-service items, after applicable VAT removal. Use a separate basket for one beneficiary’s personal consumption.'),
                    DropdownButtonFormField<BeneficiaryKind>(
                        isExpanded: true,
                        initialValue: _kind,
                        decoration:
                            const InputDecoration(labelText: 'Beneficiary'),
                        items: BeneficiaryKind.values
                            .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k == BeneficiaryKind.senior
                                    ? 'Senior citizen'
                                    : 'Person with disability')))
                            .toList(),
                        onChanged: _busy
                            ? null
                            : (v) => setState(() {
                                  _kind = v!;
                                  _verified = false;
                                })),
                    TextField(
                        controller: _name,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Beneficiary full name')),
                    TextField(
                        controller: _type,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Proof of entitlement / ID type')),
                    TextField(
                        controller: _id,
                        enabled: !_busy,
                        decoration:
                            const InputDecoration(labelText: 'ID number')),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'I checked valid proof of entitlement, identity and eligibility (including citizenship and senior age where applicable).'),
                        value: _verified,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _verified = v!)),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'Qualifying items are exclusively for this beneficiary’s consumption.'),
                        value: _exclusive,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _exclusive = v!)),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'The beneficiary is purchasing in person. This is not a shared, representative or bulk order.'),
                        value: _personal,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _personal = v!)),
                    if (_bnpc) ...[
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                              'Purchase booklet checked, including both booklets if also Senior and PWD. Record this purchase in the booklet after payment.'),
                          value: _booklet,
                          onChanged: _busy
                              ? null
                              : (v) => setState(() => _booklet = v!)),
                      TextField(
                          controller: _prior,
                          enabled: !_busy,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText:
                                  'Prior eligible purchases this week — PHP',
                              helperText:
                                  'Across all stores and both benefit IDs. Enter 0 if none.')),
                      TextField(
                          controller: _priorDiscount,
                          enabled: !_busy,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Prior BNPC discounts this week — PHP',
                              helperText:
                                  'Actual discounts already used, up to PHP 125. Enter 0 if none.')),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                              'At least four qualifying kinds are verified across this week’s purchases (required when using the full PHP 2,500 allowance).'),
                          value: _four,
                          onChanged:
                              _busy ? null : (v) => setState(() => _four = v!)),
                    ],
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                  ]))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _busy ? null : _apply,
                child: Text(_busy ? 'Checking…' : 'Apply benefit'))
          ]));
}
