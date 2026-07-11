import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../core/auth/pos_authorization.dart';
import 'database.dart';
import 'repositories/staff_auth_repository.dart';

String branchIdForCode(String code) => 'branch-${code.toLowerCase()}';
String terminalIdForBranch(String branchId) => '$branchId-pos01';

const _branchNames = {
  'MAIN': 'Main Branch',
  'BR002': 'Branch 2',
  'BR003': 'Branch 3',
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
  _SeedProduct('b1', 'Hot Coffee', 8500, 'beverages', 0xFF6F4E37, 50),
  _SeedProduct('b2', 'Iced Coffee', 9500, 'beverages', 0xFF4A90D9, 40),
  _SeedProduct('b3', 'Green Tea', 7500, 'beverages', 0xFF5D8A5E, 30),
  _SeedProduct('b4', 'Orange Juice', 8000, 'beverages', 0xFFE8821A, 25),
  _SeedProduct('b5', 'Mineral Water', 2500, 'beverages', 0xFF78C1D4, 100),
  _SeedProduct('b6', 'Lemonade', 7000, 'beverages', 0xFFD4C026, 20),
  _SeedProduct('f1', 'Chicken Sandwich', 12000, 'food', 0xFFD4A056, 15),
  _SeedProduct('f2', 'Cheeseburger', 15000, 'food', 0xFFBE4B26, 10),
  _SeedProduct('f3', 'Pepperoni Pizza', 18000, 'food', 0xFFCC3A3A, 8),
  _SeedProduct('f4', 'Caesar Salad', 11000, 'food', 0xFF6FAE6F, 12),
  _SeedProduct('f5', 'Pasta Carbonara', 16000, 'food', 0xFFD4BE8A, 9),
  _SeedProduct('f6', 'Fish & Chips', 14500, 'food', 0xFFD4A826, 11),
  _SeedProduct('s1', 'Potato Chips', 4500, 'snacks', 0xFFD4B44A, 60),
  _SeedProduct('s2', 'Choco Cookie', 5500, 'snacks', 0xFF7B5C3E, 45),
  _SeedProduct('s3', 'Blueberry Muffin', 6500, 'snacks', 0xFF6A5ACD, 20),
  _SeedProduct('s4', 'Pretzel', 5000, 'snacks', 0xFFC4924A, 30),
  _SeedProduct('d1', 'Ice Cream', 7500, 'desserts', 0xFFE8A0C0, 35),
  _SeedProduct('d2', 'Chocolate Cake', 9500, 'desserts', 0xFF5C3D2E, 15),
  _SeedProduct('d3', 'Brownie', 8500, 'desserts', 0xFF4A2F1A, 22),
  _SeedProduct('d4', 'Cheesecake', 11000, 'desserts', 0xFFE8D5A0, 10),
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
