import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/compliance/bir_invoice.dart' as bir;
import '../../core/hardware/pos_hardware.dart';
import '../../core/payments/payment.dart';
import '../database.dart';
import 'audit_trail_repository.dart';
import 'invoice_assembler.dart';

class OfflineSaleLineRequest {
  const OfflineSaleLineRequest({
    required this.productId,
    required this.quantity,
    this.discountCentavos = 0,
  });

  final String productId;
  final int quantity;
  final int discountCentavos;
}

class OfflineSaleRequest {
  const OfflineSaleRequest({
    required this.branchId,
    required this.terminalId,
    required this.actorId,
    required this.issuedAt,
    required this.payment,
    required this.sellerName,
    required this.sellerTin,
    required this.sellerAddress,
    required this.registrationType,
    required this.softwareName,
    required this.softwareVersion,
    required this.lines,
    this.buyer,
    this.printReceipt = true,
    this.openCashDrawer = true,
  });

  final String branchId;
  final String terminalId;
  final String actorId;
  final DateTime issuedAt;
  final PaymentEvidence payment;
  final String sellerName;
  final String sellerTin;
  final String sellerAddress;
  final bir.TaxRegistrationType registrationType;
  final String softwareName;
  final String softwareVersion;
  final List<OfflineSaleLineRequest> lines;
  final bir.BirBuyerDetails? buyer;
  final bool printReceipt;
  final bool openCashDrawer;
}

class VoidInvoiceRequest {
  const VoidInvoiceRequest({
    required this.invoiceId,
    required this.actorId,
    required this.reason,
    required this.voidedAt,
  });

  final String invoiceId;
  final String actorId;
  final String reason;
  final DateTime voidedAt;
}

class OfflineSaleRepository {
  OfflineSaleRepository(
    this.database, {
    Uuid uuid = const Uuid(),
    bir.BirInvoiceIssuer issuer = const bir.BirInvoiceIssuer(),
  })  : _uuid = uuid,
        _issuer = issuer,
        _audit = AuditTrailRepository(database, uuid: uuid);

  final AppDatabase database;
  final Uuid _uuid;
  final bir.BirInvoiceIssuer _issuer;
  final AuditTrailRepository _audit;

  /// Atomically commits the invoice, serial, stock, audit trail, and sync event.
  /// The outbox event is written for every sale but is uploaded only for a
  /// customer with Premium sync enabled.
  Future<bir.BirInvoice> issueSale(OfflineSaleRequest request) {
    return database.transaction(() async {
      final branch = await (database.select(database.branches)
            ..where((row) => row.id.equals(request.branchId)))
          .getSingleOrNull();
      if (branch == null || !branch.isActive) {
        throw StateError('The selected branch is missing or inactive.');
      }

      final terminal = await (database.select(database.terminals)
            ..where((row) => row.id.equals(request.terminalId)))
          .getSingleOrNull();
      if (terminal == null ||
          !terminal.isActive ||
          terminal.branchId != branch.id) {
        throw StateError('The selected terminal is not active in this branch.');
      }

      final storedSequence = await (database.select(database.invoiceSequences)
            ..where((row) => row.terminalId.equals(terminal.id)))
          .getSingleOrNull();
      if (storedSequence == null) {
        throw StateError('The terminal invoice sequence is not configured.');
      }

      final productRows = <String, Product>{};
      final inventoryRows = <String, BranchInventory>{};
      final invoiceLines = <bir.BirInvoiceLine>[];
      for (final requestedLine in request.lines) {
        if (requestedLine.quantity <= 0) {
          throw ArgumentError.value(
            requestedLine.quantity,
            'quantity',
            'Quantity must be greater than zero.',
          );
        }
        if (productRows.containsKey(requestedLine.productId)) {
          throw ArgumentError(
            'Duplicate product lines must be combined before checkout.',
          );
        }

        final product = await (database.select(database.products)
              ..where((row) => row.id.equals(requestedLine.productId)))
            .getSingleOrNull();
        if (product == null || !product.isActive) {
          throw StateError('A sale item is missing or inactive.');
        }
        final inventory = await (database.select(database.branchInventories)
              ..where(
                (row) =>
                    row.branchId.equals(branch.id) &
                    row.productId.equals(product.id),
              ))
            .getSingleOrNull();
        if (inventory == null) {
          throw StateError(
              '${product.name} has no inventory record at this branch.');
        }
        if (inventory.stockOnHand < requestedLine.quantity) {
          throw StateError('Insufficient stock for ${product.name}.');
        }

        final taxCategory = bir.TaxCategory.values
            .where((value) => value.name == product.taxCategory)
            .firstOrNull;
        if (taxCategory == null) {
          throw StateError('Invalid tax category for ${product.name}.');
        }
        productRows[product.id] = product;
        inventoryRows[product.id] = inventory;
        invoiceLines.add(
          bir.BirInvoiceLine(
            productId: product.id,
            description: product.name,
            quantity: requestedLine.quantity,
            unitPriceCentavos: product.unitPriceCentavos,
            discountCentavos: requestedLine.discountCentavos,
            taxCategory: taxCategory,
          ),
        );
      }

      final sequence = bir.BirInvoiceSequence(
        branchCode: branch.code,
        terminalCode: terminal.code,
        nextSequence: storedSequence.nextValue,
      );
      final invoiceId = _uuid.v4();
      final invoice = _issuer.issue(
        id: invoiceId,
        issuedAt: request.issuedAt,
        seller: bir.BirSellerProfile(
          registeredName: request.sellerName,
          tin: request.sellerTin,
          branchCode: branch.code,
          registeredAddress: request.sellerAddress,
          registrationType: request.registrationType,
          machineIdentificationNumber: terminal.machineIdentificationNumber,
          permitToUseNumber: terminal.permitToUseNumber,
          machineSerialNumber: terminal.machineSerialNumber,
          softwareName: request.softwareName,
          softwareVersion: request.softwareVersion,
        ),
        buyer: request.buyer,
        lines: invoiceLines,
        sequence: sequence,
        paymentReference: request.payment.reference,
      );
      final paymentErrors =
          request.payment.validateForInvoice(invoice.totalCentavos);
      if (paymentErrors.isNotEmpty) {
        throw PaymentEvidenceException(paymentErrors);
      }

      await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              id: invoice.id,
              invoiceNumber: invoice.invoiceNumber,
              branchId: branch.id,
              terminalId: terminal.id,
              issuedAt: invoice.issuedAt,
              status: invoice.status.name,
              paymentMethod: request.payment.provider.name,
              paymentReference: invoice.paymentReference,
              totalCentavos: invoice.totalCentavos,
              vatableSalesCentavos: invoice.taxSummary.vatableSalesCentavos,
              vatAmountCentavos: invoice.taxSummary.vatAmountCentavos,
              zeroRatedSalesCentavos: invoice.taxSummary.zeroRatedSalesCentavos,
              vatExemptSalesCentavos: invoice.taxSummary.vatExemptSalesCentavos,
              nonVatSalesCentavos: invoice.taxSummary.nonVatSalesCentavos,
              sellerName: invoice.seller.registeredName,
              sellerTin: invoice.seller.tin,
              sellerAddress: invoice.seller.registeredAddress,
              sellerRegistrationType: invoice.seller.registrationType.name,
              branchCode: invoice.seller.branchCode,
              machineIdentificationNumber:
                  invoice.seller.machineIdentificationNumber,
              permitToUseNumber: invoice.seller.permitToUseNumber,
              machineSerialNumber: invoice.seller.machineSerialNumber,
              softwareName: invoice.seller.softwareName,
              softwareVersion: invoice.seller.softwareVersion,
              buyerName: Value(invoice.buyer?.registeredName),
              buyerTin: Value(invoice.buyer?.tin),
              buyerAddress: Value(invoice.buyer?.address),
            ),
          );

      await database.into(database.payments).insert(
            PaymentsCompanion.insert(
              id: request.payment.id,
              invoiceId: invoice.id,
              provider: request.payment.provider.name,
              status: request.payment.status.name,
              amountCentavos: request.payment.amountCentavos,
              reference: request.payment.reference,
              authorizedAt: request.payment.authorizedAt,
              isOffline: request.payment.isOffline,
              cashTenderedCentavos: Value(request.payment.cashTenderedCentavos),
              changeCentavos: Value(request.payment.changeCentavos),
            ),
          );

      for (var index = 0; index < invoice.lines.length; index++) {
        final line = invoice.lines[index];
        await database.into(database.invoiceLines).insert(
              InvoiceLinesCompanion.insert(
                id: _uuid.v4(),
                invoiceId: invoice.id,
                productId: line.productId,
                description: line.description,
                quantity: line.quantity,
                unitPriceCentavos: line.unitPriceCentavos,
                discountCentavos: line.discountCentavos,
                taxCategory: line.taxCategory.name,
                lineTotalCentavos: line.netCentavos,
              ),
            );

        final inventory = inventoryRows[line.productId]!;
        final newBalance = inventory.stockOnHand - line.quantity;
        await (database.update(database.branchInventories)
              ..where(
                (row) =>
                    row.branchId.equals(branch.id) &
                    row.productId.equals(line.productId),
              ))
            .write(
          BranchInventoriesCompanion(
            stockOnHand: Value(newBalance),
            version: Value(inventory.version + 1),
            updatedAt: Value(request.issuedAt),
          ),
        );
        await database.into(database.inventoryMovements).insert(
              InventoryMovementsCompanion.insert(
                id: _uuid.v4(),
                branchId: branch.id,
                productId: line.productId,
                type: 'sale',
                quantityDelta: -line.quantity,
                balanceAfter: newBalance,
                referenceType: 'invoice',
                referenceId: invoice.id,
                occurredAt: request.issuedAt,
              ),
            );
        if (newBalance <= inventory.reorderPoint) {
          final lowStockPayload = jsonEncode({
            'branchId': branch.id,
            'productId': line.productId,
            'sku': productRows[line.productId]!.sku,
            'name': productRows[line.productId]!.name,
            'stockOnHand': newBalance,
            'reorderPoint': inventory.reorderPoint,
            'triggerInvoiceId': invoice.id,
          });
          await database.into(database.syncOutboxEvents).insert(
                SyncOutboxEventsCompanion.insert(
                  id: _uuid.v4(),
                  branchId: branch.id,
                  aggregateType: 'inventory',
                  aggregateId: '${branch.id}:${line.productId}',
                  eventType: 'inventory.low_stock',
                  idempotencyKey:
                      'inventory.low_stock:${branch.id}:${line.productId}:${invoice.id}',
                  payloadJson: lowStockPayload,
                  createdAt: request.issuedAt,
                ),
              );
        }
      }

      await (database.update(database.invoiceSequences)
            ..where((row) => row.terminalId.equals(terminal.id)))
          .write(
        InvoiceSequencesCompanion(
          nextValue: Value(sequence.nextSequence),
          updatedAt: Value(request.issuedAt),
        ),
      );

      final eventPayload = jsonEncode({
        'invoiceId': invoice.id,
        'invoiceNumber': invoice.invoiceNumber,
        'branchId': branch.id,
        'terminalId': terminal.id,
        'totalCentavos': invoice.totalCentavos,
        'paymentMethod': request.payment.provider.name,
        'paymentReference': invoice.paymentReference,
        'taxSummary': {
          'vatableSalesCentavos': invoice.taxSummary.vatableSalesCentavos,
          'vatAmountCentavos': invoice.taxSummary.vatAmountCentavos,
          'zeroRatedSalesCentavos': invoice.taxSummary.zeroRatedSalesCentavos,
          'vatExemptSalesCentavos': invoice.taxSummary.vatExemptSalesCentavos,
          'nonVatSalesCentavos': invoice.taxSummary.nonVatSalesCentavos,
        },
        'lines': [
          for (final line in invoice.lines)
            {
              'productId': line.productId,
              'description': line.description,
              'quantity': line.quantity,
              'unitPriceCentavos': line.unitPriceCentavos,
              'discountCentavos': line.discountCentavos,
              'taxCategory': line.taxCategory.name,
              'lineTotalCentavos': line.netCentavos,
            },
        ],
        'issuedAt': invoice.issuedAt.toUtc().toIso8601String(),
      });
      await _audit.append(
        branchId: branch.id,
        terminalId: terminal.id,
        actorId: request.actorId,
        eventType: 'invoice.issued',
        entityType: 'invoice',
        entityId: invoice.id,
        payloadJson: eventPayload,
        occurredAt: request.issuedAt,
      );
      await database.into(database.syncOutboxEvents).insert(
            SyncOutboxEventsCompanion.insert(
              id: _uuid.v4(),
              branchId: branch.id,
              aggregateType: 'invoice',
              aggregateId: invoice.id,
              eventType: 'invoice.issued',
              idempotencyKey: 'invoice.issued:${invoice.id}',
              payloadJson: eventPayload,
              createdAt: request.issuedAt,
            ),
          );

      if (request.printReceipt) {
        await database.into(database.hardwareJobs).insert(
              HardwareJobsCompanion.insert(
                id: _uuid.v4(),
                invoiceId: invoice.id,
                jobType: HardwareJobType.printInvoice.name,
                status: HardwareJobStatus.queued.name,
                payloadJson: jsonEncode({
                  'invoiceId': invoice.id,
                  'isReprint': false,
                  'cashierName': request.actorId,
                }),
                idempotencyKey: 'invoice.print:${invoice.id}:original',
                createdAt: request.issuedAt,
              ),
            );
      }
      if (request.openCashDrawer &&
          request.payment.provider == PaymentProvider.cash) {
        await database.into(database.hardwareJobs).insert(
              HardwareJobsCompanion.insert(
                id: _uuid.v4(),
                invoiceId: invoice.id,
                jobType: HardwareJobType.openCashDrawer.name,
                status: HardwareJobStatus.queued.name,
                payloadJson: jsonEncode({'invoiceId': invoice.id}),
                idempotencyKey: 'cash_drawer.open:${invoice.id}',
                createdAt: request.issuedAt,
              ),
            );
      }

      return invoice;
    });
  }

  /// Reactively lists sales for a branch, most recent first. Re-emits on any
  /// invoice insert/update (issuance or void); lines/payments are read fresh
  /// per emission since they are only ever inserted once per invoice.
  Stream<List<SaleRecord>> watchSales({required String branchId}) {
    final query = database.select(database.invoices)
      ..where((row) => row.branchId.equals(branchId))
      ..orderBy([(row) => OrderingTerm.desc(row.issuedAt)]);
    return query.watch().asyncMap((rows) async {
      final records = <SaleRecord>[];
      for (final row in rows) {
        final lines = await (database.select(database.invoiceLines)
              ..where((line) => line.invoiceId.equals(row.id)))
            .get();
        final payment = await (database.select(database.payments)
              ..where((p) => p.invoiceId.equals(row.id)))
            .getSingle();
        records.add(SaleRecord(
          invoice: assembleInvoice(row, lines),
          payment: assemblePayment(payment),
        ));
      }
      return records;
    });
  }

  Future<String> queueInvoiceReprint({
    required String invoiceId,
    required String actorId,
    required DateTime requestedAt,
  }) {
    return database.transaction(() async {
      if (actorId.trim().isEmpty) {
        throw ArgumentError.value(actorId, 'actorId');
      }
      final invoice = await (database.select(database.invoices)
            ..where((row) => row.id.equals(invoiceId)))
          .getSingleOrNull();
      if (invoice == null) throw StateError('Invoice was not found.');

      final jobId = _uuid.v4();
      final payload = jsonEncode({
        'invoiceId': invoice.id,
        'invoiceNumber': invoice.invoiceNumber,
        'isReprint': true,
        'cashierName': actorId.trim(),
        'reprintedAt': requestedAt.toUtc().toIso8601String(),
      });
      await database.into(database.hardwareJobs).insert(
            HardwareJobsCompanion.insert(
              id: jobId,
              invoiceId: invoice.id,
              jobType: HardwareJobType.printInvoice.name,
              status: HardwareJobStatus.queued.name,
              payloadJson: payload,
              idempotencyKey: 'invoice.print:${invoice.id}:reprint:$jobId',
              createdAt: requestedAt,
            ),
          );
      await _audit.append(
        branchId: invoice.branchId,
        terminalId: invoice.terminalId,
        actorId: actorId.trim(),
        eventType: 'invoice.reprint_requested',
        entityType: 'invoice',
        entityId: invoice.id,
        payloadJson: payload,
        occurredAt: requestedAt,
      );
      return jobId;
    });
  }

  /// Voids an issued invoice without deleting or renumbering it.
  /// Inventory, audit, and outbox reversal records commit atomically.
  Future<void> voidInvoice(VoidInvoiceRequest request) {
    return database.transaction(() async {
      if (request.actorId.trim().isEmpty) {
        throw ArgumentError.value(request.actorId, 'actorId');
      }
      if (request.reason.trim().isEmpty) {
        throw ArgumentError.value(
          request.reason,
          'reason',
          'Void reason is required.',
        );
      }

      final invoice = await (database.select(database.invoices)
            ..where((row) => row.id.equals(request.invoiceId)))
          .getSingleOrNull();
      if (invoice == null) throw StateError('Invoice was not found.');
      if (invoice.status == bir.InvoiceStatus.voided.name) {
        throw StateError('Invoice is already voided.');
      }
      if (invoice.status != bir.InvoiceStatus.issued.name) {
        throw StateError('Only an issued invoice can be voided.');
      }

      final lines = await (database.select(database.invoiceLines)
            ..where((row) => row.invoiceId.equals(invoice.id)))
          .get();
      if (lines.isEmpty) {
        throw StateError('Invoice has no stored line items.');
      }

      for (final line in lines) {
        final inventory = await (database.select(database.branchInventories)
              ..where(
                (row) =>
                    row.branchId.equals(invoice.branchId) &
                    row.productId.equals(line.productId),
              ))
            .getSingleOrNull();
        if (inventory == null) {
          throw StateError(
            'Cannot restore inventory for product ${line.productId}.',
          );
        }
        final restoredBalance = inventory.stockOnHand + line.quantity;
        await (database.update(database.branchInventories)
              ..where(
                (row) =>
                    row.branchId.equals(invoice.branchId) &
                    row.productId.equals(line.productId),
              ))
            .write(
          BranchInventoriesCompanion(
            stockOnHand: Value(restoredBalance),
            version: Value(inventory.version + 1),
            updatedAt: Value(request.voidedAt),
          ),
        );
        await database.into(database.inventoryMovements).insert(
              InventoryMovementsCompanion.insert(
                id: _uuid.v4(),
                branchId: invoice.branchId,
                productId: line.productId,
                type: 'sale_void',
                quantityDelta: line.quantity,
                balanceAfter: restoredBalance,
                referenceType: 'invoice_void',
                referenceId: invoice.id,
                occurredAt: request.voidedAt,
              ),
            );
      }

      await (database.update(database.invoices)
            ..where((row) => row.id.equals(invoice.id)))
          .write(
        InvoicesCompanion(
          status: Value(bir.InvoiceStatus.voided.name),
          voidedAt: Value(request.voidedAt),
          voidReason: Value(request.reason.trim()),
          synced: const Value(false),
        ),
      );

      final payload = jsonEncode({
        'invoiceId': invoice.id,
        'invoiceNumber': invoice.invoiceNumber,
        'branchId': invoice.branchId,
        'terminalId': invoice.terminalId,
        'reason': request.reason.trim(),
        'voidedAt': request.voidedAt.toUtc().toIso8601String(),
        'originalTotalCentavos': invoice.totalCentavos,
      });
      await _audit.append(
        branchId: invoice.branchId,
        terminalId: invoice.terminalId,
        actorId: request.actorId.trim(),
        eventType: 'invoice.voided',
        entityType: 'invoice',
        entityId: invoice.id,
        payloadJson: payload,
        occurredAt: request.voidedAt,
      );
      await database.into(database.syncOutboxEvents).insert(
            SyncOutboxEventsCompanion.insert(
              id: _uuid.v4(),
              branchId: invoice.branchId,
              aggregateType: 'invoice',
              aggregateId: invoice.id,
              eventType: 'invoice.voided',
              idempotencyKey: 'invoice.voided:${invoice.id}',
              payloadJson: payload,
              createdAt: request.voidedAt,
            ),
          );
    });
  }
}
