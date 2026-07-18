import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';

class AuthManager extends Cubit<bool> {
  final AuthRepository _repository;

  AuthManager(this._repository) : super(false);

  Future<void> syncAuthState() async {
    final bool isLoggedIn = await _repository.isLoggedIn();
    emit(isLoggedIn);
  }

  Future<bool> signInWithGoogle() async {
    final bool isLoggedIn = await _repository.signInWithGoogle();
    if (isLoggedIn) {
      emit(true);
    }
    return isLoggedIn;
  }

  Future<void> logout() async {
    await _repository.signOut();
    emit(false);
  }

  Future<bool> isLoggedIn() => _repository.isLoggedIn();

  Future<bool> isBiometricEnabled() => _repository.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _repository.setBiometricEnabled(enabled);
}
