import '../models/daily_schedule.dart';
import '../models/reading_task.dart';
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

      // Merge both versions
      final mergedSchedule = _mergeDailySchedule(localSchedule, cloudSchedule);

      if (mergedSchedule != null) {
        await Future.wait([
          _storageService.saveSchedule(mergedSchedule),
          _firestoreService.saveDailySchedule(userId, mergedSchedule),
        ]);
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

  /// Merge user progress (cloud takes precedence for streaks, but we take highest values)
  UserProgress _mergeUserProgress(
    UserProgress local,
    UserProgress? cloud,
  ) {
    if (cloud == null) return local;

    return UserProgress(
      currentStreak: cloud.currentStreak > local.currentStreak
          ? cloud.currentStreak
          : local.currentStreak,
      longestStreak: cloud.longestStreak > local.longestStreak
          ? cloud.longestStreak
          : local.longestStreak,
      lastReadDate: cloud.lastReadDate != null && local.lastReadDate != null
          ? (cloud.lastReadDate!.isAfter(local.lastReadDate!) 
              ? cloud.lastReadDate 
              : local.lastReadDate)
          : (cloud.lastReadDate ?? local.lastReadDate),
      totalDaysRead: cloud.totalDaysRead > local.totalDaysRead
          ? cloud.totalDaysRead
          : local.totalDaysRead,
      consecutiveMissedDays: cloud.consecutiveMissedDays < local.consecutiveMissedDays
          ? cloud.consecutiveMissedDays
          : local.consecutiveMissedDays,
      startDate: cloud.startDate ?? local.startDate,
    );
  }

  /// Merge daily schedules (a task is completed if it's true in either)
  DailySchedule? _mergeDailySchedule(DailySchedule? local, DailySchedule? cloud) {
    if (local == null) return cloud;
    if (cloud == null) return local;

    final mergedTasks = <ReadingTask>[];
    
    // Create a map of tasks from cloud for easy lookup
    final cloudTaskMap = {for (var t in cloud.tasks) t.id: t};

    for (var localTask in local.tasks) {
      final cloudTask = cloudTaskMap[localTask.id];
      if (cloudTask != null) {
        final isCompleted = localTask.isCompleted || cloudTask.isCompleted;
        final completedAt = localTask.isCompleted 
            ? (localTask.completedAt ?? cloudTask.completedAt) 
            : cloudTask.completedAt;

        mergedTasks.add(localTask.copyWith(
          isCompleted: isCompleted,
          completedAt: completedAt,
        ));
      } else {
        mergedTasks.add(localTask);
      }
    }

    return local.copyWith(tasks: mergedTasks);
  }

  /// Perform initial sync on first sign-in
  Future<void> performInitialSync(String userId) async {
    try {
      // 1. Fetch cloud data
      final cloudProgress = await _firestoreService.getUserProgress(userId);
      final cloudSchedules = await _firestoreService.getAllSchedules(userId);
      
      // 2. Fetch local data
      final localProgress = _storageService.getProgress();
      final localSchedules = _storageService.getAllSchedules();
      
      // 3. Merge UserProgress
      final mergedProgress = _mergeUserProgress(localProgress, cloudProgress);
      
      // 4. Merge DailySchedules
      final Map<String, DailySchedule> mergedSchedulesMap = {};
      final cloudSchedulesMap = {
        for (var s in cloudSchedules) _getDateKey(s.date): s
      };
      
      // Merge local into map
      for (var localSchedule in localSchedules) {
        final key = _getDateKey(localSchedule.date);
        final cloudSchedule = cloudSchedulesMap[key];
        mergedSchedulesMap[key] = _mergeDailySchedule(localSchedule, cloudSchedule)!;
        // Remove from cloud map to track what's left
        cloudSchedulesMap.remove(key);
      }
      
      // Add remaining cloud schedules that weren't in local
      for (var cloudSchedule in cloudSchedulesMap.values) {
        final key = _getDateKey(cloudSchedule.date);
        mergedSchedulesMap[key] = cloudSchedule;
      }
      
      // 5. Save everything back to both sources
      await Future.wait([
        _storageService.saveProgress(mergedProgress),
        _firestoreService.saveUserProgress(userId, mergedProgress),
      ]);
      
      if (mergedSchedulesMap.isNotEmpty) {
        final mergedList = mergedSchedulesMap.values.toList();
        
        // Save to local
        for (var schedule in mergedList) {
          await _storageService.saveSchedule(schedule);
        }
        
        // Batch save to Firestore
        await _firestoreService.batchSaveSchedules(userId, mergedList);
      }
    } catch (e) {
      throw SyncException('Failed to perform initial sync: $e');
    }
  }

  /// Generate a consistent date key
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Custom exception for sync errors
class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => message;
}
