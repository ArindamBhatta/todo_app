import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> biometrics =
          await _localAuth.getAvailableBiometrics();
      return isSupported && biometrics.isNotEmpty;
    } on LocalAuthException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    final bool available = await isBiometricAvailable();
    if (!available) {
      return false;
    }

    try {
      return _localAuth.authenticate(
        localizedReason: 'Use biometrics to unlock your account',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
