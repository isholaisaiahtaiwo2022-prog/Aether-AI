import 'package:flutter/material.dart';
import 'package:testing/core/theme/app_theme.dart';
import 'package:testing/features/chat/presentations/screens/widgets/animated_orb.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () {},
            icon: const Icon(Icons.add),
            tooltip: 'New chat',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: LayoutBuilder(
  builder: (context, constraints) {
    final orbSize = (constraints.maxWidth * 0.88)
        .clamp(280.0, 420.0)
        .toDouble();

    return Center(
      child: AnimatedOrb(size: orbSize),
    );
  },
),
              ),
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
      ),
    );
  }
}