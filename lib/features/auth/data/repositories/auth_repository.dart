import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<bool> isLoggedIn() async {
    return _dataSource.isLoggedIn();
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    await _dataSource.setLoggedIn(loggedIn);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepository(dataSource);
});
