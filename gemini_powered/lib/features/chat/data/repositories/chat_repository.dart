
import 'package:sqflite/sqflite.dart';

import 'package:testing/core/database/app_database.dart';
import 'package:testing/features/chat/domain/models/chat_conversation.dart';

class ChatRepository {
  final AppDatabase _appDatabase;

  ChatRepository({
    AppDatabase? appDatabase,
  }) : _appDatabase = appDatabase ?? AppDatabase.instance;

  // Create and save a new conversation.
  Future<void> createConversation(
    ChatConversation conversation,
  ) async {
    final Database db = await _appDatabase.database;

    await db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
