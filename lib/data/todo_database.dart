import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase {
  TodoDatabase._();

  static final TodoDatabase instance = TodoDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_cache.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            is_pending INTEGER NOT NULL,
            urgency_level TEXT NOT NULL,
            category TEXT NOT NULL,
            name TEXT NOT NULL,
            color INTEGER NOT NULL,
            start_time TEXT NOT NULL,
            absolute_deadline TEXT NOT NULL,
            desire_deadline TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
