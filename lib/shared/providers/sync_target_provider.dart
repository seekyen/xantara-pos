import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/local_pos_store.dart';
import '../../features/pos/fnb/providers/pos_provider.dart';

/// Which backend Cloud sync talks to. Defaults to [cloud] to preserve the
/// app's existing hardcoded-production behavior for anyone upgrading; switch
/// to [local] to test against a Django backend running on this machine.
enum SyncTarget {
  local('Local backend', 'http://127.0.0.1:8086'),
  cloud('Xantara Cloud (VPS)', 'https://xantarapos.com');

  const SyncTarget(this.label, this.baseUrl);
  final String label;
  final String baseUrl;
}

class SyncTargetNotifier extends StateNotifier<SyncTarget> {
  SyncTargetNotifier(this._store) : super(SyncTarget.cloud) {
    _load();
  }

  static const _key = 'xantara.sync-target.v1';
  final LocalPosStore _store;

  Future<void> _load() async {
    final saved = await _store.read(_key);
    for (final target in SyncTarget.values) {
      if (target.name == saved) {
        state = target;
        return;
      }
    }
  }

  Future<void> select(SyncTarget target) async {
    state = target;
    await _store.write(_key, target.name);
  }
}

/// Cloud sync's connected session is already keyed by the backend's origin
/// (see CloudSyncController._sessionKey), so switching targets never mixes up
/// or overwrites credentials saved for the other one.
final syncTargetProvider =
    StateNotifierProvider<SyncTargetNotifier, SyncTarget>(
  (ref) => SyncTargetNotifier(ref.read(localPosStoreProvider)),
);
