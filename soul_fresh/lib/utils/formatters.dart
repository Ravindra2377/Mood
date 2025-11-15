import 'package:intl/intl.dart';

/// Text formatting utilities
class Formatters {
  Formatters._();

  /// Format currency
  static String currency(double value, {String symbol = '\$'}) {
    return '$symbol${value.toStringAsFixed(2)}';
  }

  /// Format number with commas
  static String number(int value) {
    return NumberFormat('#,###').format(value);
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Format file size
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format phone number (US format)
  static String phoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }

    return phone;
  }

  /// Mask email (e.g., j***@example.com)
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}@$domain';
  }

  /// Format mood score with emoji
  static String moodWithEmoji(int score) {
    if (score >= 9) return '$score 😄';
    if (score >= 7) return '$score 🙂';
    if (score >= 5) return '$score 😐';
    if (score >= 3) return '$score 😟';
    return '$score 😢';
  }

  /// Convert minutes to readable time
  static String minutesToReadable(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes min';
  }

  /// Format name with initials
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Remove special characters
  static String removeSpecialChars(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Format streak count
  static String streak(int days) {
    if (days == 0) return 'Start your streak!';
    if (days == 1) return '1 day streak 🔥';
    return '$days days streak 🔥';
  }

  /// Format activity type
  static String activityType(String type) {
    switch (type.toLowerCase()) {
      case 'yoga':
        return 'Meditation 🧘';
      case 'journal':
      case 'journaling':
        return 'Journaling 📝';
      case 'meditation':
        return 'Meditation 🧘‍♀️';
      case 'exercise':
      case 'exercises':
        return 'Exercise 💪';
      case 'breathing':
        return 'Breathing 🌬️';
      default:
        return capitalizeWords(type);
    }
  }

  /// Format list to readable string
  static String listToReadable(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length == 2) return '${items[0]} and ${items[1]}';

    final allButLast = items.sublist(0, items.length - 1).join(', ');
    return '$allButLast, and ${items.last}';
  }
}
