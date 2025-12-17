import '../models/daily_schedule.dart';
import '../models/user_progress.dart';
import '../services/firestore_service.dart';
import './storage_service.dart';

/// Repository for syncing data between local storage and Firestore
class SyncRepository {
  final StorageService _storageService;
  final FirestoreService _firestoreService;

  SyncRepository({
    StorageService? storageService,
    FirestoreService? firestoreService,
  })  : _storageService = storageService ?? StorageService(),
        _firestoreService = firestoreService ?? FirestoreService();

  /// Sync all local data to Firestore (typically on first sign-in)
  Future<void> syncLocalToCloud(String userId) async {
    try {
      // Sync user progress
      final localProgress = _storageService.getProgress();
      await _firestoreService.saveUserProgress(userId, localProgress);

      // Sync all schedules
      final localSchedules = _storageService.getAllSchedules();
      if (localSchedules.isNotEmpty) {
        await _firestoreService.batchSaveSchedules(userId, localSchedules);
      }
    } catch (e) {
      throw SyncException('Failed to sync local to cloud: $e');
    }
  }

  /// Sync cloud data to local storage
  Future<void> syncCloudToLocal(String userId) async {
    try {
      // Sync user progress
      final cloudProgress = await _firestoreService.getUserProgress(userId);
      if (cloudProgress != null) {
        await _storageService.saveProgress(cloudProgress);
      }

      // Sync schedules
      final cloudSchedules = await _firestoreService.getAllSchedules(userId);
      for (final schedule in cloudSchedules) {
        await _storageService.saveSchedule(schedule);
      }
    } catch (e) {
      throw SyncException('Failed to sync cloud to local: $e');
    }
  }

  /// Sync user progress bidirectionally
  Future<void> syncUserProgress(String userId) async {
    try {
      // Get both versions
      final localProgress = _storageService.getProgress();
      final cloudProgress = await _firestoreService.getUserProgress(userId);

      // Merge and sync
      final mergedProgress = _mergeUserProgress(localProgress, cloudProgress);
      
      // Save to both
      await Future.wait([
        _storageService.saveProgress(mergedProgress),
        _firestoreService.saveUserProgress(userId, mergedProgress),
      ]);
    } catch (e) {
      throw SyncException('Failed to sync user progress: $e');
    }
  }

  /// Sync a specific daily schedule
  Future<void> syncDailySchedule(String userId, DateTime date) async {
    try {
      // Get both versions
      final localSchedule = _storageService.getSchedule(date);
      final cloudSchedule = await _firestoreService.getDailySchedule(userId, date);

      // If local exists, use it (local is source of truth for tasks)
      if (localSchedule != null) {
        await Future.wait([
          _firestoreService.saveDailySchedule(userId, localSchedule),
        ]);
      } else if (cloudSchedule != null) {
        // If only cloud exists, sync to local
        await _storageService.saveSchedule(cloudSchedule);
      }
    } catch (e) {
      throw SyncException('Failed to sync daily schedule: $e');
    }
  }

  /// Save schedule to both local and cloud
  Future<void> saveSchedule(String userId, DailySchedule schedule) async {
    try {
      await Future.wait([
        _storageService.saveSchedule(schedule),
        _firestoreService.saveDailySchedule(userId, schedule),
      ]);
    } catch (e) {
      // If cloud sync fails, at least local is saved
      throw SyncException('Failed to save schedule: $e');
    }
  }

  /// Save progress to both local and cloud
  Future<void> saveProgress(String userId, UserProgress progress) async {
    try {
      await Future.wait([
        _storageService.saveProgress(progress),
        _firestoreService.saveUserProgress(userId, progress),
      ]);
    } catch (e) {
      // If cloud sync fails, at least local is saved
      throw SyncException('Failed to save progress: $e');
    }
  }

  /// Merge user progress (cloud takes precedence for streaks)
  UserProgress _mergeUserProgress(
    UserProgress local,
    UserProgress? cloud,
  ) {
    if (cloud == null) return local;

    // Cloud takes precedence for most fields
    // But we take the highest values for streaks
    return UserProgress(
      currentStreak: cloud.currentStreak > local.currentStreak
          ? cloud.currentStreak
          : local.currentStreak,
      longestStreak: cloud.longestStreak > local.longestStreak
          ? cloud.longestStreak
          : local.longestStreak,
      lastReadDate: cloud.lastReadDate ?? local.lastReadDate,
      totalDaysRead: cloud.totalDaysRead > local.totalDaysRead
          ? cloud.totalDaysRead
          : local.totalDaysRead,
      consecutiveMissedDays: cloud.consecutiveMissedDays,
      startDate: cloud.startDate ?? local.startDate,
    );
  }

  /// Perform initial sync on first sign-in
  Future<void> performInitialSync(String userId) async {
    try {
      // Check if cloud has any data
      final cloudProgress = await _firestoreService.getUserProgress(userId);
      
      if (cloudProgress == null) {
        // First time user - sync local to cloud
        await syncLocalToCloud(userId);
      } else {
        // Existing user - sync cloud to local and merge
        await syncCloudToLocal(userId);
        await syncUserProgress(userId);
      }
    } catch (e) {
      throw SyncException('Failed to perform initial sync: $e');
    }
  }
}

/// Custom exception for sync errors
class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => message;
}
