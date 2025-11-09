import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/utils/password_strength.dart';

void main() {
  group('PasswordStrength.calculate', () {
    test('returns 0.0 for empty password', () {
      expect(PasswordStrength.calculate(''), equals(0.0));
    });

    test('gives points for length >= 8', () {
      final score = PasswordStrength.calculate('12345678');
      expect(score, greaterThanOrEqualTo(0.2));
    });

    test('gives additional points for length >= 12', () {
      final score8 = PasswordStrength.calculate('12345678');
      final score12 = PasswordStrength.calculate('123456789012');
      expect(score12, greaterThan(score8));
    });

    test('gives points for lowercase letters', () {
      final withLower = PasswordStrength.calculate('abc'); // lower = 0.2
      final without = PasswordStrength.calculate('123'); // numbers = 0.15
      // Both have points, but different features - test that lower is recognized
      expect(withLower, equals(0.2));
      expect(without, equals(0.15));
    });

    test('gives points for uppercase letters', () {
      final withUpper = PasswordStrength.calculate('ABC'); // upper = 0.2
      final without = PasswordStrength.calculate('123'); // numbers = 0.15
      // Both have points, but different features - test that upper is recognized
      expect(withUpper, equals(0.2));
      expect(without, equals(0.15));
    });

    test('gives points for numbers', () {
      final withNumbers = PasswordStrength.calculate('abcABC12');
      final withoutNumbers = PasswordStrength.calculate('abcABCde');
      expect(withNumbers, greaterThan(withoutNumbers));
    });

    test('gives points for special characters', () {
      final withSpecial = PasswordStrength.calculate('Abc123!@');
      final withoutSpecial = PasswordStrength.calculate('Abc12345');
      expect(withSpecial, greaterThan(withoutSpecial));
    });

    test('returns maximum 1.0 for very strong password', () {
      final score = PasswordStrength.calculate('VeryStrong123!@#LongPassword');
      expect(score, equals(1.0));
    });

    test('returns weak score (< 0.4) for simple password', () {
      final score = PasswordStrength.calculate('simple');
      expect(score, lessThan(0.4));
    });

    test('returns medium score (0.4-0.7) for moderate password', () {
      final score = PasswordStrength.calculate(
        'Password',
      ); // 8 chars + lower + upper = 0.55
      expect(score, greaterThanOrEqualTo(0.4));
      expect(score, lessThan(0.7));
    });

    test('returns strong score (>= 0.7) for complex password', () {
      final score = PasswordStrength.calculate('Pass123!@#');
      expect(score, greaterThanOrEqualTo(0.7));
    });
  });

  group('PasswordStrength.getLabel', () {
    test('returns empty string for empty password', () {
      expect(PasswordStrength.getLabel(''), equals(''));
    });

    test('returns "Weak" for weak password', () {
      expect(PasswordStrength.getLabel('pass'), equals('Weak'));
    });

    test('returns "Medium" for moderate password', () {
      expect(PasswordStrength.getLabel('Password'), equals('Medium'));
    });

    test('returns "Strong" for strong password', () {
      expect(PasswordStrength.getLabel('Pass123!@#'), equals('Strong'));
    });

    test('returns "Strong" for very long complex password', () {
      expect(
        PasswordStrength.getLabel('VeryLongComplexPassword123!@#'),
        equals('Strong'),
      );
    });
  });

  group('PasswordStrength.getColor', () {
    test('returns grey for empty password', () {
      expect(PasswordStrength.getColor(''), equals(Colors.grey));
    });

    test('returns red for weak password', () {
      expect(PasswordStrength.getColor('weak'), equals(Colors.red));
    });

    test('returns orange for medium password', () {
      expect(PasswordStrength.getColor('Password'), equals(Colors.orange));
    });

    test('returns green for strong password', () {
      expect(PasswordStrength.getColor('Pass123!@#'), equals(Colors.green));
    });
  });

  group('PasswordStrength.getInfo', () {
    test('returns empty label and grey for empty password', () {
      final (label, color) = PasswordStrength.getInfo('');
      expect(label, equals(''));
      expect(color, equals(Colors.grey));
    });

    test('returns "Weak" and red for weak password', () {
      final (label, color) = PasswordStrength.getInfo('weak');
      expect(label, equals('Weak'));
      expect(color, equals(Colors.red));
    });

    test('returns "Medium" and orange for medium password', () {
      final (label, color) = PasswordStrength.getInfo('Password');
      expect(label, equals('Medium'));
      expect(color, equals(Colors.orange));
    });

    test('returns "Strong" and green for strong password', () {
      final (label, color) = PasswordStrength.getInfo('Pass123!@#');
      expect(label, equals('Strong'));
      expect(color, equals(Colors.green));
    });
  });

  group('PasswordStrength.meetsMinimumRequirements', () {
    test('returns false for empty password', () {
      expect(PasswordStrength.meetsMinimumRequirements(''), isFalse);
    });

    test('returns false for weak password', () {
      expect(PasswordStrength.meetsMinimumRequirements('weak'), isFalse);
    });

    test('returns true for medium password', () {
      expect(PasswordStrength.meetsMinimumRequirements('Password'), isTrue);
    });

    test('returns true for strong password', () {
      expect(PasswordStrength.meetsMinimumRequirements('Pass123!@#'), isTrue);
    });

    test('returns true exactly at threshold (0.4)', () {
      // 8 chars (0.25) + lowercase (0.15) = 0.4
      expect(PasswordStrength.meetsMinimumRequirements('abcdefgh'), isTrue);
    });
  });

  group('PasswordStrength.getMissingRequirements', () {
    test('returns all requirements for empty password', () {
      final missing = PasswordStrength.getMissingRequirements('');
      expect(missing, hasLength(5));
      expect(missing, contains('At least 8 characters'));
      expect(missing, contains('One lowercase letter'));
      expect(missing, contains('One uppercase letter'));
      expect(missing, contains('One number'));
      expect(missing, contains('One special character'));
    });

    test('returns empty list for password meeting all requirements', () {
      final missing = PasswordStrength.getMissingRequirements('Password1!');
      expect(missing, isEmpty);
    });

    test('identifies missing length requirement', () {
      final missing = PasswordStrength.getMissingRequirements('Pass1');
      expect(missing, contains('At least 8 characters'));
    });

    test('identifies missing lowercase requirement', () {
      final missing = PasswordStrength.getMissingRequirements('PASSWORD123');
      expect(missing, contains('One lowercase letter'));
    });

    test('identifies missing uppercase requirement', () {
      final missing = PasswordStrength.getMissingRequirements('password123');
      expect(missing, contains('One uppercase letter'));
    });

    test('identifies missing number requirement', () {
      final missing = PasswordStrength.getMissingRequirements('PasswordABC');
      expect(missing, contains('One number'));
    });

    test('identifies multiple missing requirements', () {
      final missing = PasswordStrength.getMissingRequirements('pass');
      expect(missing.length, greaterThanOrEqualTo(4));
      expect(missing, contains('At least 8 characters'));
      expect(missing, contains('One uppercase letter'));
      expect(missing, contains('One number'));
      expect(missing, contains('One special character'));
    });

    test('includes special character requirement when missing', () {
      final missing = PasswordStrength.getMissingRequirements('Password1');
      expect(missing, contains('One special character'));
    });
  });

  group('PasswordStrength score thresholds', () {
    test('weak threshold is below 0.4', () {
      final score = PasswordStrength.calculate('simple');
      expect(score, lessThan(0.4));
      expect(PasswordStrength.getLabel('simple'), equals('Weak'));
    });

    test('medium threshold is 0.4 to 0.7', () {
      const password = 'Password'; // 8 chars + lower + upper = 0.55
      final score = PasswordStrength.calculate(password);
      expect(score, greaterThanOrEqualTo(0.4));
      expect(score, lessThan(0.7));
      expect(PasswordStrength.getLabel(password), equals('Medium'));
    });

    test('strong threshold is 0.7 and above', () {
      const password = 'Strong!Pass123';
      final score = PasswordStrength.calculate(password);
      expect(score, greaterThanOrEqualTo(0.7));
      expect(PasswordStrength.getLabel(password), equals('Strong'));
    });
  });
}
