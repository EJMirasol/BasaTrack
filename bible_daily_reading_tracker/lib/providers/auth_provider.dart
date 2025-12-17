import 'package:flutter/foundation.dart';
import '../data/services/auth_service.dart';
import '../data/models/app_user.dart';
import '../data/repositories/storage_service.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _currentUser != null;
  String? get currentUserId => _currentUser?.uid;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      // Clear local storage before signing out
      // This prevents the next user from seeing previous user's data
      final storageService = StorageService();
      await storageService.clearAll();
      
      // Sign out from Firebase
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
