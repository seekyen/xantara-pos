import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../features/checkout/providers/checkout_provider.dart';
import '../customer_display_bridge.dart';
import '../providers/customer_display_providers.dart';

// CUSTOMER_DISPLAY — customer selects payment method.
// Tapping a card immediately sends the selection to the cashier window,
// which auto-updates the checkout screen's selected payment method.
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  // Main window (cashier POS) is always ID 0 in desktop_multi_window.
  static const _cashierWindowId = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDisplayStateProvider);
    final selected = state.selectedPaymentMethod;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          // CUSTOMER_DISPLAY — branded header with total
          _PaymentHeader(total: state.total),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount due — prominent, large text for readability
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xl, vertical: AppSizes.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSizes.rCard),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Amount Due',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '₱${state.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  const Text(
                    'How would you like to pay?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // CUSTOMER_DISPLAY — large touch-friendly payment method cards
                  _PaymentCard(
                    icon: Icons.credit_card_rounded,
                    label: 'Credit / Debit Card',
                    subtitle: 'Tap, insert, or swipe',
                    selected: selected == PaymentMethod.card,
                    onTap: () => _select(ref, PaymentMethod.card),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _PaymentCard(
                    icon: Icons.payments_rounded,
                    label: 'Cash',
                    subtitle: 'Pay with bills or coins',
                    selected: selected == PaymentMethod.cash,
                    onTap: () => _select(ref, PaymentMethod.cash),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _PaymentCard(
                    icon: Icons.qr_code_rounded,
                    label: 'GCash / Maya / QRPh',
                    subtitle: 'Scan QR code to pay',
                    selected: selected == PaymentMethod.qrph,
                    onTap: () => _select(ref, PaymentMethod.qrph),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  const Text(
                    'Your cashier will complete the transaction after your selection.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(WidgetRef ref, PaymentMethod method) {
    // Update local customer display state
    ref.read(customerDisplayStateProvider).selectPaymentMethod(method);
    // Immediately send selection back to cashier window
    CustomerDisplayBridge.replySelectPaymentMethod(_cashierWindowId, method)
        .ignore();
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl, vertical: AppSizes.lg + 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Image.asset(
              'assets/images/xantara-logo.png',
              height: 28,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            const Expanded(
              child: Text(
                'Select Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.rPill),
              ),
              child: Text(
                '₱${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment method card ─────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // CUSTOMER_DISPLAY — min 80px height, touch-friendly, animated selection
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl, vertical: AppSizes.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.rCard),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.gray200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [] : AppShadows.sm,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppSizes.rCard),
              ),
              child: Icon(
                icon,
                size: 28,
                color: selected ? Colors.white : AppColors.gray600,
              ),
            ),
            const SizedBox(width: AppSizes.lg),

            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.primary : AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),

            // Selected checkmark
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
