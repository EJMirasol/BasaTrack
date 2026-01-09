import 'package:hive/hive.dart';

part 'user_progress.g.dart';

/// Tracks user's overall reading progress and streaks
@HiveType(typeId: 2)
class UserProgress extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  DateTime? lastReadDate;

  @HiveField(3)
  int totalDaysRead;

  @HiveField(4)
  int consecutiveMissedDays;

  @HiveField(5)
  DateTime? startDate;

  @HiveField(6)
  DateTime? lastWeekStreakShownDate;

  UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.totalDaysRead = 0,
    this.consecutiveMissedDays = 0,
    this.startDate,
    this.lastWeekStreakShownDate,
  });

  /// Update progress after completing a day's reading
  void completeDay(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final normalizedLastRead = lastReadDate != null
        ? _normalizeDate(lastReadDate!)
        : null;

    // If first time reading or reading after a break
    if (normalizedLastRead == null) {
      currentStreak = 1;
      consecutiveMissedDays = 0;
      startDate ??= normalizedDate;
    } else {
      final daysSinceLastRead = normalizedDate.difference(normalizedLastRead).inDays;

      if (daysSinceLastRead == 1) {
        // Reading the very next day - continue streak
        currentStreak++;
        consecutiveMissedDays = 0;
      } else if (daysSinceLastRead == 0) {
        // Same day, don't increment streak
        // Streak stays the same
      } else {
        // Missed one or more days - reset streak
        currentStreak = 1;
        consecutiveMissedDays = daysSinceLastRead - 1;
      }
    }

    lastReadDate = normalizedDate;
    totalDaysRead++;

    // Update longest streak if current is higher
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  /// Calculate missed days from last read date to today
  int calculateMissedDays() {
    if (lastReadDate == null) return 0;

    final now = _normalizeDate(DateTime.now());
    final normalizedLastRead = _normalizeDate(lastReadDate!);
    final daysSince = now.difference(normalizedLastRead).inDays;

    // If we read today or yesterday, no missed days
    if (daysSince <= 1) return 0;

    // Otherwise, missed days = days since last read - 1
    return daysSince - 1;
  }

  /// Check if streak is broken (missed more than 1 day)
  bool get isStreakBroken {
    if (lastReadDate == null) return false;
    return calculateMissedDays() > 0;
  }

  /// Reset streak due to missed days
  void breakStreak() {
    currentStreak = 0;
    consecutiveMissedDays = calculateMissedDays();
  }

  /// Normalize date to midnight for accurate day comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Create a copy with updated fields
  UserProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    int? totalDaysRead,
    int? consecutiveMissedDays,
    DateTime? startDate,
    DateTime? lastWeekStreakShownDate,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      totalDaysRead: totalDaysRead ?? this.totalDaysRead,
      consecutiveMissedDays: consecutiveMissedDays ?? this.consecutiveMissedDays,
      startDate: startDate ?? this.startDate,
      lastWeekStreakShownDate: lastWeekStreakShownDate ?? this.lastWeekStreakShownDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'totalDaysRead': totalDaysRead,
      'consecutiveMissedDays': consecutiveMissedDays,
      'startDate': startDate?.toIso8601String(),
      'lastWeekStreakShownDate': lastWeekStreakShownDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.parse(json['lastReadDate'] as String)
          : null,
      totalDaysRead: json['totalDaysRead'] as int? ?? 0,
      consecutiveMissedDays: json['consecutiveMissedDays'] as int? ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      lastWeekStreakShownDate: json['lastWeekStreakShownDate'] != null
          ? DateTime.parse(json['lastWeekStreakShownDate'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'UserProgress(streak: $currentStreak, longest: $longestStreak, total: $totalDaysRead)';
}
