import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/compliance/bir_invoice.dart';
import '../../../../core/hardware/pos_hardware.dart';
import '../../../../core/payments/payment.dart';
import '../../../../local/database_providers.dart';
import '../../../../local/database_seed.dart';
import '../../../../local/repositories/company_registration_repository.dart';
import '../../../../local/repositories/offline_sale_repository.dart';
import '../../../checkout/providers/checkout_provider.dart';
import 'grocery_cart_provider.dart';
import '../../../../core/pricing/commercial_discounts.dart';
import '../../../../core/pricing/statutory_discount.dart';
import '../../../../local/repositories/statutory_discount_repository.dart';

final groceryCheckoutProvider = Provider(
    (ref) => GroceryCheckout(ref.watch(offlineSaleRepositoryProvider)));

/// A checkout attempt owns an immutable basket and never performs fallible
/// hardware work after the database commit. UI retries cannot duplicate an
/// in-flight attempt; failure leaves the basket untouched.
class GroceryCheckout {
  GroceryCheckout(this.sales);
  final OfflineSaleRepository sales;
  Future<ReceiptPrintData>? _pending;

  Future<ReceiptPrintData> submit(
      {required List<GroceryCartItem> items,
      required String branchCode,
      required String actorId,
      required int tenderedCentavos,
      required GroceryPaymentMethod method,
      BirBuyerDetails? buyer,
      StatutoryClaim? statutoryClaim,
      GroceryCoupon? coupon,
      GroceryDiscountKind? discountKind,
      String customDiscount = '',
      GroceryDiscountUnit unit = GroceryDiscountUnit.percent}) {
    if (_pending != null) return _pending!;
    final task = _save(
        items: List.of(items),
        branchCode: branchCode,
        actorId: actorId,
        tenderedCentavos: tenderedCentavos,
        method: method,
        buyer: buyer,
        statutoryClaim: statutoryClaim,
        coupon: coupon,
        discountKind: discountKind,
        customDiscount: customDiscount,
        unit: unit);
    _pending = task;
    return task.whenComplete(() => _pending = null);
  }

  Future<ReceiptPrintData> _save(
      {required List<GroceryCartItem> items,
      required String branchCode,
      required String actorId,
      required int tenderedCentavos,
      required GroceryPaymentMethod method,
      required BirBuyerDetails? buyer,
      required StatutoryClaim? statutoryClaim,
      required GroceryCoupon? coupon,
      required GroceryDiscountKind? discountKind,
      required String customDiscount,
      required GroceryDiscountUnit unit}) async {
    if (method != GroceryPaymentMethod.cash) {
      throw StateError(
          'Only cash is available until a payment gateway is configured.');
    }
    if (discountKind == GroceryDiscountKind.seniorPwd &&
        statutoryClaim == null) {
      throw StateError('Enter beneficiary evidence in the payment dialog.');
    }
    if (items.isEmpty ||
        items.any((i) =>
            i.quantity <= 0 ||
            !i.product.price.isFinite ||
            i.product.price < 0)) {
      throw StateError('Add valid items before checkout.');
    }
    final registration =
        await CompanyRegistrationRepository(sales.database).read();
    if (registration != null && coupon != null) {
      throw StateError(
          'Demo coupons cannot be used for registered company sales.');
    }
    final actor = await (sales.database.select(sales.database.staffUsers)
          ..where((u) => u.id.equals(actorId)))
        .getSingleOrNull();
    if (actor == null || !actor.isActive) {
      throw StateError('Sign in to complete the sale.');
    }
    final subtotal = grocerySubtotalCentavos(items);
    final couponAmount = groceryCouponCentavos(subtotal, coupon);
    final base = subtotal - couponAmount;
    final discount = couponAmount +
        (discountKind == GroceryDiscountKind.custom
            ? commercialDiscountAmount(base, customDiscount,
                percentage: unit == GroceryDiscountUnit.percent)
            : 0);
    if (statutoryClaim != null &&
        (discount > 0 ||
            coupon != null ||
            discountKind == GroceryDiscountKind.custom)) {
      throw StateError(
          'Statutory benefits cannot be combined with another discount.');
    }
    final quote = statutoryClaim == null
        ? null
        : await StatutoryDiscountRepository(sales.database).preview(
            claim: statutoryClaim,
            quantities: {for (final i in items) i.product.id: i.quantity},
            checkoutType: 'retail');
    final total = quote?.totalCentavos ?? subtotal - discount;
    if (total <= 0) throw StateError('The total must be greater than zero.');
    final now = DateTime.now();
    final payment =
        await CashPaymentGateway(createEvidenceId: () => const Uuid().v4())
            .capture(PaymentRequest(
                idempotencyKey: const Uuid().v4(),
                amountCentavos: total,
                provider: PaymentProvider.cash,
                requestedAt: now,
                cashTenderedCentavos: tenderedCentavos));
    final allocations = allocateCommercialDiscount({
      for (final i in items)
        i.product.id: (i.product.price * 100).round() * i.quantity
    }, discount);
    final lines = items.map((i) {
      final price = (i.product.price * 100).round();
      return OfflineSaleLineRequest(
          productId: i.product.id,
          quantity: i.quantity,
          discountCentavos: allocations[i.product.id]!,
          expectedUnitPriceCentavos: price);
    }).toList();
    final branchId = branchIdForCode(branchCode);
    final invoice = await sales.issueSale(OfflineSaleRequest(
        checkoutType: 'retail',
        demoPromotionCode: coupon?.code,
        branchId: branchId,
        terminalId: registration?.terminalId ?? terminalIdForBranch(branchId),
        actorId: actorId,
        issuedAt: now,
        payment: payment,
        sellerName: trainingMerchantProfile.registeredName,
        sellerTin: trainingMerchantProfile.tin,
        sellerAddress: trainingMerchantProfile.registeredAddress,
        registrationType: trainingMerchantProfile.registrationType,
        softwareName: trainingMerchantProfile.softwareName,
        softwareVersion: trainingMerchantProfile.softwareVersion,
        buyer: buyer,
        statutoryClaim: statutoryClaim,
        lines: lines));
    return ReceiptPrintData(
        invoice: invoice,
        payment: payment,
        cashierName: actor.displayName,
        isReprint: false);
  }
}
