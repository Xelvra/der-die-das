import 'package:sqflite/sqflite.dart';
import 'storage_path_helper.dart';

class UserDatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    StoragePathHelper.initDatabaseFactory();
    final path = await StoragePathHelper.getDatabasePath('user.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await _createWordStatusTable(db);
    await _createGameHistoryTable(db);
  }

  Future<void> _createWordStatusTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS word_status (
        word_id $idType,
        due_date $textType,
        stability $realType,
        difficulty $realType,
        lapses $intType DEFAULT 0,
        reps $intType DEFAULT 0,
        wrong_count $intType DEFAULT 0,
        last_review TEXT
      )
    ''');
  }

  Future<void> _createGameHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        score INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        played_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
