
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Create an account
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'aetherai://auth-callback/',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Request password reset
  Future<void> resetPassword({
    required String email,
  }) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
    );
  }
}
