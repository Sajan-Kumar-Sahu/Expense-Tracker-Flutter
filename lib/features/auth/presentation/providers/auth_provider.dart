import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Singleton storage used across the app (also read by AuthInterceptor) ──
final authStorageProvider = Provider<AuthStorage>((_) => AuthStorage());

final _authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.read(authStorageProvider);
  final dio = DioProvider.createDio(storage);
  final client = ApiClient(dio);
  return AuthRepositoryImpl(AuthRemoteDataSource(client), storage);
});

// ── Auth state ──────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String fullName;
  final String email;
  const AuthAuthenticated({required this.fullName, required this.email});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Notifier ────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final AuthStorage _storage;

  AuthNotifier(this._repository, this._storage) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    final isAuth = await _storage.isAuthenticated();
    if (isAuth) {
      final fullName = await _storage.getFullName() ?? '';
      final email = await _storage.getEmail() ?? '';
      state = AuthAuthenticated(fullName: fullName, email: email);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<bool> login(String mobileNumber, String password) async {
    state = const AuthLoading();
    final result = await _repository.login(mobileNumber, password);
    return result.fold(
      (auth) {
        state = AuthAuthenticated(fullName: auth.fullName, email: auth.email);
        return true;
      },
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(_authRepositoryProvider);
  final storage = ref.read(authStorageProvider);
  return AuthNotifier(repo, storage);
});
