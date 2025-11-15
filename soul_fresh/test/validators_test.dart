import 'package:flutter_test/flutter_test.dart';
import 'package:soul/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects null', () {
      expect(Validators.email(null), equals('Email is required'));
    });

    test('rejects empty string', () {
      expect(Validators.email(''), equals('Email is required'));
    });

    test('rejects missing @ symbol', () {
      final result = Validators.email('userexample.com');
      expect(result, isNotNull);
      expect(result, contains('valid email'));
    });

    test('rejects missing domain', () {
      final result = Validators.email('user@');
      expect(result, isNotNull);
      expect(result, contains('valid email'));
    });

    test('rejects missing TLD', () {
      final result = Validators.email('user@domain');
      expect(result, isNotNull);
      expect(result, contains('valid email'));
    });

    test('rejects spaces in email', () {
      final result = Validators.email('user name@example.com');
      expect(result, isNotNull);
      expect(result, contains('valid email'));
    });

    test('accepts valid simple email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('accepts email with dots', () {
      expect(Validators.email('user.name@example.com'), isNull);
    });

    test('accepts email with plus', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('accepts email with numbers', () {
      expect(Validators.email('user123@example456.com'), isNull);
    });

    test('accepts email with subdomain', () {
      expect(Validators.email('user@mail.example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null', () {
      expect(Validators.password(null), equals('Password is required'));
    });

    test('rejects empty string', () {
      expect(Validators.password(''), equals('Password is required'));
    });

    test('rejects password shorter than 8 characters', () {
      final result = Validators.password('Abc123');
      expect(result, isNotNull);
      expect(result, contains('at least 8 characters'));
    });

    test('rejects password without uppercase', () {
      final result = Validators.password('abcdefgh123');
      expect(result, isNotNull);
      expect(result, contains('uppercase letter'));
    });

    test('rejects password without lowercase', () {
      final result = Validators.password('ABCDEFGH123');
      expect(result, isNotNull);
      expect(result, contains('lowercase letter'));
    });

    test('rejects password without number', () {
      final result = Validators.password('AbcdefghIJK');
      expect(result, isNotNull);
      expect(result, contains('number'));
    });

    test('accepts strong password with uppercase, lowercase, and number', () {
      expect(Validators.password('StrongPass123'), isNull);
    });

    test('accepts password with special characters', () {
      expect(Validators.password('StrongPass123!'), isNull);
    });

    test('accepts exactly 8 characters with all requirements', () {
      expect(Validators.password('Pass1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects null', () {
      expect(
        Validators.confirmPassword(null, 'password'),
        equals('Please confirm your password'),
      );
    });

    test('rejects empty string', () {
      expect(
        Validators.confirmPassword('', 'password'),
        equals('Please confirm your password'),
      );
    });

    test('rejects mismatched passwords', () {
      final result = Validators.confirmPassword('password1', 'password2');
      expect(result, isNotNull);
      expect(result, contains('do not match'));
    });

    test('accepts matching passwords', () {
      expect(Validators.confirmPassword('Password123', 'Password123'), isNull);
    });

    test('rejects case-sensitive mismatch', () {
      final result = Validators.confirmPassword('Password', 'password');
      expect(result, isNotNull);
      expect(result, contains('do not match'));
    });
  });

  group('Validators.otpCode', () {
    test('rejects null', () {
      expect(Validators.otpCode(null), equals('OTP code is required'));
    });

    test('rejects empty string', () {
      expect(Validators.otpCode(''), equals('OTP code is required'));
    });

    test('rejects code shorter than 6 digits', () {
      final result = Validators.otpCode('12345');
      expect(result, isNotNull);
      expect(result, contains('6-digit code'));
    });

    test('rejects code longer than 6 digits', () {
      final result = Validators.otpCode('1234567');
      expect(result, isNotNull);
      expect(result, contains('6-digit code'));
    });

    test('rejects non-numeric code', () {
      final result = Validators.otpCode('12A456');
      expect(result, isNotNull);
      expect(result, contains('6-digit code'));
    });

    test('rejects code with spaces', () {
      final result = Validators.otpCode('123 456');
      expect(result, isNotNull);
      expect(result, contains('6-digit code'));
    });

    test('accepts valid 6-digit code', () {
      expect(Validators.otpCode('123456'), isNull);
    });

    test('accepts code with all zeros', () {
      expect(Validators.otpCode('000000'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects null', () {
      expect(Validators.required(null), equals('This field is required'));
    });

    test('rejects empty string', () {
      expect(Validators.required(''), equals('This field is required'));
    });

    test('rejects whitespace-only string', () {
      expect(Validators.required('   '), equals('This field is required'));
    });

    test('accepts non-empty string', () {
      expect(Validators.required('value'), isNull);
    });

    test('uses custom field name in error message', () {
      expect(
        Validators.required(null, fieldName: 'Username'),
        equals('Username is required'),
      );
    });
  });

  group('Validators.minLength', () {
    test('rejects null', () {
      final result = Validators.minLength(null, 5);
      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    test('rejects empty string', () {
      final result = Validators.minLength('', 5);
      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    test('rejects string shorter than minimum', () {
      final result = Validators.minLength('abc', 5);
      expect(result, isNotNull);
      expect(result, contains('at least 5 characters'));
    });

    test('accepts string equal to minimum length', () {
      expect(Validators.minLength('abcde', 5), isNull);
    });

    test('accepts string longer than minimum', () {
      expect(Validators.minLength('abcdef', 5), isNull);
    });

    test('uses custom field name in error message', () {
      final result = Validators.minLength('ab', 5, fieldName: 'Title');
      expect(result, contains('Title must be at least 5 characters'));
    });
  });

  group('Validators.maxLength', () {
    test('accepts null (optional field)', () {
      expect(Validators.maxLength(null, 10), isNull);
    });

    test('accepts empty string', () {
      expect(Validators.maxLength('', 10), isNull);
    });

    test('accepts string shorter than maximum', () {
      expect(Validators.maxLength('abc', 10), isNull);
    });

    test('accepts string equal to maximum length', () {
      expect(Validators.maxLength('1234567890', 10), isNull);
    });

    test('rejects string longer than maximum', () {
      final result = Validators.maxLength('12345678901', 10);
      expect(result, isNotNull);
      expect(result, contains('must not exceed 10 characters'));
    });

    test('uses custom field name in error message', () {
      final result = Validators.maxLength('toolongtext', 5, fieldName: 'Bio');
      expect(result, contains('Bio must not exceed 5 characters'));
    });
  });

  group('Validators.phone', () {
    test('rejects null', () {
      expect(Validators.phone(null), equals('Phone number is required'));
    });

    test('rejects empty string', () {
      expect(Validators.phone(''), equals('Phone number is required'));
    });

    test('rejects phone with less than 10 digits', () {
      final result = Validators.phone('123456789');
      expect(result, isNotNull);
      expect(result, contains('valid phone number'));
    });

    test('accepts 10-digit phone', () {
      expect(Validators.phone('1234567890'), isNull);
    });

    test('accepts phone with country code', () {
      expect(Validators.phone('+11234567890'), isNull);
    });

    test('accepts phone with spaces', () {
      expect(Validators.phone('123 456 7890'), isNull);
    });

    test('accepts phone with dashes', () {
      expect(Validators.phone('123-456-7890'), isNull);
    });

    test('accepts phone with parentheses', () {
      expect(Validators.phone('(123) 456-7890'), isNull);
    });

    test('rejects phone with letters', () {
      final result = Validators.phone('12345ABCDE');
      expect(result, isNotNull);
      expect(result, contains('valid phone number'));
    });
  });

  group('Validators.numeric', () {
    test('rejects null', () {
      final result = Validators.numeric(null);
      expect(result, equals('This field is required'));
    });

    test('rejects empty string', () {
      final result = Validators.numeric('');
      expect(result, equals('This field is required'));
    });

    test('rejects non-numeric string', () {
      final result = Validators.numeric('abc');
      expect(result, isNotNull);
      expect(result, contains('must be a number'));
    });

    test('accepts integer', () {
      expect(Validators.numeric('123'), isNull);
    });

    test('accepts decimal', () {
      expect(Validators.numeric('123.45'), isNull);
    });

    test('accepts negative number', () {
      expect(Validators.numeric('-123'), isNull);
    });

    test('uses custom field name in error message', () {
      final result = Validators.numeric('abc', fieldName: 'Age');
      expect(result, contains('Age must be a number'));
    });
  });

  group('Validators.url', () {
    test('rejects null', () {
      expect(Validators.url(null), equals('URL is required'));
    });

    test('rejects empty string', () {
      expect(Validators.url(''), equals('URL is required'));
    });

    test('rejects URL without scheme', () {
      final result = Validators.url('example.com');
      expect(result, isNotNull);
      expect(result, contains('valid URL'));
    });

    test('rejects URL with invalid scheme', () {
      final result = Validators.url('ftp://example.com');
      expect(result, isNotNull);
      expect(result, contains('valid URL'));
    });

    test('accepts http URL', () {
      expect(Validators.url('http://example.com'), isNull);
    });

    test('accepts https URL', () {
      expect(Validators.url('https://example.com'), isNull);
    });

    test('accepts URL with path', () {
      expect(Validators.url('https://example.com/path/to/page'), isNull);
    });

    test('accepts URL with query parameters', () {
      expect(Validators.url('https://example.com?param=value'), isNull);
    });
  });
}
