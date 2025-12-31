/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'BasaTrack';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String hiveBoxSchedules = 'schedules';
  static const String hiveBoxProgress = 'progress';
  static const String keyUserProgress = 'user_progress';

  // Streak Milestones
  static const int weekStreakDays = 7;
  static const int monthStreakDays = 30;
  static const int yearStreakDays = 365;

  // Messages
  static const String successMessage = 
      "Well done! You've made it for today. Please come again tomorrow.";
  static const String weekStreakMessage = 
      "🎉 Amazing! You have read straight for a week!";
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // UI Constants
  static const double cardElevation = 2.0;
  static const double borderRadius = 16.0;
  static const double iconSize = 24.0;
  static const double spacing = 16.0;

  // Reading Plan
  static const int planStartYear = 2026;
  static const int planStartMonth = 1; // January
  static const int planStartDay = 4; // January 4
}
