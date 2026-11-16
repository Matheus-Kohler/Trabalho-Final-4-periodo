import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_manager/core/utils/validators.dart';

void main() {
  group('AppValidators.requiredField', () {
    test('rejects empty and whitespace-only values', () {
      expect(AppValidators.requiredField(null), isNotNull);
      expect(AppValidators.requiredField('   '), isNotNull);
    });

    test('accepts a non-empty value', () {
      expect(AppValidators.requiredField('Aventura'), isNull);
    });
  });

  group('AppValidators.email', () {
    test('rejects missing and malformed e-mails', () {
      expect(AppValidators.email(null), isNotNull);
      expect(AppValidators.email('jogador'), isNotNull);
    });

    test('accepts a valid e-mail', () {
      expect(AppValidators.email('jogador@example.com'), isNull);
    });
  });

  group('AppValidators.numeric fields', () {
    test('validates integer values', () {
      expect(AppValidators.integerNumber('12'), isNull);
      expect(AppValidators.integerNumber('12.5'), isNotNull);
    });

    test('validates non-negative decimal values with comma or period', () {
      expect(AppValidators.positiveNumber('0'), isNull);
      expect(AppValidators.positiveNumber('12,50'), isNull);
      expect(AppValidators.positiveNumber('-1'), isNotNull);
      expect(AppValidators.positiveNumber('abc'), isNotNull);
    });
  });

  test('validates minimum text length', () {
    expect(AppValidators.minLength('RPG', 3), isNull);
    expect(AppValidators.minLength('ab', 3), isNotNull);
  });
}
