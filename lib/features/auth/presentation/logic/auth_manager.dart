import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';

class AuthManager extends Cubit<bool> {
  final AuthRepository _repository;

  AuthManager(this._repository) : super(false);

  Future<void> login() async {
    await _repository.setLoggedIn(true);
    emit(true);
  }

  Future<void> logout() async {
    await _repository.setLoggedIn(false);
    emit(false);
  }

  Future<bool> isBiometricEnabled() => _repository.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _repository.setBiometricEnabled(enabled);
}
