
import 'package:drift/drift.dart';

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
    await _appDatabase.into(_appDatabase.conversations).insertOnConflictUpdate(
      ConversationsCompanion.insert(
        id: conversation.id,
        title: conversation.title,
        createdAt: conversation.createdAt.toIso8601String(),
        updatedAt: conversation.updatedAt.toIso8601String(),
      ),
    );
  }

  // Save a message and update the conversation activity time.
  Future<void> saveMessage(
    String conversationId,
    ChatMessage message,
  ) async {
    await _appDatabase.transaction(() async {
      await _appDatabase.into(_appDatabase.messages).insertOnConflictUpdate(
        MessagesCompanion.insert(
          id: message.id,
          conversationId: conversationId,
          content: message.content,
          role: message.role.name,
          createdAt: message.createdAt.toIso8601String(),
          status: message.status.name,
        ),
      );

      await (_appDatabase.update(_appDatabase.conversations)
            ..where((table) => table.id.equals(conversationId)))
          .write(
        ConversationsCompanion(
          updatedAt: Value(message.createdAt.toIso8601String()),
        ),
      );
    });
  }

  // Retrieve all conversations, newest activity first.
  Future<List<ChatConversation>> getConversations() async {
    final results = await (_appDatabase.select(_appDatabase.conversations)
          ..orderBy([
            (table) => OrderingTerm.desc(table.updatedAt),
          ]))
        .get();

    return results.map((conversation) {
      return ChatConversation(
        id: conversation.id,
        title: conversation.title,
        createdAt: DateTime.parse(conversation.createdAt),
        updatedAt: DateTime.parse(conversation.updatedAt),
      );
    }).toList();
  }

  // Retrieve all messages belonging to a conversation.
  Future<List<ChatMessage>> getMessages(
    String conversationId,
  ) async {
    final results = await (_appDatabase.select(_appDatabase.messages)
          ..where((table) => table.conversationId.equals(conversationId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();

    return results.map((message) {
      return ChatMessage(
        id: message.id,
        content: message.content,
        role: MessageRole.values.byName(message.role),
        createdAt: DateTime.parse(message.createdAt),
        status: MessageStatus.values.byName(message.status),
      );
    }).toList();
  }

  // Delete a conversation and its associated messages.
  Future<void> deleteConversation(String conversationId) async {
    await (_appDatabase.delete(_appDatabase.conversations)
          ..where((table) => table.id.equals(conversationId)))
        .go();
  }
}
