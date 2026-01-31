import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import '../data/models/app_user.dart';
import '../core/constants/app_constants.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AppUser? _currentUser;
  bool _isLoading = true; // Initializing to true while loading session
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _loadSession();
    
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

  /// Load session from SharedPreferences
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(AppConstants.keyUserSession);
      
      if (sessionJson != null) {
        final Map<String, dynamic> userData = jsonDecode(sessionJson);
        _currentUser = AppUser.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize local session
  Future<bool> initializeSession() async {
    _setLoading(true);
    _error = null;

    try {
      // Create a local session user
      _currentUser = AppUser.local();
      
      // Persist the session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyUserSession,
        jsonEncode(_currentUser!.toJson()),
      );
      
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
      // Clear persisted session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserSession);
      
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
