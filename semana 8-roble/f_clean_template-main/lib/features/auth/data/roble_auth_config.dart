/// Connection settings for the official `roble` SDK.
///
/// Every value comes from `--dart-define` so the real project id and the
/// per-environment SSO redirect name never get hardcoded or committed.
/// See `.env.example` for the full list of keys. Provider secrets (Microsoft
/// client secret, etc.) live only in the Roble console, never in the app.
class RobleAuthConfig {
  const RobleAuthConfig({
    required this.baseUrl,
    required this.contractId,
    required this.ssoRedirect,
    required this.nativeCallbackScheme,
    required this.institutionalEmailDomain,
  });

  factory RobleAuthConfig.fromEnvironment() => const RobleAuthConfig(
    baseUrl: String.fromEnvironment(
      'ROBLE_BASE_URL',
      defaultValue: 'https://roble-api.test-openlab.uninorte.edu.co',
    ),
    contractId: String.fromEnvironment('ROBLE_CONTRACT_ID'),
    ssoRedirect: String.fromEnvironment('ROBLE_SSO_REDIRECT'),
    nativeCallbackScheme: String.fromEnvironment(
      'ROBLE_NATIVE_CALLBACK_SCHEME',
    ),
    institutionalEmailDomain: String.fromEnvironment(
      'INSTITUTIONAL_EMAIL_DOMAIN',
      defaultValue: 'uninorte.edu.co',
    ),
  );

  final String baseUrl;
  final String contractId;
  final String ssoRedirect;
  final String nativeCallbackScheme;
  final String institutionalEmailDomain;

  bool get isConfigured => contractId.trim().isNotEmpty;

  bool isInstitutionalEmail(String email) {
    final domain = institutionalEmailDomain.trim().toLowerCase();
    if (domain.isEmpty) return true;
    return email.trim().toLowerCase().endsWith('@$domain');
  }
}
