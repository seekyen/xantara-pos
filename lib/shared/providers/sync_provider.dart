import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/cloud_sync_controller.dart';
import '../../features/pos/fnb/providers/pos_provider.dart';
import '../../local/database_providers.dart';
import 'sync_target_provider.dart';

enum SyncStatus { synced, syncing, offline, complete }

class SyncState {
  final SyncStatus status;
  final int queued;
  final int downloaded;
  const SyncState({
    this.status = SyncStatus.synced,
    this.queued = 0,
    this.downloaded = 0,
  });

  SyncState copyWith({SyncStatus? status, int? queued, int? downloaded}) =>
      SyncState(
        status: status ?? this.status,
        queued: queued ?? this.queued,
        downloaded: downloaded ?? this.downloaded,
      );
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._controller) : super(const SyncState()) {
    _syncConfiguredSession();
  }

  final CloudSyncController _controller;

  void setSynced() =>
      state = state.copyWith(status: SyncStatus.synced, queued: 0);

  void setSyncing() => state = state.copyWith(status: SyncStatus.syncing);

  void setOffline(int queued) =>
      state = state.copyWith(status: SyncStatus.offline, queued: queued);

  void setComplete(CloudSyncResult result) => state = state.copyWith(
        status: SyncStatus.complete,
        queued: result.uploadedEvents,
        downloaded: result.downloadedProducts,
      );

  Future<void> _syncConfiguredSession() async {
    if (!await _controller.isConfigured) return;
    try {
      await syncNow();
    } catch (_) {
      // syncNow already exposes the offline state; startup remains local-first.
    }
  }

  Future<void> connectAndSync({
    required String email,
    required String password,
  }) async {
    setSyncing();
    try {
      await _controller.connect(email: email, password: password);
      final result = await _controller.syncNow();
      setComplete(result);
    } catch (_) {
      state = state.copyWith(status: SyncStatus.offline);
      rethrow;
    }
  }

  Future<void> syncNow() async {
    setSyncing();
    try {
      final result = await _controller.syncNow();
      setComplete(result);
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
    baseUrl: ref.watch(syncTargetProvider).baseUrl,
  ),
);

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(ref.watch(cloudSyncControllerProvider)),
);
