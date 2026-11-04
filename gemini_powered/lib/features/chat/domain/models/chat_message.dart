
enum MessageRole {
  user,
  assistant,
}

enum MessageStatus {
  pending,
  sent,
  failed,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.status = MessageStatus.pending,
  });

  bool get isUser => role == MessageRole.user;

  // Convert the Dart object into a map SQLite can store.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  // Convert a database record back into a ChatMessage object.
  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      role: MessageRole.values.byName(map['role'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: MessageStatus.values.byName(map['status'] as String),
    );
  }

  ChatMessage copyWith({
    String? content,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      role: role,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
