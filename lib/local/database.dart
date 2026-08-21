import 'package:drift/drift.dart';

part 'database.g.dart';

class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Terminals extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get code => text()();
  TextColumn get machineIdentificationNumber => text()();
  TextColumn get permitToUseNumber => text()();
  TextColumn get machineSerialNumber => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {branchId, code},
        {machineIdentificationNumber},
      ];
}

class StaffUsers extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get emailNormalized => text().unique()();
  TextColumn get role => text()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get passwordAlgorithm => text()();
  IntColumn get passwordIterations => integer()();
  IntColumn get failedLoginAttempts =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StaffBranchAccess extends Table {
  TextColumn get staffUserId => text().references(StaffUsers, #id)();
  TextColumn get branchId => text().references(Branches, #id)();
  DateTimeColumn get grantedAt => dateTime()();
  TextColumn get grantedBy => text()();

  @override
  Set<Column<Object>> get primaryKey => {staffUserId, branchId};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text().unique()();
  TextColumn get name => text()();
  TextColumn get taxCategory => text()();
  IntColumn get unitPriceCentavos => integer()();
  TextColumn get categoryId =>
      text().withDefault(const Constant('uncategorized'))();
  IntColumn get colorArgb =>
      integer().withDefault(const Constant(0xFF6F4E37))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BranchInventories extends Table {
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get stockOnHand => integer().withDefault(const Constant(0))();
  IntColumn get reorderPoint => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {branchId, productId};
}

class InvoiceSequences extends Table {
  TextColumn get terminalId => text().references(Terminals, #id)();
  IntColumn get nextValue => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {terminalId};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get terminalId => text().references(Terminals, #id)();
  DateTimeColumn get issuedAt => dateTime()();
  TextColumn get status => text()();
  TextColumn get paymentMethod => text()();
  TextColumn get paymentReference => text()();
  IntColumn get totalCentavos => integer()();
  IntColumn get vatableSalesCentavos => integer()();
  IntColumn get vatAmountCentavos => integer()();
  IntColumn get zeroRatedSalesCentavos => integer()();
  IntColumn get vatExemptSalesCentavos => integer()();
  IntColumn get nonVatSalesCentavos => integer()();
  TextColumn get sellerName => text()();
  TextColumn get sellerTin => text()();
  TextColumn get sellerAddress => text()();
  TextColumn get sellerRegistrationType => text()();
  TextColumn get branchCode => text()();
  TextColumn get machineIdentificationNumber => text()();
  TextColumn get permitToUseNumber => text()();
  TextColumn get machineSerialNumber => text()();
  TextColumn get softwareName => text()();
  TextColumn get softwareVersion => text()();
  TextColumn get buyerName => text().nullable()();
  TextColumn get buyerTin => text().nullable()();
  TextColumn get buyerAddress => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();
  TextColumn get originalInvoiceId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InvoiceLines extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get description => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceCentavos => integer()();
  IntColumn get discountCentavos => integer()();
  TextColumn get taxCategory => text()();
  IntColumn get lineTotalCentavos => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().unique().references(Invoices, #id)();
  TextColumn get provider => text()();
  TextColumn get status => text()();
  IntColumn get amountCentavos => integer()();
  TextColumn get reference => text()();
  DateTimeColumn get authorizedAt => dateTime()();
  BoolColumn get isOffline => boolean()();
  IntColumn get cashTenderedCentavos => integer().nullable()();
  IntColumn get changeCentavos => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get type => text()();
  IntColumn get quantityDelta => integer()();
  IntColumn get balanceAfter => integer()();
  TextColumn get referenceType => text()();
  TextColumn get referenceId => text()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InventoryTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  @ReferenceName('sourceBranchTransfers')
  TextColumn get sourceBranchId => text().references(Branches, #id)();
  @ReferenceName('destinationBranchTransfers')
  TextColumn get destinationBranchId => text().references(Branches, #id)();
  IntColumn get quantity => integer()();
  TextColumn get status => text()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dispatchedAt => dateTime()();
  TextColumn get receivedBy => text().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  TextColumn get cancelledBy => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancellationReason => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuditEvents extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  IntColumn get sequence => integer()();
  TextColumn get previousHash => text()();
  TextColumn get eventHash => text()();
  TextColumn get terminalId => text().nullable()();
  TextColumn get actorId => text()();
  TextColumn get eventType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {branchId, sequence},
      ];
}

class SyncOutboxEvents extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get eventType => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get leaseId => text().nullable()();
  DateTimeColumn get leaseExpiresAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get serverEventId => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class HardwareJobs extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get jobType => text()();
  TextColumn get status => text()();
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get processingStartedAt => dateTime().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SupplierConnectors extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get name => text()();
  TextColumn get connectorType => text()();
  TextColumn get secretReference => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get approvedBy => text()();
  DateTimeColumn get approvedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SupplierProductSubscriptions extends Table {
  TextColumn get connectorId => text().references(SupplierConnectors, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get allowedFieldsJson => text()();
  IntColumn get suggestedOrderQuantity => integer()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get approvedBy => text()();
  DateTimeColumn get approvedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {connectorId, productId};
}

class SupplierDeliveryJobs extends Table {
  TextColumn get id => text()();
  TextColumn get connectorId => text().references(SupplierConnectors, #id)();
  TextColumn get sourceEventId => text().references(SyncOutboxEvents, #id)();
  TextColumn get branchId => text().references(Branches, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get status => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get leaseId => text().nullable()();
  DateTimeColumn get leaseExpiresAt => dateTime().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get externalReference => text().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Branches,
    Terminals,
    StaffUsers,
    StaffBranchAccess,
    Products,
    BranchInventories,
    InvoiceSequences,
    Invoices,
    InvoiceLines,
    Payments,
    InventoryMovements,
    InventoryTransfers,
    AuditEvents,
    SyncOutboxEvents,
    HardwareJobs,
    SupplierConnectors,
    SupplierProductSubscriptions,
    SupplierDeliveryJobs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(products, products.categoryId);
            await migrator.addColumn(products, products.colorArgb);
          }
          if (from < 3) {
            await _replaceUntouchedTrainingInventory();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _replaceUntouchedTrainingInventory() async {
    final transactionalCounts = await Future.wait([
      select(invoices).get().then((rows) => rows.length),
      select(inventoryMovements).get().then((rows) => rows.length),
      select(inventoryTransfers).get().then((rows) => rows.length),
    ]);
    if (transactionalCounts.any((count) => count != 0)) return;

    const trainingProductIds = {
      'b1',
      'b2',
      'b3',
      'b4',
      'b5',
      'b6',
      'f1',
      'f2',
      'f3',
      'f4',
      'f5',
      'f6',
      's1',
      's2',
      's3',
      's4',
      'd1',
      'd2',
      'd3',
      'd4',
    };
    final existingProducts = await select(products).get();
    if (existingProducts.length != trainingProductIds.length ||
        existingProducts.any((row) => !trainingProductIds.contains(row.id))) {
      return;
    }

    final now = DateTime.now();
    await (update(branches)..where((row) => row.id.equals('branch-main')))
        .write(const BranchesCompanion(
      code: Value('MAIN'),
      name: Value('Head Office'),
    ));
    await (update(branches)..where((row) => row.id.equals('branch-br002')))
        .write(const BranchesCompanion(
      code: Value('BGC'),
      name: Value('BGC'),
    ));
    await (update(branches)..where((row) => row.id.equals('branch-br003')))
        .write(const BranchesCompanion(
      code: Value('MKT'),
      name: Value('Makati'),
    ));

    await delete(branchInventories).go();
    await delete(products).go();
    await into(products).insert(ProductsCompanion.insert(
      id: 'SAMPLE-001',
      sku: 'SAMPLE-001',
      name: 'Sample Product',
      taxCategory: 'vat12',
      unitPriceCentavos: 10000,
      categoryId: const Value('sample'),
      colorArgb: const Value(0xFF1565C0),
      createdAt: now,
      updatedAt: now,
    ));
    for (final branchId in const [
      'branch-main',
      'branch-br002',
      'branch-br003',
    ]) {
      await into(branchInventories).insert(BranchInventoriesCompanion.insert(
        branchId: branchId,
        productId: 'SAMPLE-001',
        stockOnHand: const Value(10),
        reorderPoint: const Value(2),
        updatedAt: now,
      ));
    }
  }
}
