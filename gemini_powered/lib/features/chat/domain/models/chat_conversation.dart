
class ChatConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert conversation into a format
  // that can be stored in a database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Reconstruct a conversation from database data.
  factory ChatConversation.fromMap(
    Map<String, Object?> map,
  ) {
    return ChatConversation(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }
}
