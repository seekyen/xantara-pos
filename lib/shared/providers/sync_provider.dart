import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/cloud_sync_controller.dart';
import '../../features/pos/fnb/providers/pos_provider.dart';
import '../../local/database_providers.dart';

enum SyncStatus { synced, syncing, offline, complete }

class SyncState {
  final SyncStatus status;
  final int queued;
  const SyncState({this.status = SyncStatus.synced, this.queued = 0});

  SyncState copyWith({SyncStatus? status, int? queued}) => SyncState(
        status: status ?? this.status,
        queued: queued ?? this.queued,
      );
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._controller) : super(const SyncState());

  final CloudSyncController _controller;

  void setSynced() =>
      state = state.copyWith(status: SyncStatus.synced, queued: 0);

  void setSyncing() => state = state.copyWith(status: SyncStatus.syncing);

  void setOffline(int queued) =>
      state = state.copyWith(status: SyncStatus.offline, queued: queued);

  void setComplete(int uploaded) =>
      state = state.copyWith(status: SyncStatus.complete, queued: uploaded);

  Future<void> connectAndSync({
    required String email,
    required String password,
  }) async {
    setSyncing();
    try {
      await _controller.connect(email: email, password: password);
      final uploaded = await _controller.syncNow();
      setComplete(uploaded);
    } catch (_) {
      state = state.copyWith(status: SyncStatus.offline);
      rethrow;
    }
  }

  Future<void> syncNow() async {
    setSyncing();
    try {
      final uploaded = await _controller.syncNow();
      setComplete(uploaded);
    } catch (_) {
      state = state.copyWith(status: SyncStatus.offline);
      rethrow;
    }
  }
}

final cloudSyncControllerProvider = Provider<CloudSyncController>(
  (ref) => CloudSyncController(
    database: ref.watch(appDatabaseProvider),
    store: ref.watch(localPosStoreProvider),
  ),
);

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(ref.watch(cloudSyncControllerProvider)),
);
