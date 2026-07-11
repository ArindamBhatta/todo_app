import 'package:sqflite/sqflite.dart';
import 'package:todo/data/todo_database.dart';

class OnboardingLocalDataSource {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<bool> isOnboardingCompleted() async {
    final db = await TodoDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_onboardingCompletedKey],
    );
    if (maps.isEmpty) {
      return false;
    }
    return maps.first['value'] == 'true';
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'app_settings',
      {'key': _onboardingCompletedKey, 'value': completed ? 'true' : 'false'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
