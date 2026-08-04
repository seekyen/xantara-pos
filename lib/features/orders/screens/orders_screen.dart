import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../checkout/providers/checkout_provider.dart';
import '../../pos/fnb/providers/pos_provider.dart';
import '../providers/orders_provider.dart';
import '../../../core/auth/pos_authorization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../local/database_seed.dart';
import '../../../shared/widgets/supervisor_authorization_dialog.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Order History', style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        leading: const BackButton(color: AppColors.gray800),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('No orders yet',
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Completed orders will appear here',
                      style: AppTextStyles.caption),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.screenH),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) =>
                  _OrderCard(record: orders[index]),
            ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.record});
  final OrderRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = record.order;
    final isVoided = record.isVoided;

    final iconColor = isVoided
        ? AppColors.gray400
        : order.paymentMethod == PaymentMethod.cash
            ? AppColors.success
            : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        border: isVoided
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.rCard),
                  ),
                  child: Icon(
                    isVoided
                        ? Icons.cancel_outlined
                        : order.paymentMethod == PaymentMethod.cash
                            ? Icons.payments_outlined
                            : Icons.qr_code_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                            style: AppTextStyles.monoMd.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          if (isVoided)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.rBadgeSm),
                                border: Border.all(
                                    color:
                                        AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Text('VOIDED',
                                  style: AppTextStyles.labelSm.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error)),
                            ),
                        ],
                      ),
                      Text(
                        DateFormat('MMM d, yyyy  hh:mm a')
                            .format(order.timestamp),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${order.total.toStringAsFixed(2)}',
                      style: AppTextStyles.titleSm.copyWith(
                        fontSize: 14,
                        color: isVoided ? AppColors.gray400 : AppColors.primary,
                        decoration:
                            isVoided ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      '${order.items.length} item${order.items.length != 1 ? 's' : ''}  •  ${order.paymentMethod.label}',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSizes.sm),
            const Divider(height: 1, color: AppColors.gray100),
            const SizedBox(height: AppSizes.sm),

            // ── Items ────────────────────────────────────────────────
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('${item.quantity}×',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.gray400)),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                          child: Text(item.name,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.gray600))),
                      Text('₱${item.subtotal.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySm
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),

            if (order.paymentMethod == PaymentMethod.cash &&
                order.change != null) ...[
              const SizedBox(height: AppSizes.xs),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Change: ₱${order.change!.toStringAsFixed(2)}',
                  style: AppTextStyles.caption,
                ),
              ),
            ],

            // ── Void button ──────────────────────────────────────────
            if (!isVoided) ...[
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showVoidDialog(context, ref, order.id),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Void Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.rButton)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showVoidDialog(
      BuildContext context, WidgetRef ref, String orderId) async {
    final branchId = branchIdForCode(ref.read(activeBranchProvider));
    final supervisor = await showSupervisorAuthorizationDialog(
      context,
      title: 'Void Order',
      message: 'Voiding order #${_shortId(orderId)} requires supervisor '
          'authorization. This cannot be undone.',
      permission: PosPermission.voidInvoice,
      branchId: branchId,
    );
    if (supervisor == null || !context.mounted) return;

    final reason = await _promptVoidReason(context);
    if (reason == null || !context.mounted) return;

    try {
      await ref.read(ordersProvider.notifier).voidOrder(
            orderId,
            actorId: supervisor.id,
            reason: reason,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order voided successfully.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.rCard)),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Void failed: $error')),
      );
    }
  }

  Future<String?> _promptVoidReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reason for void'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => ElevatedButton(
              onPressed: value.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, value.text.trim()),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

String _shortId(String orderId) => orderId.length >= 8
    ? orderId.substring(0, 8).toUpperCase()
    : orderId.toUpperCase();
