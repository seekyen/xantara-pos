import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/hardware/pos_hardware.dart';
import 'database.dart';
import 'repositories/audit_trail_repository.dart';
import 'repositories/bir_reporting_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/hardware_job_processor.dart';
import 'repositories/offline_sale_repository.dart';
import 'repositories/staff_auth_repository.dart';

/// Overridden in main() with the real on-device database once opened.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main().');
});

final offlineSaleRepositoryProvider = Provider<OfflineSaleRepository>(
  (ref) => OfflineSaleRepository(ref.watch(appDatabaseProvider)),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(appDatabaseProvider)),
);

final staffAuthRepositoryProvider = Provider<StaffAuthRepository>(
  (ref) => StaffAuthRepository(ref.watch(appDatabaseProvider)),
);

final auditTrailRepositoryProvider = Provider<AuditTrailRepository>(
  (ref) => AuditTrailRepository(ref.watch(appDatabaseProvider)),
);

final birReportingRepositoryProvider = Provider<BirReportingRepository>(
  (ref) => BirReportingRepository(ref.watch(appDatabaseProvider)),
);

/// No printer/cash-drawer driver is selected yet — see
/// docs/HARDWARE_ARCHITECTURE.md. Jobs are still queued, leased, retried,
/// and completed for real; only the physical I/O is simulated.
final hardwareJobProcessorProvider = Provider<HardwareJobProcessor>(
  (ref) => HardwareJobProcessor(
    database: ref.watch(appDatabaseProvider),
    printer: const LoggingReceiptPrinterAdapter(),
    cashDrawer: const LoggingCashDrawerAdapter(),
  ),
);

/// Drains the hardware job queue until nothing is immediately eligible, so
/// print/cash-drawer jobs reach a terminal state right after a sale/void in
/// this single-threaded desktop app (no background isolate yet).
Future<void> drainHardwareJobQueue(HardwareJobProcessor processor) async {
  for (var guard = 0; guard < 50; guard++) {
    final result = await processor.processNext(DateTime.now());
    if (!result.processed) return;
  }
}
