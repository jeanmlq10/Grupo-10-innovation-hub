/// Connection settings for the official `roble` SDK.
///
/// Every value comes from `--dart-define` so the real project id and the
/// per-environment SSO redirect name never get hardcoded or committed.
/// See `.env.example` at the repo root for the full list of keys and where
/// to find each value in the Roble console.
class RobleAuthConfig {
  const RobleAuthConfig({
    required this.baseUrl,
    required this.contractId,
    required this.ssoRedirect,
    required this.googleIosClientId,
    required this.institutionalEmailDomain,
  });

  factory RobleAuthConfig.fromEnvironment() => const RobleAuthConfig(
    baseUrl: String.fromEnvironment(
      'ROBLE_BASE_URL',
      defaultValue: 'https://roble-api.test-openlab.uninorte.edu.co',
    ),
    contractId: String.fromEnvironment('ROBLE_CONTRACT_ID'),
    // Name of the "destino de retorno" registered in the Roble console
    // under Usuarios > Proveedores (not a URL). Must match the build:
    // e.g. "innovation-hub-web-dev" for `flutter run -d chrome --web-port=5001`,
    // "innovation-hub-mobile" for the Android/iOS custom scheme.
    ssoRedirect: String.fromEnvironment('ROBLE_SSO_REDIRECT'),
    // Only required to sign in with Google on iOS.
    googleIosClientId: String.fromEnvironment('ROBLE_GOOGLE_IOS_CLIENT_ID'),
    // Leave empty to allow any email domain to register.
    institutionalEmailDomain: String.fromEnvironment(
      'INSTITUTIONAL_EMAIL_DOMAIN',
      defaultValue: 'uninorte.edu.co',
    ),
  );

  final String baseUrl;
  final String contractId;
  final String ssoRedirect;
  final String googleIosClientId;
  final String institutionalEmailDomain;

  bool get isConfigured => contractId.trim().isNotEmpty;

  bool isInstitutionalEmail(String email) {
    final domain = institutionalEmailDomain.trim().toLowerCase();
    if (domain.isEmpty) return true;
    return email.trim().toLowerCase().endsWith('@$domain');
  }
}
