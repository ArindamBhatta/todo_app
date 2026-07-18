import '../datasources/auth_local_datasource.dart';
import '../datasources/google_auth.dart';

class AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final GoogleAuthDataSource _googleAuthDataSource;

  AuthRepository(
    this._localDataSource, {
    GoogleAuthDataSource? googleAuthDataSource,
  }) : _googleAuthDataSource = googleAuthDataSource ?? GoogleAuthDataSource();

  Future<bool> isLoggedIn() async => _googleAuthDataSource.isLoggedIn();

  Future<bool> signInWithGoogle() => _googleAuthDataSource.signInWithGoogle();

  Future<void> signOut() async {
    await _googleAuthDataSource.signOut();
    await _localDataSource.setBiometricEnabled(false);
  }

  Future<bool> isBiometricEnabled() => _localDataSource.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _localDataSource.setBiometricEnabled(enabled);

  Future<bool> isGuestMode() => _localDataSource.isGuestMode();

  Future<void> setGuestMode(bool value) => _localDataSource.setGuestMode(value);
}
