const _adminUxRoles = {'owner', 'admin', 'manager'};

/// Owner/admin/manager land on the admin dashboard; cashier (and, for now,
/// inventoryClerk/auditor) land on the cashier dashboard.
bool isAdminRole(String? role) => _adminUxRoles.contains(role);

const _roleLabels = {
  'owner': 'Owner',
  'admin': 'Administrator',
  'manager': 'Manager',
  'cashier': 'Cashier',
  'inventoryClerk': 'Inventory Clerk',
  'auditor': 'Auditor',
};

String roleLabelFor(String? role) => _roleLabels[role] ?? 'Staff';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final Set<String> branchIds;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.branchIds = const {},
  });
}
