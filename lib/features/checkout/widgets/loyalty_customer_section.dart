import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/loyalty/loyalty_points.dart';
import '../../../local/database.dart';
import '../../../local/database_providers.dart';
import '../providers/loyalty_provider.dart';

/// Optional "loyalty customer" row of the cart: attach a customer downloaded from Xantara Cloud
/// and see roughly how many points this sale earns. The estimate is only a guide; the cloud
/// awards the real points when the invoice syncs.
class LoyaltyCustomerSection extends ConsumerWidget {
  const LoyaltyCustomerSection({
    super.key,
    required this.total,
    required this.vat,
  });

  final double total;
  final double vat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(selectedLoyaltyCustomerProvider);
    final rules = ref.watch(loyaltyRulesProvider).maybeWhen(
          data: (rules) => rules,
          orElse: () => const <LoyaltyPromoRule>[],
        );

    Widget body;
    if (customer == null) {
      body = InkWell(
        borderRadius: BorderRadius.circular(AppSizes.rCard),
        onTap: () => showLoyaltyCustomerPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg, vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.rCard),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(children: [
            const Icon(Icons.person_add_alt_1_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text('Add customer for loyalty points',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.primary)),
            ),
          ]),
        ),
      );
    } else {
      final estimate = estimateLoyaltyPoints(
        netCentavos: ((total - vat) * 100).round(),
        issuedAt: DateTime.now(),
        promos: rules,
      );
      body = Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
        ),
        child: Row(children: [
          const Icon(Icons.stars_rounded, size: 22, color: AppColors.primary),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTextStyles.labelMd),
                Text(
                  [
                    if (customer.phone.isNotEmpty) customer.phone,
                    '${customer.points} pts',
                  ].join(' · '),
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 2),
                Text(
                  estimate.points > 0
                      ? 'Earns about ${estimate.points} pts on this sale · ${estimate.promoName}'
                      : 'No points promo is running for this sale',
                  style: AppTextStyles.bodySm.copyWith(
                    color: estimate.points > 0
                        ? AppColors.success
                        : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove customer',
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.gray600),
            onPressed: () =>
                ref.read(selectedLoyaltyCustomerProvider.notifier).state = null,
          ),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LOYALTY', style: AppTextStyles.labelCaps),
        const SizedBox(height: AppSizes.sm),
        body,
      ],
    );
  }
}

Future<void> showLoyaltyCustomerPicker(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _LoyaltyCustomerPicker(),
  );
}

class _LoyaltyCustomerPicker extends ConsumerStatefulWidget {
  const _LoyaltyCustomerPicker();

  @override
  ConsumerState<_LoyaltyCustomerPicker> createState() =>
      _LoyaltyCustomerPickerState();
}

class _LoyaltyCustomerPickerState
    extends ConsumerState<_LoyaltyCustomerPicker> {
  final _query = TextEditingController();
  List<LoyaltyCustomer> _results = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String text) async {
    final rows =
        await ref.read(loyaltyRepositoryProvider).searchCustomers(text);
    if (!mounted || text != _query.text) return;
    setState(() {
      _results = rows;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searching = _query.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Select customer'),
      content: SizedBox(
        width: 420,
        height: 380,
        child: Column(children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search name or phone…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: !_loaded
                ? const SizedBox.shrink()
                : _results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Text(
                            searching
                                ? 'No matching customer.'
                                : 'No customers on this device yet. Sync with Xantara Cloud in Settings to download them.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final customer = _results[index];
                          return ListTile(
                            title: Text(customer.name),
                            subtitle: Text(customer.phone.isEmpty
                                ? 'No phone'
                                : customer.phone),
                            trailing: Text('${customer.points} pts',
                                style: AppTextStyles.labelMd),
                            onTap: () {
                              ref
                                  .read(selectedLoyaltyCustomerProvider.notifier)
                                  .state = customer;
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ],
    );
  }
}
