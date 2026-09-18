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
