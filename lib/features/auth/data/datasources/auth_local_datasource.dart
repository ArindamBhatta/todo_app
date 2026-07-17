import 'package:sqflite/sqflite.dart';
import 'package:todo/data/todo_database.dart';

class AuthLocalDataSource {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';

  Future<bool> isLoggedIn() async {
    final db = await TodoDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_isLoggedInKey],
    );
    if (maps.isEmpty) {
      return false;
    }
    return maps.first['value'] == 'true';
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'app_settings',
      {'key': _isLoggedInKey, 'value': loggedIn ? 'true' : 'false'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isBiometricEnabled() async {
    final db = await TodoDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_isBiometricEnabledKey],
    );
    if (maps.isEmpty) {
      return false;
    }
    return maps.first['value'] == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'app_settings',
      {
        'key': _isBiometricEnabledKey,
        'value': enabled ? 'true' : 'false',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
