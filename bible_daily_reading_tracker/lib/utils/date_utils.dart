import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

/// Date utility functions
class DateUtils {
  DateUtils._();

  /// The official start date of the reading plan
  static final DateTime planStartDate = DateTime(
    AppConstants.planStartYear,
    AppConstants.planStartMonth,
    AppConstants.planStartDay,
  );

  /// Calculate days since the official plan start date
  static int getPlanDay(DateTime date) {
    final normalizedDate = normalizeDate(date);
    final normalizedStart = normalizeDate(planStartDate);
    
    final daysSince = daysBetween(normalizedStart, normalizedDate);
    
    // If before start date, return 1
    if (daysSince < 0) return 1;
    
    // Cycle every 104 weeks (728 days)
    return (daysSince % 728) + 1;
  }

  /// Get the plan week number (1-104)
  static int getPlanWeek(DateTime date) {
    final dayOfPlan = getPlanDay(date);
    return ((dayOfPlan - 1) ~/ 7) + 1;
  }

  /// Get day of week within the plan (1-7, where 1 = Lord's Day)
  static int getPlanDayOfWeek(DateTime date) {
    final dayOfPlan = getPlanDay(date);
    return ((dayOfPlan - 1) % 7) + 1;
  }

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

  /// Get the first Sunday (Lord's Day) of January for a given year
  /// This is used as the starting point for the reading plan (week 1, day 1)
  static DateTime getFirstSundayOfJanuary(int year) {
    // Start with January 1
    DateTime date = DateTime(year, 1, 1);
    
    // weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // We want to find the first Sunday (weekday == 7)
    while (date.weekday != DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    
    return date;
  }

  /// Calculate days since the first Sunday of January for a given date
  /// Returns the number of days (1-based) from the first Sunday
  static int getDaysSinceFirstSunday(DateTime date) {
    final firstSunday = getFirstSundayOfJanuary(date.year);
    final normalizedDate = normalizeDate(date);
    final normalizedFirstSunday = normalizeDate(firstSunday);
    
    final daysSince = daysBetween(normalizedFirstSunday, normalizedDate);
    
    // If date is before first Sunday, return 0 (will be handled as day 1 in repository)
    if (daysSince < 0) {
      return 0;
    }
    
    // Return 1-based day count (day 1 = first Sunday)
    return daysSince + 1;
  }
}
