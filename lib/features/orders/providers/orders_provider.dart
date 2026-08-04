import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkout/providers/checkout_provider.dart';
import '../../pos/fnb/providers/pos_provider.dart';
import '../../../core/compliance/bir_invoice.dart';
import '../../../core/payments/payment.dart';
import '../../../local/database_providers.dart';
import '../../../local/database_seed.dart';
import '../../../local/repositories/invoice_assembler.dart';
import '../../../local/repositories/offline_sale_repository.dart';

class OrderRecord {
  final Order order;
  final bool isVoided;

  const OrderRecord({required this.order, this.isVoided = false});
}

/// Branch-scoped order history, backed by [OfflineSaleRepository.watchSales]
/// (Drift). Reactively re-subscribes whenever the active branch changes;
/// voiding an invoice updates the list automatically once the underlying
/// row changes, no manual state mutation needed.
class OrdersNotifier extends StateNotifier<List<OrderRecord>> {
  OrdersNotifier(this._repository, this._branchId) : super(const []) {
    _subscription =
        _repository.watchSales(branchId: _branchId).listen((sales) {
      state = sales.map(_toOrderRecord).toList(growable: false);
    });
  }

  final OfflineSaleRepository _repository;
  final String _branchId;
  late final StreamSubscription<List<SaleRecord>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> voidOrder(
    String orderId, {
    required String actorId,
    required String reason,
  }) {
    return _repository.voidInvoice(VoidInvoiceRequest(
      invoiceId: orderId,
      actorId: actorId,
      reason: reason,
      voidedAt: DateTime.now(),
    ));
  }
}

OrderRecord _toOrderRecord(SaleRecord sale) {
  final invoice = sale.invoice;
  final payment = sale.payment;
  return OrderRecord(
    isVoided: invoice.status == InvoiceStatus.voided,
    order: Order(
      id: invoice.id,
      items: invoice.lines
          .map((line) => OrderItem(
                name: line.description,
                price: line.unitPriceCentavos / 100,
                quantity: line.quantity,
                subtotal: line.netCentavos / 100,
              ))
          .toList(growable: false),
      total: invoice.totalCentavos / 100,
      paymentMethod: _paymentMethodFor(payment.provider),
      paymentReference: invoice.paymentReference,
      cashReceived: payment.cashTenderedCentavos == null
          ? null
          : payment.cashTenderedCentavos! / 100,
      change: payment.changeCentavos == null
          ? null
          : payment.changeCentavos! / 100,
      timestamp: invoice.issuedAt,
      birReceipt: birReceiptFromInvoice(invoice),
    ),
  );
}

PaymentMethod _paymentMethodFor(PaymentProvider provider) => switch (provider) {
      PaymentProvider.cash => PaymentMethod.cash,
      PaymentProvider.gcash => PaymentMethod.gcash,
      PaymentProvider.maya => PaymentMethod.maya,
      PaymentProvider.bank => PaymentMethod.bank,
      PaymentProvider.card => PaymentMethod.card,
    };

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderRecord>>(
  (ref) => OrdersNotifier(
    ref.watch(offlineSaleRepositoryProvider),
    branchIdForCode(ref.watch(activeBranchProvider)),
  ),
);
