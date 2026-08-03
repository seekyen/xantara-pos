enum StaffRole { owner, admin, manager, cashier, inventoryClerk, auditor }

enum PosPermission {
  createSale,
  voidInvoice,
  reprintInvoice,
  viewInventory,
  adjustInventory,
  dispatchTransfer,
  receiveTransfer,
  cancelTransfer,
  manageSupplierConnectors,
  viewReports,
  manageSettings,
  manageStaff,
  monitorPremium,
}

class StaffPrincipal {
  const StaffPrincipal({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.branchIds,
  });

  final String id;
  final String displayName;
  final String email;
  final StaffRole role;
  final Set<String> branchIds;
}

class PosAuthorizationPolicy {
  const PosAuthorizationPolicy();

  static final _rolePermissions = <StaffRole, Set<PosPermission>>{
    StaffRole.owner: PosPermission.values.toSet(),
    StaffRole.admin: PosPermission.values.toSet(),
    StaffRole.manager: {
      PosPermission.createSale,
      PosPermission.voidInvoice,
      PosPermission.reprintInvoice,
      PosPermission.viewInventory,
      PosPermission.adjustInventory,
      PosPermission.dispatchTransfer,
      PosPermission.receiveTransfer,
      PosPermission.cancelTransfer,
      PosPermission.viewReports,
    },
    StaffRole.cashier: {
      PosPermission.createSale,
      PosPermission.viewInventory,
    },
    StaffRole.inventoryClerk: {
      PosPermission.viewInventory,
      PosPermission.adjustInventory,
      PosPermission.dispatchTransfer,
      PosPermission.receiveTransfer,
    },
    StaffRole.auditor: {
      PosPermission.viewInventory,
      PosPermission.viewReports,
    },
  };

  bool allows(
    StaffPrincipal principal,
    PosPermission permission, {
    required String branchId,
  }) {
    if (!principal.branchIds.contains(branchId)) return false;
    return _rolePermissions[principal.role]?.contains(permission) ?? false;
  }

  void require(
    StaffPrincipal principal,
    PosPermission permission, {
    required String branchId,
  }) {
    if (!allows(principal, permission, branchId: branchId)) {
      throw AuthorizationException(
        '${principal.role.name} is not allowed to ${permission.name} at this branch.',
      );
    }
  }
}

class AuthorizationException implements Exception {
  const AuthorizationException(this.message);
  final String message;
  @override
  String toString() => message;
}
