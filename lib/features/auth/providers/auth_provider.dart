import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Static users for testing
const _staticUsers = [
  {
    'id': '1',
    'name': 'Admin User',
    'email': 'admin@xantara.com',
    'password': 'admin123',
    'role': 'admin',
  },
  {
    'id': '2',
    'name': 'Cashier One',
    'email': 'cashier@xantara.com',
    'password': 'cashier123',
    'role': 'cashier',
  },
];

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
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final match = _staticUsers.where(
      (u) => u['email'] == email.trim() && u['password'] == password,
    );

    if (match.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password.',
      );
      return false;
    }

    final u = match.first;
    state = AuthState(
      user: UserModel(
        id: u['id']!,
        name: u['name']!,
        email: u['email']!,
        role: u['role']!,
      ),
    );
    return true;
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
