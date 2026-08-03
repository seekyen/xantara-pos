import 'package:drift/drift.dart';

import '../database.dart';

class ElectronicJournalEntry {
  const ElectronicJournalEntry({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.issuedAt,
    required this.status,
    required this.paymentMethod,
    required this.totalCentavos,
    required this.vatableSalesCentavos,
    required this.vatAmountCentavos,
    required this.zeroRatedSalesCentavos,
    required this.vatExemptSalesCentavos,
    required this.nonVatSalesCentavos,
    this.voidedAt,
    this.voidReason,
  });

  final String invoiceId;
  final String invoiceNumber;
  final DateTime issuedAt;
  final String status;
  final String paymentMethod;
  final int totalCentavos;
  final int vatableSalesCentavos;
  final int vatAmountCentavos;
  final int zeroRatedSalesCentavos;
  final int vatExemptSalesCentavos;
  final int nonVatSalesCentavos;
  final DateTime? voidedAt;
  final String? voidReason;
}

class TerminalReading {
  const TerminalReading({
    required this.branchId,
    required this.terminalId,
    required this.from,
    required this.to,
    required this.generatedAt,
    required this.transactionCount,
    required this.voidCount,
    required this.grossSalesCentavos,
    required this.voidSalesCentavos,
    required this.netSalesCentavos,
    required this.vatableSalesCentavos,
    required this.vatAmountCentavos,
    required this.zeroRatedSalesCentavos,
    required this.vatExemptSalesCentavos,
    required this.nonVatSalesCentavos,
    required this.paymentTotalsCentavos,
    this.beginningInvoiceNumber,
    this.endingInvoiceNumber,
  });

  final String branchId;
  final String terminalId;
  final DateTime from;
  final DateTime to;
  final DateTime generatedAt;
  final int transactionCount;
  final int voidCount;
  final int grossSalesCentavos;
  final int voidSalesCentavos;
  final int netSalesCentavos;
  final int vatableSalesCentavos;
  final int vatAmountCentavos;
  final int zeroRatedSalesCentavos;
  final int vatExemptSalesCentavos;
  final int nonVatSalesCentavos;
  final Map<String, int> paymentTotalsCentavos;
  final String? beginningInvoiceNumber;
  final String? endingInvoiceNumber;
}

class BirReportingRepository {
  const BirReportingRepository(this.database);

  final AppDatabase database;

  Future<List<ElectronicJournalEntry>> electronicSalesJournal({
    required String branchId,
    required String terminalId,
    required DateTime from,
    required DateTime to,
  }) async {
    _validateRange(from, to);
    final rows = await (database.select(database.invoices)
          ..where(
            (row) =>
                row.branchId.equals(branchId) &
                row.terminalId.equals(terminalId) &
                row.issuedAt.isBiggerOrEqualValue(from) &
                row.issuedAt.isSmallerThanValue(to),
          )
          ..orderBy([
            (row) => OrderingTerm.asc(row.issuedAt),
            (row) => OrderingTerm.asc(row.invoiceNumber),
          ]))
        .get();

    return List.unmodifiable(
      rows.map(
        (row) => ElectronicJournalEntry(
          invoiceId: row.id,
          invoiceNumber: row.invoiceNumber,
          issuedAt: row.issuedAt,
          status: row.status,
          paymentMethod: row.paymentMethod,
          totalCentavos: row.totalCentavos,
          vatableSalesCentavos: row.vatableSalesCentavos,
          vatAmountCentavos: row.vatAmountCentavos,
          zeroRatedSalesCentavos: row.zeroRatedSalesCentavos,
          vatExemptSalesCentavos: row.vatExemptSalesCentavos,
          nonVatSalesCentavos: row.nonVatSalesCentavos,
          voidedAt: row.voidedAt,
          voidReason: row.voidReason,
        ),
      ),
    );
  }

  Future<TerminalReading> terminalReading({
    required String branchId,
    required String terminalId,
    required DateTime from,
    required DateTime to,
    required DateTime generatedAt,
  }) async {
    final journal = await electronicSalesJournal(
      branchId: branchId,
      terminalId: terminalId,
      from: from,
      to: to,
    );

    var gross = 0;
    var voidSales = 0;
    var vatable = 0;
    var vat = 0;
    var zeroRated = 0;
    var exempt = 0;
    var nonVat = 0;
    var voidCount = 0;
    final paymentTotals = <String, int>{};

    for (final entry in journal) {
      gross += entry.totalCentavos;
      if (entry.status == 'voided') {
        voidCount++;
        voidSales += entry.totalCentavos;
        continue;
      }
      vatable += entry.vatableSalesCentavos;
      vat += entry.vatAmountCentavos;
      zeroRated += entry.zeroRatedSalesCentavos;
      exempt += entry.vatExemptSalesCentavos;
      nonVat += entry.nonVatSalesCentavos;
      paymentTotals.update(
        entry.paymentMethod,
        (value) => value + entry.totalCentavos,
        ifAbsent: () => entry.totalCentavos,
      );
    }

    return TerminalReading(
      branchId: branchId,
      terminalId: terminalId,
      from: from,
      to: to,
      generatedAt: generatedAt,
      transactionCount: journal.length,
      voidCount: voidCount,
      grossSalesCentavos: gross,
      voidSalesCentavos: voidSales,
      netSalesCentavos: gross - voidSales,
      vatableSalesCentavos: vatable,
      vatAmountCentavos: vat,
      zeroRatedSalesCentavos: zeroRated,
      vatExemptSalesCentavos: exempt,
      nonVatSalesCentavos: nonVat,
      paymentTotalsCentavos: Map.unmodifiable(paymentTotals),
      beginningInvoiceNumber:
          journal.isEmpty ? null : journal.first.invoiceNumber,
      endingInvoiceNumber: journal.isEmpty ? null : journal.last.invoiceNumber,
    );
  }

  void _validateRange(DateTime from, DateTime to) {
    if (!from.isBefore(to)) {
      throw ArgumentError('Report start must be before report end.');
    }
  }
}
