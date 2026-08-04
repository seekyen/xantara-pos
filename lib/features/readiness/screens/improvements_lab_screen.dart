import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../pos/fnb/providers/pos_provider.dart';

final _offlineTestProvider = StateProvider<bool>((ref) => true);
final _premiumProvider = StateProvider<bool>((ref) => false);
final _paymentProvider = StateProvider<String>((ref) => 'Cash');

class ImprovementsLabScreen extends ConsumerWidget {
  const ImprovementsLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(_offlineTestProvider);
    final premium = ref.watch(_premiumProvider);
    final branch = ref.watch(activeBranchProvider);
    final payment = ref.watch(_paymentProvider);
    final products = ref.watch(productsProvider);
    final lowStock = products.where((item) => item.stock <= 10).length;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Improvements Lab'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Notice(offline: offline),
          const SizedBox(height: 16),
          _Section(
            title: 'Offline-first operation',
            icon: Icons.wifi_off_rounded,
            status: offline ? 'OFFLINE TEST ACTIVE' : 'ONLINE',
            statusColor: offline ? AppColors.warning : AppColors.success,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate no internet'),
              subtitle: Text(offline
                  ? 'Sales must remain local and queue for later sync.'
                  : 'Online services may be reached when configured.'),
              value: offline,
              onChanged: (value) =>
                  ref.read(_offlineTestProvider.notifier).state = value,
            ),
          ),
          const _Section(
            title: 'BIR transaction controls',
            icon: Icons.receipt_long_outlined,
            status: 'FOUNDATION VERIFIED',
            statusColor: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Check('Sequential invoice numbers per terminal'),
                _Check('VAT, zero-rated, exempt and non-VAT totals'),
                _Check('Void trail preserves the original transaction'),
                _Check('Seller, terminal, MIN, PTU and serial fields'),
              ],
            ),
          ),
          _Section(
            title: 'Branch inventory',
            icon: Icons.store_mall_directory_outlined,
            status: '$lowStock LOW-STOCK ITEM${lowStock == 1 ? '' : 'S'}',
            statusColor: lowStock == 0 ? AppColors.success : AppColors.warning,
            child: DropdownButtonFormField<String>(
              initialValue: branch,
              decoration: const InputDecoration(labelText: 'Viewing branch'),
              items: retailBranches
                  .map((item) => DropdownMenuItem(
                      value: item.code, child: Text(item.name)))
                  .toList(),
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(activeBranchProvider.notifier).select(value);
                }
              },
            ),
          ),
          _Section(
            title: 'Premium record sync',
            icon: Icons.cloud_sync_outlined,
            status: premium ? 'PREMIUM ENABLED' : 'LOCAL ONLY',
            statusColor: premium ? AppColors.primary : AppColors.gray600,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Premium account simulation'),
              subtitle: Text(premium
                  ? offline
                      ? 'Records are queued until connectivity returns.'
                      : 'Queued records are eligible for secure sync.'
                  : 'Business records remain on this device.'),
              value: premium,
              onChanged: (value) =>
                  ref.read(_premiumProvider.notifier).state = value,
            ),
          ),
          _Section(
            title: 'Payments',
            icon: Icons.payments_outlined,
            status: payment.toUpperCase(),
            statusColor: AppColors.primary,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Cash', 'GCash', 'Maya', 'Bank']
                  .map((method) => ChoiceChip(
                        label: Text(method),
                        selected: payment == method,
                        onSelected: (_) =>
                            ref.read(_paymentProvider.notifier).state = method,
                      ))
                  .toList(),
            ),
          ),
          const _Section(
            title: 'Supplier and hardware readiness',
            icon: Icons.settings_input_component_outlined,
            status: 'CONTROLLED INTEGRATIONS',
            statusColor: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Check('Low-stock supplier alerts use approved subscriptions'),
                _Check('Receipt print jobs are queued and retryable'),
                _Check('Cash drawer opens only for authorized sale jobs'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GCash, Maya, bank, cloud, supplier and hardware actions on this page are safe simulations until production credentials and devices are configured.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.offline});
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(offline ? Icons.cloud_off : Icons.cloud_done,
              color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              offline
                  ? 'You can test the POS without internet. Premium sync will queue records.'
                  : 'Connectivity simulation is active. External services still require configuration.',
              style: AppTextStyles.bodyLg.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.status,
    required this.statusColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String status;
  final Color statusColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: AppTextStyles.titleSm),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: AppTextStyles.labelSm.copyWith(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
        ],
      ),
    );
  }
}
