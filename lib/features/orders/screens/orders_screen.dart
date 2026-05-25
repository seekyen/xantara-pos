import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/providers/checkout_provider.dart';
import '../providers/orders_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

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
        title: const Text('Order History',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.gray800)),
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
                      borderRadius:
                          BorderRadius.circular(AppSizes.rCard),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text('No orders yet',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800)),
                  const SizedBox(height: 4),
                  const Text('Completed orders will appear here',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.gray400)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.screenH),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.sm),
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
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role == 'admin';

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
            ? Border.all(
                color: AppColors.error.withValues(alpha: 0.3))
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
                    borderRadius:
                        BorderRadius.circular(AppSizes.rCard),
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
                            style: GoogleFonts.dmMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray800),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          if (isVoided)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.rBadgeSm),
                                border: Border.all(
                                    color: AppColors.error
                                        .withValues(alpha: 0.3)),
                              ),
                              child: const Text('VOIDED',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      Text(
                        DateFormat('MMM d, yyyy  hh:mm a')
                            .format(order.timestamp),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray400),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isVoided
                            ? AppColors.gray400
                            : AppColors.primary,
                        decoration: isVoided
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${order.items.length} item${order.items.length != 1 ? 's' : ''}  •  ${order.paymentMethod == PaymentMethod.cash ? 'Cash' : 'QRPh'}',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.gray400),
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
                          style: const TextStyle(
                              color: AppColors.gray400,
                              fontSize: 12)),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                          child: Text(item.name,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray600))),
                      Text('₱${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray800)),
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
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.gray400),
                ),
              ),
            ],

            // ── Void button ──────────────────────────────────────────
            if (!isVoided) ...[
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showVoidDialog(context, ref, order.id, isAdmin),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Void Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.sm),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.rButton)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showVoidDialog(
      BuildContext context, WidgetRef ref, String orderId, bool isAdmin) {
    showDialog(
      context: context,
      builder: (_) =>
          _VoidDialog(orderId: orderId, isAdmin: isAdmin, ref: ref),
    );
  }
}

// ── Void dialog ───────────────────────────────────────────────────────────────

class _VoidDialog extends StatefulWidget {
  const _VoidDialog({
    required this.orderId,
    required this.isAdmin,
    required this.ref,
  });
  final String orderId;
  final bool isAdmin;
  final WidgetRef ref;

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  final _codeController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_codeController.text != voidPermissionCode) {
      setState(() => _error = 'Incorrect permission code. Try again.');
      return;
    }
    widget.ref.read(ordersProvider.notifier).voidOrder(widget.orderId);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order voided successfully.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.rCard)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortId = widget.orderId.length >= 8
        ? widget.orderId.substring(0, 8).toUpperCase()
        : widget.orderId.toUpperCase();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error, size: 22),
          SizedBox(width: AppSizes.sm),
          Text('Void Order'),
        ],
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action requires supervisor permission.',
            style: TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
          const SizedBox(height: AppSizes.lg),
          TextField(
            controller: _codeController,
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Permission Code',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppSizes.rCard),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: AppSizes.xs),
                Expanded(
                  child: Text(
                    'Voiding cannot be undone. Order #$shortId will be marked as void.',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSizes.rButton)),
          ),
          child: const Text('Void Order'),
        ),
      ],
    );
  }
}
