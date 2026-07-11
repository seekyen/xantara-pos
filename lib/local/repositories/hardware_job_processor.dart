import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/hardware/pos_hardware.dart';
import '../database.dart';
import 'invoice_assembler.dart';

class HardwareJobProcessResult {
  const HardwareJobProcessResult({
    required this.processed,
    required this.succeeded,
    this.jobId,
    this.error,
  });

  final bool processed;
  final bool succeeded;
  final String? jobId;
  final String? error;
}

class HardwareJobProcessor {
  const HardwareJobProcessor({
    required this.database,
    required this.printer,
    required this.cashDrawer,
    this.receiptFormatter = const BirReceiptFormatter(),
  });

  final AppDatabase database;
  final ReceiptPrinterAdapter printer;
  final CashDrawerAdapter cashDrawer;
  final BirReceiptFormatter receiptFormatter;

  Future<HardwareJobProcessResult> processNext(DateTime now) async {
    final candidates = await (database.select(database.hardwareJobs)
          ..where((row) => row.status.isIn([
                HardwareJobStatus.queued.name,
                HardwareJobStatus.failed.name,
              ]))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
    final eligible = candidates
        .where(
          (job) =>
              job.nextAttemptAt == null || !job.nextAttemptAt!.isAfter(now),
        )
        .firstOrNull;
    if (eligible == null) {
      return const HardwareJobProcessResult(
        processed: false,
        succeeded: false,
      );
    }

    final attempts = eligible.attemptCount + 1;
    await (database.update(database.hardwareJobs)
          ..where((row) => row.id.equals(eligible.id)))
        .write(
      HardwareJobsCompanion(
        status: Value(HardwareJobStatus.processing.name),
        attemptCount: Value(attempts),
        processingStartedAt: Value(now),
        lastError: const Value(null),
      ),
    );

    try {
      final type = HardwareJobType.values.byName(eligible.jobType);
      switch (type) {
        case HardwareJobType.printInvoice:
          final data = await _loadReceiptData(eligible);
          await printer.printReceipt(
            receiptFormatter.format(data),
            jobId: eligible.id,
          );
          break;
        case HardwareJobType.openCashDrawer:
          await cashDrawer.openDrawer(jobId: eligible.id);
          break;
      }
      await (database.update(database.hardwareJobs)
            ..where((row) => row.id.equals(eligible.id)))
          .write(
        HardwareJobsCompanion(
          status: Value(HardwareJobStatus.completed.name),
          completedAt: Value(now),
          processingStartedAt: const Value(null),
          nextAttemptAt: const Value(null),
          lastError: const Value(null),
        ),
      );
      return HardwareJobProcessResult(
        processed: true,
        succeeded: true,
        jobId: eligible.id,
      );
    } catch (error) {
      final delaySeconds = min(300, 1 << min(attempts, 8));
      await (database.update(database.hardwareJobs)
            ..where((row) => row.id.equals(eligible.id)))
          .write(
        HardwareJobsCompanion(
          status: Value(HardwareJobStatus.failed.name),
          processingStartedAt: const Value(null),
          nextAttemptAt: Value(now.add(Duration(seconds: delaySeconds))),
          lastError: Value(error.toString()),
        ),
      );
      return HardwareJobProcessResult(
        processed: true,
        succeeded: false,
        jobId: eligible.id,
        error: error.toString(),
      );
    }
  }

  Future<int> recoverInterruptedJobs({
    required DateTime now,
    required Duration staleAfter,
  }) async {
    if (staleAfter <= Duration.zero) {
      throw ArgumentError.value(staleAfter, 'staleAfter');
    }
    final cutoff = now.subtract(staleAfter);
    final interrupted = await (database.select(database.hardwareJobs)
          ..where(
            (row) =>
                row.status.equals(HardwareJobStatus.processing.name) &
                row.processingStartedAt.isSmallerThanValue(cutoff),
          ))
        .get();
    for (final job in interrupted) {
      await (database.update(database.hardwareJobs)
            ..where((row) => row.id.equals(job.id)))
          .write(
        HardwareJobsCompanion(
          status: Value(HardwareJobStatus.queued.name),
          processingStartedAt: const Value(null),
          nextAttemptAt: Value(now),
          lastError: const Value(
            'Recovered after an interrupted hardware operation.',
          ),
        ),
      );
    }
    return interrupted.length;
  }

  Future<ReceiptPrintData> _loadReceiptData(HardwareJob job) async {
    final invoiceRow = await (database.select(database.invoices)
          ..where((row) => row.id.equals(job.invoiceId)))
        .getSingle();
    final lineRows = await (database.select(database.invoiceLines)
          ..where((row) => row.invoiceId.equals(invoiceRow.id)))
        .get();
    final paymentRow = await (database.select(database.payments)
          ..where((row) => row.invoiceId.equals(invoiceRow.id)))
        .getSingle();
    final payload = jsonDecode(job.payloadJson) as Map<String, dynamic>;

    final reprintedAtRaw = payload['reprintedAt'] as String?;
    return ReceiptPrintData(
      invoice: assembleInvoice(invoiceRow, lineRows),
      payment: assemblePayment(paymentRow),
      cashierName: payload['cashierName'] as String? ?? 'Unknown',
      isReprint: payload['isReprint'] as bool? ?? false,
      reprintedAt:
          reprintedAtRaw == null ? null : DateTime.parse(reprintedAtRaw),
    );
  }
}
