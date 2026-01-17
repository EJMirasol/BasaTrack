import 'package:flutter/foundation.dart';
import '../data/services/auth_service.dart';
import '../data/models/app_user.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Listen to auth state changes (currently mock)
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    });
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _currentUser != null;
  String? get currentUserId => _currentUser?.uid;

  /// Initialize local session
  Future<bool> initializeSession() async {
    _setLoading(true);
    _error = null;

    try {
      // Create a local session user
      _currentUser = AppUser.local();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Session initialization failed: ${e.toString()}';
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
      // For this app, sign out clears the current session
      // If we want to clear all data on sign out, we can call clearAll()
      // But usually guest mode should keep data.
      
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
}
