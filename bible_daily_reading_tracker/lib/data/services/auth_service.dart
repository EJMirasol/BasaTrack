import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

/// Service for handling user authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user stream
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  /// Get current user
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _userFromFirebase(user) : null;
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      return _userFromFirebase(userCredential.user);
    } catch (e) {
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  /// Convert Firebase User to AppUser
  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;

    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  /// Delete account (optional, for future use)
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);

  @override
  String toString() => message;
}
