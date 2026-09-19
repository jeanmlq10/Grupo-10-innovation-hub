import 'package:roble/roble.dart';

import '../features/auth/domain/auth_exceptions.dart';

/// Turns an exception into a message safe to show a user — never the raw
/// exception text, which could leak internal details from Roble.
String errorMessage(Object error, {String? fallback}) {
  if (error is AuthConfigurationException) return error.message;
  if (error is NonInstitutionalEmailException) return error.toString();
  if (error is AuthProviderUnavailableException) return error.toString();
  if (error is AuthRateLimitedException) return error.toString();

  if (error is RobleApiForbiddenException) {
    return 'Tu cuenta no tiene permiso para hacer esto.';
  }
  if (error is RobleApiNotFoundException) {
    return 'No encontramos lo que buscas, o ya no es tuyo.';
  }
  if (error is RobleApiConflictException) {
    return 'Ya existe una cuenta con ese correo. Inicia sesion con el metodo '
        'con el que la creaste.';
  }
  if (error is RobleApiHttpException) {
    if (error.statusCode == 401) {
      return 'Correo o contrasena incorrectos.';
    }
    // 4xx are Roble's own field/rule validation (e.g. password complexity or
    // "El correo ya está registrado"), already written to be shown to the end
    // user. Only 5xx falls back to a generic message, since that is an
    // internal/unexpected server failure.
    if (error.statusCode >= 400 && error.statusCode < 500) {
      final message = _unwrap(error.message);
      if (message.isNotEmpty) return message;
    }
    return 'Roble no pudo procesar la solicitud. Intenta de nuevo.';
  }
  if (error is RobleApiAuthException) {
    return 'No se pudo completar el inicio de sesion (sesion expirada, '
        'ventana bloqueada o cancelada). Vuelve a intentarlo.';
  }
  if (error is RobleApiTimeoutException) {
    return 'Roble tardo demasiado en responder. Intenta de nuevo.';
  }
  if (error is RobleApiNetworkException) {
    return 'No pudimos contactar Roble. Revisa tu conexion.';
  }
  if (error is RobleApiException) return error.message;
  if (error is StateError) return error.message;

  return fallback ?? 'Ocurrio un error inesperado. Intenta de nuevo.';
}

/// Roble sometimes reports validation errors as a JSON array, which the SDK
/// stringifies as `[msg]`; show just the text.
String _unwrap(String message) {
  final text = message.trim();
  if (text.startsWith('[') && text.endsWith(']')) {
    return text.substring(1, text.length - 1).trim();
  }
  return text;
}
