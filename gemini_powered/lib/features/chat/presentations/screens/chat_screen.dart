
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:testing/core/theme/app_theme.dart';
import 'package:testing/features/chat/presentations/screens/widgets/animated_orb.dart';
import 'package:testing/features/chat/data/repositories/chat_repository.dart';
import 'package:testing/features/chat/domain/models/chat_conversation.dart';
import 'package:testing/features/chat/domain/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final Uuid _uuid = const Uuid();

  final ChatRepository _chatRepository = ChatRepository();

  final List<ChatMessage> _messages = [];

  List<ChatConversation> _conversations = [];

  String? _currentConversationId;

  bool _isLoadingHistory = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  // Load all saved conversations from SQLite.
  Future<void> _loadConversations() async {
    if (mounted) {
      setState(() {
        _isLoadingHistory = true;
      });
    }

    try {
      final conversations =
          await _chatRepository.getConversations();

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _isLoadingHistory = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
      });

      debugPrint('Error loading conversations: $error');
    }
  }

  // Send and save a message.
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final now = DateTime.now();

      // Create a conversation if one is not currently active.
      if (_currentConversationId == null) {
        final conversationId = _uuid.v4();

        final conversation = ChatConversation(
          id: conversationId,
          title: message.length > 40
              ? '${message.substring(0, 40)}...'
              : message,
          createdAt: now,
          updatedAt: now,
        );

        await _chatRepository.createConversation(conversation);

        _currentConversationId = conversationId;
      }

      // Create the message object.
      final chatMessage = ChatMessage(
        id: _uuid.v4(),
        content: message,
        role: MessageRole.user,
        createdAt: now,
        status: MessageStatus.sent,
      );

      // Save the message in SQLite.
      await _chatRepository.saveMessage(
        _currentConversationId!,
        chatMessage,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(chatMessage);
        _messageController.clear();
        _isSendingMessage = false;
      });

      await _loadConversations();

      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSendingMessage = false;
      });

      debugPrint('Error sending message: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save message. Please try again.'),
        ),
      );
    }
  }

  // Open a previously saved conversation.
  Future<void> _openConversation(
    ChatConversation conversation,
  ) async {
    try {
      final messages = await _chatRepository.getMessages(
        conversation.id,
      );

      if (!mounted) return;

      setState(() {
        _currentConversationId = conversation.id;

        _messages
          ..clear()
          ..addAll(messages);
      });

      Navigator.pop(context);

      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      debugPrint('Error opening conversation: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this conversation.'),
        ),
      );
    }
  }

  // Start a new conversation without deleting saved chats.
  void _startNewChat({bool closeDrawer = false}) {
    setState(() {
      _messages.clear();
      _messageController.clear();
      _currentConversationId = null;
    });

    if (closeDrawer) {
      Navigator.pop(context);
    }
  }

  // Scroll to the latest message.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildChatHistoryDrawer(),

      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Chat history',
          ),
        ),

        title: const Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppTheme.primary,
            ),
            SizedBox(width: 10),
            Text('Aether'),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add),
            tooltip: 'New chat',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Chat history navigation drawer.
  Widget _buildChatHistoryDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surface,
      width: MediaQuery.sizeOf(context).width * 0.82,

      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),

              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primary,
                    size: 26,
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    'Aether',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // New chat button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _startNewChat(closeDrawer: true);
                  },

                  icon: const Icon(Icons.add),
                  label: const Text('New chat'),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 12),

              child: Text(
                'RECENT CHATS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Display saved conversations.
            Expanded(
              child: _buildConversationList(),
            ),

            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),

              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Recent conversation list.
  Widget _buildConversationList() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      );
    }

    if (_conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),

          child: Text(
            'Your conversations will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _conversations.length,

      itemBuilder: (context, index) {
        final conversation = _conversations[index];

        final isSelected =
            conversation.id == _currentConversationId;

        return ListTile(
          selected: isSelected,

          selectedTileColor:
              AppTheme.primary.withValues(alpha: 0.10),

          leading: const Icon(
            Icons.chat_bubble_outline,
            size: 19,
          ),

          title: Text(
            conversation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),

          onTap: () {
            _openConversation(conversation);
          },
        );
      },
    );
  }

  // Welcome screen shown before the first message.
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const AnimatedOrb(size: 180),

            const SizedBox(height: 28),

            const Text(
              'What can I help you with?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ask a question, explore an idea, '
              'or start something new.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display messages.
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),

      itemCount: _messages.length,

      itemBuilder: (context, index) {
        final message = _messages[index];

        return Align(
          alignment: message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,

          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),

            margin: const EdgeInsets.only(bottom: 16),

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: message.isUser
                  ? AppTheme.primary.withValues(alpha: 0.15)
                  : AppTheme.surface,

              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: message.isUser
                    ? const Radius.circular(5)
                    : const Radius.circular(20),

                bottomLeft: message.isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
              ),
            ),

            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  // Message composer.
  Widget _buildMessageInput() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),

      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 6,
          top: 4,
          bottom: 4,
        ),

        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),

          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Expanded(
              child: TextField(
                controller: _messageController,

                minLines: 1,
                maxLines: 5,

                keyboardType: TextInputType.multiline,

                textCapitalization: TextCapitalization.sentences,

                textInputAction: TextInputAction.newline,

                onSubmitted: (_) => _sendMessage(),

                enabled: !_isSendingMessage,

                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),

                decoration: const InputDecoration(
                  hintText: 'Message Aether...',

                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                  ),

                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,

                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),

                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Padding(
              padding: const EdgeInsets.only(bottom: 2),

              child: IconButton.filled(
                onPressed: _isSendingMessage
                    ? null
                    : _sendMessage,

                tooltip: 'Send message',

                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(44, 44),
                  shape: const CircleBorder(),
                ),

                icon: _isSendingMessage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.arrow_upward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
