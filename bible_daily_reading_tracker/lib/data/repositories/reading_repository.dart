import '../models/daily_schedule.dart';
import '../models/reading_task.dart';
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
    final dayOfYear = _getDayOfYear(date);
    final readings = ReadingPlanData.getReadingsForDay(dayOfYear);
    
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
    
    task.toggleCompletion();
    
    // Save updated schedule
    await _storageService.saveSchedule(schedule);
    
    // Update user progress if all tasks completed
    if (schedule.allCompleted) {
      await _updateProgressForCompletedDay(date);
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
      
      // Update progress if all tasks completed
      if (schedule.allCompleted) {
        await _updateProgressForCompletedDay(date);
      }
    }
  }

  /// Update user progress after completing a day
  Future<void> _updateProgressForCompletedDay(DateTime date) async {
    final progress = getUserProgress();
    progress.completeDay(date);
    await _storageService.saveProgress(progress);
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

  /// Get day of year (1-365/366)
  int _getDayOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(firstDayOfYear).inDays;
    return difference + 1;
  }

  /// Normalize date to midnight
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
