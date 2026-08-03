import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../local/database_providers.dart';
import '../../../local/repositories/staff_auth_repository.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final StaffAuthRepository _repository;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final principal = await _repository.authenticate(
        email: email,
        password: password,
        now: DateTime.now(),
      );
      state = AuthState(
        user: UserModel(
          id: principal.id,
          name: principal.displayName,
          email: principal.email,
          role: principal.role.name,
          branchIds: principal.branchIds,
        ),
      );
      return true;
    } on AuthenticationLockedException catch (error) {
      final minutes = error.lockedUntil.difference(DateTime.now()).inMinutes;
      state = state.copyWith(
        isLoading: false,
        error: 'Too many attempts. Try again in ${minutes.clamp(1, 999)} min.',
      );
      return false;
    } on AuthenticationException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(staffAuthRepositoryProvider)),
);
