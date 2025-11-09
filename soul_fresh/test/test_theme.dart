import 'package:flutter_test/flutter_test.dart';
import 'package:soul/core/theme/app_theme.dart';

void main() {
  test('app themes instantiate', () {
    expect(() => AppTheme.lightTheme, returnsNormally);
    expect(() => AppTheme.darkTheme, returnsNormally);
  });
}
