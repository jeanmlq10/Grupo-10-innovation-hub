import 'package:f_clean_template/core/errors/app_failure.dart';

/// Thrown before any Roble call when required `--dart-define` configuration
/// (contract id, SSO redirect name, etc.) is missing.
class AuthConfigurationException extends AppFailure {
  const AuthConfigurationException(super.message);
}

/// A registration attempt used an email outside the configured
/// institutional domain (see [RobleAuthConfig.institutionalEmailDomain]).
class NonInstitutionalEmailException extends AppFailure {
  const NonInstitutionalEmailException(this.domain)
    : super('El correo debe pertenecer al dominio institucional.');

  final String domain;

  @override
  String toString() => 'El correo debe pertenecer al dominio $domain.';
}

/// Roble answered `429 Too Many Requests`. [retryAfter] is the server's
/// `Retry-After` when it could be read, otherwise null and the caller must
/// pick its own wait.
class AuthRateLimitedException extends AppFailure {
  const AuthRateLimitedException([this.retryAfter])
    : super('Demasiadas solicitudes. Intenta de nuevo en un momento.');

  final Duration? retryAfter;

  @override
  String toString() =>
      'Demasiadas solicitudes. Intenta de nuevo en un momento.';
}

/// The requested social provider is not enabled in the Roble project.
class AuthProviderUnavailableException extends AppFailure {
  const AuthProviderUnavailableException(this.provider)
    : super('Proveedor no habilitado en Roble.');

  final String provider;

  @override
  String toString() =>
      '$provider aun no esta habilitado en Roble. Pide al administrador del '
      'proyecto que lo configure.';
}
