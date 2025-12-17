import 'package:flutter/foundation.dart';
import '../data/repositories/sync_repository.dart';
import '../data/services/connectivity_service.dart';
import 'auth_provider.dart';

/// Provider for managing sync state
class SyncProvider with ChangeNotifier {
  final SyncRepository _syncRepository;
  final ConnectivityService _connectivityService;
  final AuthProvider _authProvider;

  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _error;

  SyncProvider({
    required AuthProvider authProvider,
    SyncRepository? syncRepository,
    ConnectivityService? connectivityService,
  })  : _authProvider = authProvider,
        _syncRepository = syncRepository ?? SyncRepository(),
        _connectivityService = connectivityService ?? ConnectivityService() {
    _initialize();
  }

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get error => _error;
  bool get isSyncing => _syncStatus == SyncStatus.syncing;
  bool get isOnline => _connectivityService.isOnline;

  /// Initialize sync provider
  Future<void> _initialize() async {
    await _connectivityService.initialize();

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline && _authProvider.isSignedIn) {
        // Auto-sync when back online
        syncAll();
      }
      notifyListeners();
    });
  }

  /// Perform initial sync after sign-in
  Future<void> performInitialSync() async {
    final userId = _authProvider.currentUserId;
    if (userId == null) return;

    _setSyncStatus(SyncStatus.syncing);
    _error = null;

    try {
      await _syncRepository.performInitialSync(userId);
      _lastSyncTime = DateTime.now();
      _setSyncStatus(SyncStatus.synced);
    } catch (e) {
      // Silently fail initial sync - app works with local data
      // Don't show error to user, just log it
      debugPrint('Initial sync skipped: ${e.toString()}');
      _setSyncStatus(SyncStatus.idle);
      // Don't set error so user doesn't see constant failure messages
    }
  }

  /// Sync all data
  Future<void> syncAll() async {
    final userId = _authProvider.currentUserId;
    if (userId == null || !_connectivityService.isOnline) {
      return;
    }

    _setSyncStatus(SyncStatus.syncing);
    _error = null;

    try {
      await _syncRepository.syncUserProgress(userId);
      await _syncRepository.syncDailySchedule(userId, DateTime.now());
      _lastSyncTime = DateTime.now();
      _setSyncStatus(SyncStatus.synced);
    } catch (e) {
      // Log but don't spam user with errors
      debugPrint('Sync failed: ${e.toString()}');
      _setSyncStatus(SyncStatus.idle);
      // Only set error for non-permission issues
      if (!e.toString().contains('permission-denied')) {
        _error = 'Sync failed: ${e.toString()}';
      }
    }
  }

  /// Sync user progress only
  Future<void> syncProgress() async {
    final userId = _authProvider.currentUserId;
    if (userId == null || !_connectivityService.isOnline) {
      return;
    }

    try {
      await _syncRepository.syncUserProgress(userId);
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = 'Progress sync failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Sync today's schedule only
  Future<void> syncTodaySchedule() async {
    final userId = _authProvider.currentUserId;
    if (userId == null || !_connectivityService.isOnline) {
      return;
    }

    try {
      await _syncRepository.syncDailySchedule(userId, DateTime.now());
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = 'Schedule sync failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Set sync status
  void _setSyncStatus(SyncStatus status) {
    _syncStatus = status;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}
