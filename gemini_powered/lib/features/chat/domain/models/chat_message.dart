
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
