import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final profile = await repo.getCurrentUserProfile();
  if (profile != null) return profile;
  final user = repo.currentUser;
  if (user == null) return null;
  return UserModel(
    id: user.id,
    email: user.email ?? '',
    fullName: user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'Utilizador',
    username: user.userMetadata?['username'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthUiState>((ref) {
  return AuthNotifier(ref);
});

class AuthUiState {
  final bool isLoading;
  final String? error;
  final bool success;

  const AuthUiState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AuthUiState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return AuthUiState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthUiState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthUiState());

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signUpWithEmail(email: email, password: password, fullName: fullName);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.resetPassword(email);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}
