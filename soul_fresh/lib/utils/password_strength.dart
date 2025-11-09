import 'package:flutter/material.dart';

/// Password strength calculator utility
class PasswordStrength {
  PasswordStrength._();

  static final RegExp _lowerRegex = RegExp(r'[a-z]');
  static final RegExp _upperRegex = RegExp(r'[A-Z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]');

  /// Calculate password strength score (0.0 to 1.0)
  static double calculate(String password) {
    if (password.isEmpty) {
      return 0;
    }

    double strength = 0;
    if (password.length >= 8) {
      strength += 0.2;
      if (password.length >= 12) {
        strength += 0.1;
      }
    }
    if (_lowerRegex.hasMatch(password)) strength += 0.2;
    if (_upperRegex.hasMatch(password)) strength += 0.2;
    if (_digitRegex.hasMatch(password)) strength += 0.15;
    if (_specialCharRegex.hasMatch(password)) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  /// Get password strength label based on score
  static String getLabel(String password) {
    if (password.isEmpty) return '';
    final strength = calculate(password);
    if (strength < 0.4) {
      return 'Weak';
    } else if (strength < 0.7) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  /// Get password strength color based on score
  static Color getColor(String password) {
    if (password.isEmpty) return Colors.grey;
    final strength = calculate(password);
    if (strength < 0.4) {
      return Colors.red;
    } else if (strength < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Get both label and color as a record
  static (String label, Color color) getInfo(String password) {
    return (getLabel(password), getColor(password));
  }

  /// Check if password meets minimum strength requirements
  static bool meetsMinimumRequirements(String password) {
    return calculate(password) >= 0.4;
  }

  /// Get list of missing requirements for a password
  static List<String> getMissingRequirements(String password) {
    final missing = <String>[];

    if (password.length < 8) {
      missing.add('At least 8 characters');
    }
    if (!_lowerRegex.hasMatch(password)) {
      missing.add('One lowercase letter');
    }
    if (!_upperRegex.hasMatch(password)) {
      missing.add('One uppercase letter');
    }
    if (!_digitRegex.hasMatch(password)) {
      missing.add('One number');
    }
    if (!_specialCharRegex.hasMatch(password)) {
      missing.add('One special character');
    }

    return missing;
  }
}
