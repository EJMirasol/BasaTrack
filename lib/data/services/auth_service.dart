import '../models/app_user.dart';

/// Service for handling user authentication (Refactored to local only)
class AuthService {
  // We'll keep a mock current user for guest mode, or just handle it in AuthProvider
  
  /// Get current user stream (Mock for local only)
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  /// Get current user
  AppUser? get currentUser => null;

  /// Get current user ID
  String? get currentUserId => null;

  /// Check if user is signed in
  bool get isSignedIn => false;

  /// Sign out
  Future<void> signOut() async {
    // Local state handled by AuthProvider
    return;
  }

  /// Delete account
  Future<void> deleteAccount() async {
    return;
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);

  @override
  String toString() => message;
}
