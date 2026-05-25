import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';

final biometricServiceProvider =
    Provider<BiometricService>((_) => BiometricService());

final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.read(biometricServiceProvider).isAvailable();
});

class BiometricEnabledNotifier extends StateNotifier<bool> {
  final BiometricService _svc;

  BiometricEnabledNotifier(this._svc) : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await _svc.isEnabled();
  }

  Future<void> enable(String email, String password) async {
    await _svc.enable(email, password);
    state = true;
  }

  Future<void> disable() async {
    await _svc.disable();
    state = false;
  }
}

final biometricEnabledProvider =
    StateNotifierProvider<BiometricEnabledNotifier, bool>(
  (ref) => BiometricEnabledNotifier(ref.read(biometricServiceProvider)),
);
