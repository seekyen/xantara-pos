import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/payments/payment.dart';

void main() {
  test('cash capture works fully offline and calculates change', () async {
    var sequence = 0;
    final coordinator = PaymentCoordinator([
      CashPaymentGateway(createEvidenceId: () => 'cash-${++sequence}'),
    ]);

    final evidence = await coordinator.capture(
      PaymentRequest(
        idempotencyKey: 'sale-1',
        amountCentavos: 12500,
        provider: PaymentProvider.cash,
        requestedAt: DateTime(2026, 7, 11),
        cashTenderedCentavos: 15000,
      ),
      isOnline: false,
    );

    expect(evidence.status, PaymentStatus.captured);
    expect(evidence.isOffline, isTrue);
    expect(evidence.changeCentavos, 2500);
    expect(evidence.reference, 'CASH-cash-1');
  });

  test('cash capture rejects an insufficient tender', () async {
    final coordinator = PaymentCoordinator([
      CashPaymentGateway(createEvidenceId: () => 'cash-1'),
    ]);

    expect(
      () => coordinator.capture(
        PaymentRequest(
          idempotencyKey: 'sale-1',
          amountCentavos: 12500,
          provider: PaymentProvider.cash,
          requestedAt: DateTime(2026, 7, 11),
          cashTenderedCentavos: 10000,
        ),
        isOnline: false,
      ),
      throwsA(isA<PaymentDeclinedException>()),
    );
  });

  test('electronic gateways cannot run while offline', () async {
    final coordinator = PaymentCoordinator([
      const _FakeOnlineGateway(PaymentProvider.gcash),
    ]);

    expect(
      () => coordinator.capture(
        PaymentRequest(
          idempotencyKey: 'sale-2',
          amountCentavos: 50000,
          provider: PaymentProvider.gcash,
          requestedAt: DateTime(2026, 7, 11),
        ),
        isOnline: false,
      ),
      throwsA(isA<PaymentConnectivityException>()),
    );
  });

  test('unconfigured providers fail instead of simulating payment', () async {
    final coordinator = PaymentCoordinator(const []);

    expect(
      () => coordinator.capture(
        PaymentRequest(
          idempotencyKey: 'sale-3',
          amountCentavos: 50000,
          provider: PaymentProvider.maya,
          requestedAt: DateTime(2026, 7, 11),
        ),
        isOnline: true,
      ),
      throwsA(isA<PaymentConfigurationException>()),
    );
  });
}

class _FakeOnlineGateway implements PaymentGateway {
  const _FakeOnlineGateway(this.provider);

  @override
  final PaymentProvider provider;

  @override
  bool get requiresInternet => true;

  @override
  Future<PaymentEvidence> capture(PaymentRequest request) async {
    return PaymentEvidence(
      id: 'gateway-payment',
      provider: provider,
      status: PaymentStatus.captured,
      amountCentavos: request.amountCentavos,
      reference: 'gateway-reference',
      authorizedAt: request.requestedAt,
      isOffline: false,
    );
  }
}
