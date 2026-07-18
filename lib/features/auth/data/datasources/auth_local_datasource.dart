import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';
  static const _guestMode = 'guest_mode';

  // check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_isBiometricEnabledKey) ?? false;
  }

  // set biometric authentication status
  Future<void> setBiometricEnabled(bool enabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_isBiometricEnabledKey, enabled);
  }

  Future<bool> isGuestMode() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_guestMode) ?? false;
  }

  Future<void> setGuestMode(bool value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_guestMode, value);
  }
}

/* 
First launch
────────────

Splash
   │
   ▼
Firebase.currentUser == null
   │
   ▼
Google Sign-In (mandatory)
   │
   ▼
Firebase creates user
   │
   ▼
Ask user to enroll/enable biometric (mandatory)
   │
   ▼
Home


Then every subsequent launch:

Splash
   │
   ▼
Firebase.currentUser == null ?
   │
   ├── Yes → Google Sign-In
   │
   └── No
         │
         ▼
   Biometric Authentication
         │
    ┌────┴────┐
    │         │
 Success    Failed
    │         │
    ▼         ▼
 Home     Stay Locked
 */
