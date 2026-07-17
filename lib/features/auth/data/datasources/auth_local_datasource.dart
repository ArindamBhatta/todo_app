import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, loggedIn);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isBiometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isBiometricEnabledKey, enabled);
  }
}
