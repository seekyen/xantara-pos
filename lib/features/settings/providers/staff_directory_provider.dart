import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/cloud_sync_controller.dart';
import '../../../shared/providers/sync_provider.dart';

/// Read-only view of the backend's Staff + Branch records — the same roster
/// the admin web dashboard's Staff page manages (name, role/access level,
/// branch assignment, status). This is deliberately NOT this device's own
/// cashier login (that stays local-first via StaffUsers/StaffBranchAccess in
/// the Drift database); it only lets a connected cloud administrator look up
/// who's assigned where.
class BranchInfo {
  const BranchInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.staffCount,
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final bool isActive;
  final int staffCount;

  factory BranchInfo.fromJson(Map<String, dynamic> json) => BranchInfo(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        staffCount: (json['staff_count'] as num?)?.toInt() ?? 0,
      );
}

class StaffDirectoryEntry {
  const StaffDirectoryEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.roleDisplay,
    required this.branchId,
    required this.branchName,
    required this.status,
    required this.statusDisplay,
    required this.initials,
    required this.salesCount,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String roleDisplay;
  final int? branchId;
  final String? branchName;
  final String status;
  final String statusDisplay;
  final String initials;
  final int salesCount;

  factory StaffDirectoryEntry.fromJson(Map<String, dynamic> json) {
    final branchDetail = json['branch_detail'] as Map<String, dynamic>?;
    return StaffDirectoryEntry(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      roleDisplay: json['role_display'] as String? ?? '',
      branchId: json['branch'] as int?,
      branchName: branchDetail?['name'] as String?,
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      salesCount: (json['sales_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class StaffDirectoryState {
  const StaffDirectoryState({
    this.loading = true,
    this.connected = false,
    this.error,
    this.staff = const [],
    this.branches = const [],
  });

  final bool loading;
  final bool connected;
  final String? error;
  final List<StaffDirectoryEntry> staff;
  final List<BranchInfo> branches;

  StaffDirectoryState copyWith({
    bool? loading,
    bool? connected,
    String? error,
    List<StaffDirectoryEntry>? staff,
    List<BranchInfo>? branches,
  }) =>
      StaffDirectoryState(
        loading: loading ?? this.loading,
        connected: connected ?? this.connected,
        error: error,
        staff: staff ?? this.staff,
        branches: branches ?? this.branches,
      );
}

/// Backend list endpoints are paginated at 10/page — page_size=100 covers any
/// realistic branch/staff roster in one request instead of following `next`.
List<Map<String, dynamic>> _extractResults(dynamic data) {
  if (data is Map && data['results'] is List) {
    return List<Map<String, dynamic>>.from(data['results'] as List);
  }
  if (data is List) return List<Map<String, dynamic>>.from(data);
  return const [];
}

class StaffDirectoryController extends StateNotifier<StaffDirectoryState> {
  StaffDirectoryController(this._cloud) : super(const StaffDirectoryState()) {
    load();
  }

  final CloudSyncController _cloud;

  Future<void> load() async {
    if (!await _cloud.isConfigured) {
      state = state.copyWith(loading: false, connected: false);
      return;
    }
    state = state.copyWith(loading: true, connected: true, error: null);
    try {
      final staffData = await _cloud.staffRequest('?page_size=100');
      final branchData = await _cloud.branchesRequest('?page_size=100');
      state = StaffDirectoryState(
        loading: false,
        connected: true,
        staff: _extractResults(staffData).map(StaffDirectoryEntry.fromJson).toList(),
        branches: _extractResults(branchData).map(BranchInfo.fromJson).toList(),
      );
    } catch (error) {
      state = state.copyWith(loading: false, connected: true, error: error.toString());
    }
  }
}

final staffDirectoryProvider =
    StateNotifierProvider<StaffDirectoryController, StaffDirectoryState>(
  (ref) => StaffDirectoryController(ref.watch(cloudSyncControllerProvider)),
);
