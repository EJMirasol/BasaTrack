import 'package:flutter/foundation.dart';
import '../data/models/user_progress.dart';
import '../data/repositories/reading_repository.dart';
import '../core/constants/app_constants.dart';
import '../utils/date_utils.dart' as app_date_utils;

/// Provider for managing streak tracking and achievements
class StreakProvider with ChangeNotifier {
  final ReadingRepository _repository;
  
  UserProgress? _progress;
  bool _showWeekStreakCelebration = false;

  StreakProvider({ReadingRepository? repository})
      : _repository = repository ?? ReadingRepository();

  // Getters
  int get currentStreak => _progress?.currentStreak ?? 0;
  int get longestStreak => _progress?.longestStreak ?? 0;
  int get totalDaysRead => _progress?.totalDaysRead ?? 0;
  int get missedDays => _progress?.calculateMissedDays() ?? 0;
  bool get showWeekStreakCelebration => _showWeekStreakCelebration;
  bool get hasActiveStreak => currentStreak > 0;
  
  /// Check if user achieved a week streak
  bool get hasWeekStreak => currentStreak >= AppConstants.weekStreakDays;
  
  /// Get streak status message
  String get streakMessage {
    if (currentStreak == 0) {
      return 'Start your reading journey today!';
    } else if (currentStreak == 1) {
      return 'Great start! Keep going!';
    } else if (currentStreak < AppConstants.weekStreakDays) {
      final daysToWeek = AppConstants.weekStreakDays - currentStreak;
      return '$daysToWeek more day${daysToWeek == 1 ? '' : 's'} to a week streak!';
    } else if (currentStreak == AppConstants.weekStreakDays) {
      return AppConstants.weekStreakMessage;
    } else {
      return '$currentStreak day streak! Amazing!';
    }
  }

  /// Load progress data
  Future<void> loadProgress() async {
    try {
      _progress = _repository.getUserProgress();
      
      // Reset celebration status at the start of check
      _showWeekStreakCelebration = false;
      
      // Check for week streak achievement
      // Show if currentStreak >= 7 AND it's Saturday
      // AND we haven't shown it for this SPECIFIC week yet
      final lastShownDate = _progress?.lastWeekStreakShownDate;
      final today = DateTime.now();
      final isSaturday = today.weekday == DateTime.saturday;
      
      bool alreadyShownThisWeek = false;
      if (lastShownDate != null) {
        // Calculate week indices from plan start (continuous across years)
        final todayWeek = app_date_utils.DateUtils.getPlanWeek(today);
        final shownWeek = app_date_utils.DateUtils.getPlanWeek(lastShownDate);
        
        alreadyShownThisWeek = (todayWeek == shownWeek);
      }
      
      if (isSaturday && currentStreak >= AppConstants.weekStreakDays && !alreadyShownThisWeek) {
        _showWeekStreakCelebration = true;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load progress: $e');
    }
  }

  /// Dismiss week streak celebration
  Future<void> dismissWeekStreakCelebration() async {
    _showWeekStreakCelebration = false;
    
    // Save that we've shown the celebration for this current week
    if (_progress != null) {
      _progress!.lastWeekStreakShownDate = DateTime.now();
      await _repository.updateProgress(_progress!);
    }
    
    notifyListeners();
  }

  /// Refresh progress
  Future<void> refresh() async {
    await loadProgress();
  }

  /// Get streak color based on current streak
  int getStreakColor() {
    if (currentStreak == 0) return 0xFF757575; // Grey
    if (currentStreak < 7) return 0xFF4A90E2; // Blue
    if (currentStreak < 30) return 0xFFFFD700; // Gold
    if (currentStreak < 100) return 0xFFFF6B35; // Orange
    return 0xFFE63946; // Red (legendary)
  }

  /// Get streak icon based on current streak
  String getStreakIcon() {
    if (currentStreak == 0) return '📖';
    if (currentStreak < 7) return '🔥';
    if (currentStreak < 30) return '⭐';
    if (currentStreak < 100) return '🏆';
    return '👑'; // Legendary
  }

  /// Get encouragement message for missed days
  String getMissedDaysMessage() {
    if (missedDays == 0) return '';
    if (missedDays == 1) {
      return 'You missed yesterday. Don\'t break the rhythm!';
    }
    return 'You have missed for $missedDays days. Let\'s get back on track!';
  }
}
