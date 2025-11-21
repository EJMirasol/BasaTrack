import '../models/daily_schedule.dart';
import '../models/user_progress.dart';
import '../data_sources/reading_plan_data.dart';
import 'storage_service.dart';

/// Repository for managing reading data with business logic
class ReadingRepository {
  final StorageService _storageService;

  ReadingRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  /// Get today's reading schedule
  /// Creates a new schedule if one doesn't exist
  DailySchedule getTodaySchedule() {
    final today = DateTime.now();
    return getScheduleForDate(today);
  }

  /// Get schedule for a specific date
  DailySchedule getScheduleForDate(DateTime date) {
    // Check if schedule exists in storage
    var schedule = _storageService.getSchedule(date);
    
    if (schedule == null) {
      // Create new schedule from reading plan
      schedule = _createScheduleForDate(date);
      _storageService.saveSchedule(schedule);
    }
    
    return schedule;
  }

  /// Create a new schedule for a given date
  DailySchedule _createScheduleForDate(DateTime date) {
    final dayOfPlan = _getDayOfPlan(date);
    final readings = ReadingPlanData.getReadingsForDay(dayOfPlan);
    
    return DailySchedule(
      date: _normalizeDate(date),
      tasks: readings,
    );
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String scheduleDate, String taskId) async {
    final date = DateTime.parse(scheduleDate);
    final schedule = getScheduleForDate(date);
    
    // Find and toggle the task
    final task = schedule.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found: $taskId'),
    );
    
    final wasAllCompleted = schedule.allCompleted;
    task.toggleCompletion();
    final isNowAllCompleted = schedule.allCompleted;
    
    // Save updated schedule
    await _storageService.saveSchedule(schedule);
    
    // Only process for today's date
    if (_isToday(date)) {
      if (!wasAllCompleted && isNowAllCompleted) {
        // Completed all tasks → increment
        await _updateProgressForCompletedDay(date);
      } else if (wasAllCompleted && !isNowAllCompleted) {
        // Unchecked a task after completing all → decrement
        await _removeProgressForDay(date);
      }
    }
  }

  /// Mark task as completed
  Future<void> completeTask(DateTime date, String taskId) async {
    final schedule = getScheduleForDate(date);
    
    final task = schedule.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found: $taskId'),
    );
    
    if (!task.isCompleted) {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      await _storageService.saveSchedule(schedule);
      
      // Update progress if all tasks completed and it's today
      if (schedule.allCompleted && _isToday(date)) {
        await _updateProgressForCompletedDay(date);
      }
    }
  }

  /// Update user progress after completing a day
  Future<void> _updateProgressForCompletedDay(DateTime date) async {
    final progress = getUserProgress();
    
    // Only update if this day hasn't been counted yet
    final normalizedDate = _normalizeDate(date);
    final normalizedLastRead = progress.lastReadDate != null 
        ? _normalizeDate(progress.lastReadDate!)
        : null;
    
    // Only count if this is a new completion (not already counted today)
    if (normalizedLastRead == null || !_isSameDay(normalizedDate, normalizedLastRead)) {
      progress.completeDay(date);
      await _storageService.saveProgress(progress);
    }
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Remove progress for a day (when unchecking tasks)
  Future<void> _removeProgressForDay(DateTime date) async {
    final progress = getUserProgress();
    final normalizedDate = _normalizeDate(date);
    final normalizedLastRead = progress.lastReadDate != null 
        ? _normalizeDate(progress.lastReadDate!)
        : null;
    
    // Only remove if this was the last completed day
    if (normalizedLastRead != null && _isSameDay(normalizedDate, normalizedLastRead)) {
      // Decrement streak
      if (progress.currentStreak > 0) {
        progress.currentStreak--;
      }
      
      // If streak is now 0, clear last read date
      if (progress.currentStreak == 0) {
        progress.lastReadDate = null;
      } else {
        // Find the previous completed date from schedules
        // For simplicity, just move last read date back by 1 day
        // In a full implementation, you'd track all completed dates
        final previousDate = normalizedLastRead.subtract(const Duration(days: 1));
        progress.lastReadDate = previousDate;
      }
      
      await _storageService.saveProgress(progress);
    }
  }

  /// Get user progress
  UserProgress getUserProgress() {
    var progress = _storageService.getProgress();
    
    // Check if streak should be broken due to missed days
    if (progress.isStreakBroken) {
      progress.breakStreak();
      _storageService.saveProgress(progress);
    }
    
    return progress;
  }

  /// Update user progress
  Future<void> updateProgress(UserProgress progress) async {
    await _storageService.saveProgress(progress);
  }

  /// Check if user has achieved 7-day streak (returns true only once)
  bool hasNewWeekStreakAchievement() {
    final progress = getUserProgress();
    return progress.currentStreak == 7;
  }

  /// Get missed days count
  int getMissedDaysCount() {
    final progress = getUserProgress();
    return progress.calculateMissedDays();
  }

  /// Get current streak
  int getCurrentStreak() {
    final progress = getUserProgress();
    return progress.currentStreak;
  }

  /// Reset all data (for testing)
  Future<void> resetAll() async {
    await _storageService.clearAll();
  }

  /// Get day of plan (1-728) based on start date of January 4
  int _getDayOfPlan(DateTime date) {
    // Plan starts on January 4 of the current year
    final startDate = DateTime(date.year, 1, 4);
    final daysSinceStart = date.difference(startDate).inDays + 1;
    
    // If before start date, use day 1
    if (daysSinceStart < 1) {
      return 1;
    }
    
    return ((daysSinceStart - 1) % 728) + 1; // Cycle through 728 days
  }

  /// Normalize date to midnight
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
