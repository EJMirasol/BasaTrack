import 'package:flutter/foundation.dart';
import '../data/models/daily_schedule.dart';
import '../data/models/user_progress.dart';
import '../data/repositories/reading_repository.dart';
import '../data/services/notification_service.dart';

/// Provider for managing reading state
class ReadingProvider with ChangeNotifier {
  final ReadingRepository _repository;
  final NotificationService _notificationService = NotificationService();
  
  DailySchedule? _currentSchedule;
  UserProgress? _userProgress;
  bool _isLoading = false;
  String? _error;

  ReadingProvider({ReadingRepository? repository})
      : _repository = repository ?? ReadingRepository();

  // Getters
  DailySchedule? get currentSchedule => _currentSchedule;
  UserProgress? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentSchedule != null;
  
  /// Get today's reading schedule
  int get completedTasksCount => _currentSchedule?.completedCount ?? 0;
  int get totalTasksCount => _currentSchedule?.totalCount ?? 0;
  bool get allTasksCompleted => _currentSchedule?.allCompleted ?? false;
  double get completionPercentage => _currentSchedule?.completionPercentage ?? 0.0;

  /// Initialize and load today's schedule
  Future<void> loadTodaySchedule() async {
    _setLoading(true);
    _error = null;

    try {
      _currentSchedule = _repository.getTodaySchedule();
      _userProgress = _repository.getUserProgress();
      
      _updateMissedReadingNotification();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load schedule: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle task completion with animation support
  Future<void> toggleTask(String taskId, {DateTime? date}) async {
    try {
      final targetDate = date ?? _currentSchedule?.date;
      if (targetDate == null) return;

      final scheduleDate = targetDate.toIso8601String();
      await _repository.toggleTaskCompletion(scheduleDate, taskId);
      
      // Reload schedule and progress
      _currentSchedule = _repository.getTodaySchedule();
      _userProgress = _repository.getUserProgress();
      
      _updateMissedReadingNotification();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle task: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Update missed reading notification based on current backlog
  void _updateMissedReadingNotification() {
    final missedCount = _repository.getIncompleteMissedDaysCount();
    _notificationService.scheduleMissedReadingReminder(missedCount);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadTodaySchedule();
  }

  /// Check if there's a new week streak achievement
  bool hasWeekStreakAchievement() {
    return _repository.hasNewWeekStreakAchievement();
  }

  /// Get missed days count
  int getMissedDays() {
    return _repository.getMissedDaysCount();
  }

  /// Get current streak
  int getCurrentStreak() {
    return _userProgress?.currentStreak ?? 0;
  }

  /// Get longest streak
  int getLongestStreak() {
    return _userProgress?.longestStreak ?? 0;
  }

  /// Get current week's schedules (7 days: Sunday to Saturday)
  List<DailySchedule> getWeekSchedules() {
    return _repository.getCurrentWeekSchedules();
  }

  /// Get week completion status for calendar (7 booleans)
  List<bool> getWeekCompletionStatus() {
    final weekSchedules = getWeekSchedules();
    return weekSchedules.map((schedule) => schedule.allCompleted).toList();
  }

  /// Get current day index in week (0=Sunday/LD, 6=Saturday)
  int getCurrentDayIndex() {
    final now = DateTime.now();
    return now.weekday % 7; // Sun=0, Mon=1, ..., Sat=6
  }

  /// Get all missed schedules (past incomplete days)
  List<DailySchedule> getMissedSchedules() {
    return _repository.getMissedSchedules();
  }

  /// Check if there are incomplete missed days (for reminder card)
  bool hasIncompleteMissedDays() {
    return _repository.getIncompleteMissedDaysCount() > 0;
  }

  /// Get count of incomplete missed days
  int getIncompleteMissedDaysCount() {
    return _repository.getIncompleteMissedDaysCount();
  }

  /// Get total tasks completed across all time
  int getTotalCompletedTasksCount() {
    return _repository.getTotalCompletedTasksCount();
  }

  /// Get total number of days with at least one completed task
  int getTotalDaysRead() {
    return _repository.getTotalDaysRead();
  }

  /// Get total week streaks completed
  int getTotalWeekStreaksCount() {
    return _repository.getTotalWeekStreaksCount();
  }

  /// Get total OT tasks completed
  int getOTCompletedCount() {
    return _repository.getOTCompletedCount();
  }

  /// Get total NT tasks completed
  int getNTCompletedCount() {
    return _repository.getNTCompletedCount();
  }

  /// Reset all data (for testing)
  Future<void> resetAllData() async {
    await _repository.resetAll();
    await loadTodaySchedule();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
