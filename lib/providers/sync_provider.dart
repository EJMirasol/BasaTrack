import 'package:flutter/foundation.dart';
import '../data/services/connectivity_service.dart';
import 'auth_provider.dart';

/// Provider for managing sync state
class SyncProvider with ChangeNotifier {
  final ConnectivityService _connectivityService;
  final AuthProvider _authProvider;

  final SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _error;

  SyncProvider({
    required AuthProvider authProvider,
    ConnectivityService? connectivityService,
  })  : _authProvider = authProvider,
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

  /// Perform initial sync (No-op after refactor)
  Future<void> performInitialSync() async {
    return;
  }

  /// Sync all data (No-op after refactor)
  Future<void> syncAll() async {
    return;
  }

  /// Sync user progress only (No-op after refactor)
  Future<void> syncProgress() async {
    return;
  }

  /// Sync today's schedule only (No-op after refactor)
  Future<void> syncTodaySchedule() async {
    return;
  }

  /// Sync a specific schedule date (No-op after refactor)
  Future<void> syncScheduleForDate(DateTime date) async {
    return;
  }

  /// Set sync status

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
