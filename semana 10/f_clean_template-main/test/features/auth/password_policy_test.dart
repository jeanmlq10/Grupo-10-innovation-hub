import 'package:f_clean_template/features/auth/domain/password_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordPolicy (mirrors the rule Roble enforces)', () {
    test('accepts a compliant password', () {
      expect(PasswordPolicy.validate('Password1!'), isNull);
      expect(PasswordPolicy.validate('Abcdef1_'), isNull);
      expect(PasswordPolicy.validate('Abcdef1-'), isNull);
      expect(PasswordPolicy.validate(r'Abcdef1$'), isNull);
      expect(PasswordPolicy.validate('Abcdef1@'), isNull);
      expect(PasswordPolicy.validate('Abcdef1#'), isNull);
    });

    test('rejects fewer than 8 characters', () {
      expect(PasswordPolicy.validate('Ab1!xyz'), isNotNull);
    });

    test('rejects a missing uppercase letter', () {
      expect(PasswordPolicy.validate('password1!'), contains('mayuscula'));
    });

    test('rejects a missing lowercase letter', () {
      expect(PasswordPolicy.validate('PASSWORD1!'), contains('minuscula'));
    });

    test('rejects a missing digit', () {
      expect(PasswordPolicy.validate('Password!!'), contains('numero'));
    });

    test('rejects a symbol outside the allowed set', () {
      expect(PasswordPolicy.validate('Password1%'), contains('simbolo'));
      expect(PasswordPolicy.validate('Password1.'), contains('simbolo'));
    });
  });
}
