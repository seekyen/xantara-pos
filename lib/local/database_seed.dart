import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/auth/pos_authorization.dart';
import 'database.dart';
import 'repositories/staff_auth_repository.dart';

String branchIdForCode(String code) => switch (code.toUpperCase()) {
      'BGC' => 'branch-br002',
      'MKT' => 'branch-br003',
      final normalized => 'branch-${normalized.toLowerCase()}',
    };
String terminalIdForBranch(String branchId) => '$branchId-pos01';

const _branchNames = {
  'MAIN': 'Head Office',
  'BGC': 'BGC',
  'MKT': 'Makati',
};

class _SeedProduct {
  const _SeedProduct(this.id, this.name, this.priceCentavos, this.categoryId,
      this.colorArgb, this.stock);
  final String id;
  final String name;
  final int priceCentavos;
  final String categoryId;
  final int colorArgb;
  final int stock;
}

const _seedProducts = [
  _SeedProduct(
    'SAMPLE-001',
    'Sample Product',
    10000,
    'sample',
    0xFF1565C0,
    10,
  ),
];

/// Demo/training credentials, seeded once on first run so the app is usable
/// without an out-of-band credential handoff. Shown on the login screen
/// while the seller profile stays in training mode. Replace with real staff
/// accounts (via StaffAuthRepository.createStaff) before production use.
const seedOwnerEmail = 'owner@xantara.com';
const seedOwnerPassword = 'XantaraOwner#2026!';
const seedCashierEmail = 'cashier@xantara.com';
const seedCashierPassword = 'XantaraCashier#2026!';

/// Seeds branches, terminals, invoice sequences, the shared product catalog,
/// per-branch stock, and demo staff accounts — only when the database is
/// empty (first run).
Future<void> seedDatabaseIfEmpty(AppDatabase database) async {
  final existing =
      await (database.select(database.branches)..limit(1)).getSingleOrNull();
  if (existing != null) return;

  final now = DateTime.now();
  await database.transaction(() async {
    for (final product in _seedProducts) {
      await database.into(database.products).insert(
            ProductsCompanion.insert(
              id: product.id,
              sku: product.id,
              name: product.name,
              taxCategory: 'vat12',
              unitPriceCentavos: product.priceCentavos,
              categoryId: Value(product.categoryId),
              colorArgb: Value(product.colorArgb),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    for (final entry in _branchNames.entries) {
      final code = entry.key;
      final branchId = branchIdForCode(code);
      final terminalId = terminalIdForBranch(branchId);
      await database.into(database.branches).insert(
            BranchesCompanion.insert(
              id: branchId,
              code: code,
              name: entry.value,
              createdAt: now,
            ),
          );
      await database.into(database.terminals).insert(
            TerminalsCompanion.insert(
              id: terminalId,
              branchId: branchId,
              code: 'POS01',
              machineIdentificationNumber: 'TRAINING-MIN-$code',
              permitToUseNumber: 'TRAINING-PTU-$code',
              machineSerialNumber: 'TRAINING-SERIAL-$code',
              createdAt: now,
            ),
          );
      await database.into(database.invoiceSequences).insert(
            InvoiceSequencesCompanion.insert(
              terminalId: terminalId,
              nextValue: 1,
              updatedAt: now,
            ),
          );
      for (final product in _seedProducts) {
        await database.into(database.branchInventories).insert(
              BranchInventoriesCompanion.insert(
                branchId: branchId,
                productId: product.id,
                stockOnHand: Value(product.stock),
                reorderPoint: const Value(5),
                updatedAt: now,
              ),
            );
      }
    }
  });

  final staffAuth = StaffAuthRepository(database);
  final allBranchIds = _branchNames.keys.map(branchIdForCode).toSet();
  await staffAuth.createStaff(CreateStaffRequest(
    displayName: 'Store Owner',
    email: seedOwnerEmail,
    role: StaffRole.owner,
    password: seedOwnerPassword,
    branchIds: allBranchIds,
    createdBy: 'system-seed',
    createdAt: now,
  ));
  await staffAuth.createStaff(CreateStaffRequest(
    displayName: 'Cashier One',
    email: seedCashierEmail,
    role: StaffRole.cashier,
    password: seedCashierPassword,
    branchIds: {branchIdForCode('MAIN')},
    createdBy: 'system-seed',
    createdAt: now,
  ));

  debugPrint(
    'Xantara POS: seeded demo accounts — '
    '$seedOwnerEmail / $seedOwnerPassword (owner), '
    '$seedCashierEmail / $seedCashierPassword (cashier).',
  );
}
