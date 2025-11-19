import 'package:intl/intl.dart';

/// Date utility functions
class DateUtils {
  DateUtils._();

  /// Format date as "Monday, January 1"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// Format date as "Jan 1, 2024"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format date as "January 1"
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMMM d').format(date);
  }

  /// Get day of week name
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day);
    return normalizedTo.difference(normalizedFrom).inDays;
  }

  /// Check if dates are consecutive
  static bool areConsecutiveDays(DateTime date1, DateTime date2) {
    return daysBetween(date1, date2).abs() == 1;
  }

  /// Normalize date to midnight
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get day of year (1-365/366)
  static int getDayOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    return daysBetween(firstDayOfYear, date) + 1;
  }

  /// Get relative date string (Today, Yesterday, or date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    
    final daysAgo = daysBetween(date, DateTime.now());
    if (daysAgo > 0 && daysAgo < 7) {
      return '$daysAgo days ago';
    }
    
    return formatShortDate(date);
  }
}
