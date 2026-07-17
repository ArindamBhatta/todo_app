import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

class AuthManager extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.isLoggedIn();
  }

  Future<void> login() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.setLoggedIn(true);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.setLoggedIn(false);
      state = const AsyncData(false);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> isBiometricEnabled() async {
    final repository = ref.read(authRepositoryProvider);
    return repository.isBiometricEnabled();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.setBiometricEnabled(enabled);
  }
}

final authProvider = AsyncNotifierProvider<AuthManager, bool>(() {
  return AuthManager();
});
