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
      // If we get a real user, always update (even if current is guest)
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      } 
      // If we get null, only update if the current user is NOT a guest
      // This prevents guest state from being cleared by background auth changes
      else if (_currentUser?.isGuest != true) {
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
  bool get isGuest => _currentUser?.isGuest ?? false;
  String? get currentUserId => _currentUser?.uid;

  /// Sign in with Google (Currently disabled - under development)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = 'Google Sign-In is currently under development. Please use Offline mode for now.';
    notifyListeners();
    _setLoading(false);
    return false;

    /* Original implementation - disabled
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
      }
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
    */
  }

  /// Sign in as guest (local only, no Firebase auth)
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _error = null;

    try {
      // Create a local guest user
      _currentUser = AppUser.guest();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Guest sign in failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Prepare for Google Sign-In while in guest mode
  /// Resets internal user state to null but DOES NOT clear local storage
  void prepareForSignInFromGuest() {
    _currentUser = null;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      // Only clear local storage if NOT a guest (authenticated user)
      // This allows guest progress to be retained on the device
      // while protecting privacy for signed-in users.
      if (!isGuest) {
        final storageService = StorageService();
        await storageService.clearAll();
        
        await _authService.signOut();
      }

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
