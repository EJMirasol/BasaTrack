import 'package:flutter/foundation.dart';
import '../data/models/user_progress.dart';
import '../data/repositories/reading_repository.dart';
import '../core/constants/app_constants.dart';

/// Provider for managing streak tracking and achievements
class StreakProvider with ChangeNotifier {
  final ReadingRepository _repository;
  
  UserProgress? _progress;
  bool _showWeekStreakCelebration = false;
  bool _hasShownWeekStreakToday = false;

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
      
      // Check for week streak achievement
      if (currentStreak == AppConstants.weekStreakDays && !_hasShownWeekStreakToday) {
        _showWeekStreakCelebration = true;
        _hasShownWeekStreakToday = true;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load progress: $e');
    }
  }

  /// Dismiss week streak celebration
  void dismissWeekStreakCelebration() {
    _showWeekStreakCelebration = false;
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
