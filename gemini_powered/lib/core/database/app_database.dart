
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  // Singleton: one shared database manager.
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'aether_ai.db',
    );

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            content TEXT NOT NULL,
            role TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL,

            FOREIGN KEY (conversation_id)
            REFERENCES conversations (id)
            ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_messages_conversation_id
          ON messages (conversation_id)
        ''');
      },
    );
  }
}
