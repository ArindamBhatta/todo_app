import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    final bool isSupported = await _localAuth.isDeviceSupported();
    final bool canCheck = await _localAuth.canCheckBiometrics;
    return isSupported || canCheck;
  }

  Future<bool> authenticate() async {
    final bool available = await canUseBiometrics();
    if (!available) {
      return false;
    }

    try {
      return _localAuth.authenticate(
        localizedReason: 'Authenticate to continue to your guest account',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
