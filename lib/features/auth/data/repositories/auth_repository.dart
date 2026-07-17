import '../datasources/auth_local_datasource.dart';

class AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<bool> isLoggedIn() => _dataSource.isLoggedIn();

  Future<void> setLoggedIn(bool loggedIn) => _dataSource.setLoggedIn(loggedIn);

  Future<bool> isBiometricEnabled() => _dataSource.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _dataSource.setBiometricEnabled(enabled);
}
