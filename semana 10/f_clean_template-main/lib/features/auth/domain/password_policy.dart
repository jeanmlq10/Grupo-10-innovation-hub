/// The password rule Roble enforces on sign-up and password reset:
/// "mínimo 8 caracteres, una mayúscula, una minúscula, un número y un símbolo
/// permitido (!, @, #, $, _, -)".
///
/// Checking it on the client means a weak password never becomes a request.
/// That matters because Roble rate-limits sign-up to 5 requests per hour, and
/// every rejected attempt counts against it.
///
/// Never apply this to login: existing passwords must be sent as typed.
class PasswordPolicy {
  const PasswordPolicy._();

  static const int minLength = 8;
  static const String allowedSymbols = r'!@#$_-';

  /// Returns a user-facing message for the first broken rule, or null.
  static String? validate(String password) {
    if (password.length < minLength) {
      return 'La contrasena debe tener minimo $minLength caracteres.';
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'La contrasena debe incluir una mayuscula.';
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return 'La contrasena debe incluir una minuscula.';
    }
    if (!password.contains(RegExp('[0-9]'))) {
      return 'La contrasena debe incluir un numero.';
    }
    if (!password.split('').any(allowedSymbols.contains)) {
      return 'La contrasena debe incluir un simbolo: '
          '${allowedSymbols.split('').join(' ')}';
    }
    return null;
  }
}
