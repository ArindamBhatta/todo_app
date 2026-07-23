import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/features/auth/data/datasources/auth_local_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthLocalDataSource', () {
    late AuthLocalDataSource dataSource;
    late FakeSecureStorage secureStorage;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      secureStorage = FakeSecureStorage();
      dataSource = AuthLocalDataSource(secureStorage: secureStorage);
    });

    test('stores a hashed app lock credential and verifies it', () async {
      expect(await dataSource.hasAppLockCredential(), isFalse);

      await dataSource.saveAppLockCredential('1234');

      expect(await dataSource.hasAppLockCredential(), isTrue);
      expect(secureStorage.values.values.single, isNot('1234'));
      expect(await dataSource.verifyAppLockCredential('1234'), isTrue);
      expect(await dataSource.verifyAppLockCredential('9999'), isFalse);
    });

    test(
      'clears the app lock credential and biometric shortcut flag',
      () async {
        await dataSource.saveAppLockCredential('strong-passphrase');
        await dataSource.setBiometricEnabled(true);

        await dataSource.clearAppLockCredential();
        await dataSource.setBiometricEnabled(false);

        expect(await dataSource.hasAppLockCredential(), isFalse);
        expect(await dataSource.isBiometricEnabled(), isFalse);
      },
    );
  });
}

class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage();

  final Map<String, String> values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
      return;
    }

    values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}
