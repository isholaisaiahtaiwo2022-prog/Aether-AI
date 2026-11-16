import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:testing/features/chat/presentations/screens/chat_screen.dart';
import 'package:testing/features/chat/presentations/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to check authentication status.'),
            ),
          );
        }

        // Use the latest auth event, or the existing session
        // when the stream has not emitted an event yet.
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          return const ChatScreen();
        }

        return const LoginScreen();
      },
    );
  }
}