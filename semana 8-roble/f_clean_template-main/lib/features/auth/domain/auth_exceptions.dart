/// Thrown before any Roble call when required `--dart-define` configuration
/// (contract id, SSO redirect name, etc.) is missing.
class AuthConfigurationException implements Exception {
  const AuthConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A registration attempt used an email outside the configured
/// institutional domain (see [RobleAuthConfig.institutionalEmailDomain]).
class NonInstitutionalEmailException implements Exception {
  const NonInstitutionalEmailException(this.domain);

  final String domain;

  @override
  String toString() => 'El correo debe pertenecer al dominio $domain.';
}

/// Roble answered `429 Too Many Requests`. [retryAfter] is the server's
/// `Retry-After` when it could be read, otherwise null and the caller must
/// pick its own wait.
class AuthRateLimitedException implements Exception {
  const AuthRateLimitedException([this.retryAfter]);

  final Duration? retryAfter;

  @override
  String toString() =>
      'Demasiadas solicitudes. Intenta de nuevo en un momento.';
}

/// The requested social provider is not enabled in the Roble project.
class AuthProviderUnavailableException implements Exception {
  const AuthProviderUnavailableException(this.provider);

  final String provider;

  @override
  String toString() =>
      '$provider aun no esta habilitado en Roble. Pide al administrador del '
      'proyecto que lo configure.';
}
