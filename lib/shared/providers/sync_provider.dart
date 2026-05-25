import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  SyncNotifier() : super(const SyncState());

  void setSynced() =>
      state = state.copyWith(status: SyncStatus.synced, queued: 0);

  void setSyncing() =>
      state = state.copyWith(status: SyncStatus.syncing);

  void setOffline(int queued) =>
      state = state.copyWith(status: SyncStatus.offline, queued: queued);

  void setComplete(int uploaded) =>
      state = state.copyWith(status: SyncStatus.complete, queued: uploaded);
}

final syncProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) => SyncNotifier());
