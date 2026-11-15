
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get the currently authenticated user.
  User? get currentUser => _supabase.auth.currentUser;

  // Listen for authentication changes.
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Register a new user.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  // Log in an existing user.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Log out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Request a password recovery email.
  Future<void> resetPassword({
    required String email,
  }) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
    );
  }
}
