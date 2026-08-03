enum PaymentProvider { cash, gcash, maya, bank, card }

enum PaymentStatus { pending, authorized, captured, failed, cancelled }

class PaymentRequest {
  const PaymentRequest({
    required this.idempotencyKey,
    required this.amountCentavos,
    required this.provider,
    required this.requestedAt,
    this.cashTenderedCentavos,
  });

  final String idempotencyKey;
  final int amountCentavos;
  final PaymentProvider provider;
  final DateTime requestedAt;
  final int? cashTenderedCentavos;
}

class PaymentEvidence {
  const PaymentEvidence({
    required this.id,
    required this.provider,
    required this.status,
    required this.amountCentavos,
    required this.reference,
    required this.authorizedAt,
    required this.isOffline,
    this.cashTenderedCentavos,
    this.changeCentavos,
  });

  final String id;
  final PaymentProvider provider;
  final PaymentStatus status;
  final int amountCentavos;
  final String reference;
  final DateTime authorizedAt;
  final bool isOffline;
  final int? cashTenderedCentavos;
  final int? changeCentavos;

  List<String> validateForInvoice(int invoiceTotalCentavos) {
    final errors = <String>[];
    if (id.trim().isEmpty) errors.add('Payment ID is required.');
    if (reference.trim().isEmpty) errors.add('Payment reference is required.');
    if (status != PaymentStatus.captured) {
      errors.add('Payment must be captured before issuing an invoice.');
    }
    if (amountCentavos != invoiceTotalCentavos) {
      errors.add('Captured payment amount must equal the invoice total.');
    }
    if (provider == PaymentProvider.cash) {
      final tendered = cashTenderedCentavos;
      if (tendered == null || tendered < invoiceTotalCentavos) {
        errors.add('Cash tendered must cover the invoice total.');
      }
      if (changeCentavos != (tendered ?? 0) - invoiceTotalCentavos) {
        errors.add('Cash change is inconsistent with the amount tendered.');
      }
    } else {
      if (isOffline) {
        errors.add('Electronic gateway evidence cannot be marked offline.');
      }
      if (cashTenderedCentavos != null || changeCentavos != null) {
        errors.add('Electronic payments cannot contain cash tender details.');
      }
    }
    return errors;
  }
}

abstract interface class PaymentGateway {
  PaymentProvider get provider;
  bool get requiresInternet;

  Future<PaymentEvidence> capture(PaymentRequest request);
}

class CashPaymentGateway implements PaymentGateway {
  const CashPaymentGateway({required this.createEvidenceId});

  final String Function() createEvidenceId;

  @override
  PaymentProvider get provider => PaymentProvider.cash;

  @override
  bool get requiresInternet => false;

  @override
  Future<PaymentEvidence> capture(PaymentRequest request) async {
    if (request.provider != provider) {
      throw ArgumentError('Cash gateway received a non-cash request.');
    }
    if (request.amountCentavos <= 0) {
      throw ArgumentError.value(request.amountCentavos, 'amountCentavos');
    }
    final tendered = request.cashTenderedCentavos;
    if (tendered == null || tendered < request.amountCentavos) {
      throw const PaymentDeclinedException('Insufficient cash tendered.');
    }
    final evidenceId = createEvidenceId();
    if (evidenceId.trim().isEmpty) {
      throw StateError('Cash evidence ID generator returned an empty value.');
    }
    return PaymentEvidence(
      id: evidenceId,
      provider: provider,
      status: PaymentStatus.captured,
      amountCentavos: request.amountCentavos,
      reference: 'CASH-$evidenceId',
      authorizedAt: request.requestedAt,
      isOffline: true,
      cashTenderedCentavos: tendered,
      changeCentavos: tendered - request.amountCentavos,
    );
  }
}

class PaymentCoordinator {
  PaymentCoordinator(Iterable<PaymentGateway> gateways)
      : _gateways = {
          for (final gateway in gateways) gateway.provider: gateway,
        };

  final Map<PaymentProvider, PaymentGateway> _gateways;

  Future<PaymentEvidence> capture(
    PaymentRequest request, {
    required bool isOnline,
  }) async {
    final gateway = _gateways[request.provider];
    if (gateway == null) {
      throw PaymentConfigurationException(
        'No ${request.provider.name} gateway is configured.',
      );
    }
    if (gateway.requiresInternet && !isOnline) {
      throw PaymentConnectivityException(
        '${request.provider.name} requires an internet connection.',
      );
    }
    final evidence = await gateway.capture(request);
    final errors = evidence.validateForInvoice(request.amountCentavos);
    if (errors.isNotEmpty) throw PaymentEvidenceException(errors);
    return evidence;
  }
}

class PaymentConfigurationException implements Exception {
  const PaymentConfigurationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentConnectivityException implements Exception {
  const PaymentConnectivityException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentDeclinedException implements Exception {
  const PaymentDeclinedException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentEvidenceException implements Exception {
  const PaymentEvidenceException(this.errors);
  final List<String> errors;
  @override
  String toString() => errors.join(' ');
}
