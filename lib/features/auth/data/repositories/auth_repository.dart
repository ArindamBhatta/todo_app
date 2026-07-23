import '../datasources/auth_local_datasource.dart';
import '../datasources/google_auth.dart';
import '../models/auth_user.dart';

class AuthRepository {
  final AuthLocalDataSource _authLocalDataSource;
  final GoogleAuthDataSource _googleAuthDataSource;

  AuthRepository(
    AuthLocalDataSource authLocalDataSource, {
    GoogleAuthDataSource? googleAuthDataSource,
  }) : _authLocalDataSource = authLocalDataSource,
       _googleAuthDataSource = googleAuthDataSource ?? GoogleAuthDataSource();

  Future<bool> isLoggedIn() async => _googleAuthDataSource.isLoggedIn();

  AuthUser? getCurrentUser() => _googleAuthDataSource.getCurrentUser();

  Future<bool> signInWithGoogle() => _googleAuthDataSource.signInWithGoogle();

  Future<void> signOut() async {
    await _googleAuthDataSource.signOut();
    await _authLocalDataSource.clearAppLockCredential();
    await _authLocalDataSource.setBiometricEnabled(false);
  }

  Future<bool> isBiometricEnabled() =>
      _authLocalDataSource.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _authLocalDataSource.setBiometricEnabled(enabled);

  Future<bool> hasAppLockCredential() =>
      _authLocalDataSource.hasAppLockCredential();

  Future<void> saveAppLockCredential(String secret) =>
      _authLocalDataSource.saveAppLockCredential(secret);

  Future<bool> verifyAppLockCredential(String secret) =>
      _authLocalDataSource.verifyAppLockCredential(secret);
}
