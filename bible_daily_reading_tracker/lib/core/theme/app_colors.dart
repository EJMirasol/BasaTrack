import 'package:flutter/material.dart';

/// App-wide color palette with uplifting, peaceful colors
class AppColors {
  AppColors._();

  // Primary Colors - Peaceful Blue
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFF7FB3F0);
  static const Color primaryDark = Color(0xFF2E5C8A);

  // Secondary Colors - Warm Gold
  static const Color secondary = Color(0xFFFFD700);
  static const Color secondaryLight = Color(0xFFFFE44D);
  static const Color secondaryDark = Color(0xFFDAA520);

  // Success Colors - Encouraging Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  // Warning Colors - Gentle Orange
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Error Colors - Soft Red
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE3F2FD),
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );

  // Streak Achievement Colors
  static const Color streakBronze = Color(0xFFCD7F32);
  static const Color streakSilver = Color(0xFFC0C0C0);
  static const Color streakGold = Color(0xFFFFD700);
  static const Color streakPlatinum = Color(0xFFE5E4E2);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF0F3460);

  // Shadow Colors
  static final Color shadowLight = Colors.black.withOpacity(0.1);
  static final Color shadowDark = Colors.black.withOpacity(0.3);
}
