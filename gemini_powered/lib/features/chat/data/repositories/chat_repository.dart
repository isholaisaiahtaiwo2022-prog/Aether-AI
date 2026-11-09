
import 'package:sqflite/sqflite.dart';

import 'package:testing/core/database/app_database.dart';
import 'package:testing/features/chat/domain/models/chat_conversation.dart';
import 'package:testing/features/chat/domain/models/chat_message.dart';

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

  // Save a message inside an existing conversation.
  Future<void> saveMessage(
    String conversationId,
    ChatMessage message,
  ) async {
    final Database db = await _appDatabase.database;

    await db.insert(
      'messages',
      {
        ...message.toMap(),
        'conversation_id': conversationId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update the conversation's last activity time.
    await db.update(
      'conversations',
      {
        'updated_at': message.createdAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }
}
