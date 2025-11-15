import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date and time formatting utilities
class AppDateUtils {
  AppDateUtils._();

  /// Format date as 'Jan 15, 2025'
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format date as '15 January 2025'
  static String formatDateLong(DateTime date) {
    return DateFormat('d MMMM y').format(date);
  }

  /// Format date as '01/15/2025'
  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd/y').format(date);
  }

  /// Format time as '2:30 PM'
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date and time as 'Jan 15, 2025 at 2:30 PM'
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(date);
  }

  /// Format as 'Today', 'Yesterday', or date
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else if (inputDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return formatDate(date);
    }
  }

  /// Format as '2 hours ago', '5 minutes ago', etc.
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get date range for a specific filter
  static DateTimeRange getDateRangeForFilter(String filter) {
    final now = DateTime.now();

    switch (filter.toLowerCase()) {
      case 'today':
        return DateTimeRange(
          start: startOfDay(now),
          end: endOfDay(now),
        );
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: startOfDay(yesterday),
          end: endOfDay(yesterday),
        );
      case 'this week':
      case 'week':
        return DateTimeRange(
          start: startOfWeek(now),
          end: endOfWeek(now),
        );
      case 'last week':
        final lastWeek = now.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: startOfWeek(lastWeek),
          end: endOfWeek(lastWeek),
        );
      case 'this month':
      case 'month':
        return DateTimeRange(
          start: startOfMonth(now),
          end: endOfMonth(now),
        );
      case 'last month':
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        return DateTimeRange(
          start: startOfMonth(lastMonth),
          end: endOfMonth(lastMonth),
        );
      case 'this year':
      case 'year':
        return DateTimeRange(
          start: DateTime(now.year),
          end: DateTime(now.year, 12, 31, 23, 59, 59, 999),
        );
      case 'last 7 days':
        return DateTimeRange(
          start: startOfDay(now.subtract(const Duration(days: 7))),
          end: endOfDay(now),
        );
      case 'last 30 days':
        return DateTimeRange(
          start: startOfDay(now.subtract(const Duration(days: 30))),
          end: endOfDay(now),
        );
      default:
        return DateTimeRange(
          start: startOfDay(now),
          end: endOfDay(now),
        );
    }
  }

  /// Format duration as '2h 30m'
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Parse ISO 8601 date string
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format date for API (ISO 8601)
  static String toIso8601(DateTime date) {
    return date.toIso8601String();
  }
}
