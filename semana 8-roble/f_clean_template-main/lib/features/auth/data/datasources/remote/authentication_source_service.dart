import 'package:roble/roble.dart';

import '../../../domain/auth_exceptions.dart';
import '../../../domain/models/authentication_user.dart';
import '../../roble_auth_config.dart';
import 'i_authentication_source.dart';

/// Thin adapter over the official `roble` SDK ([RobleApiDataBase]).
///
/// This class intentionally has almost no logic of its own: session
/// persistence, token renewal and the Google/Microsoft OAuth exchange are
/// all handled inside the SDK. What is left here is (1) turning the
/// `--dart-define` config into a [RobleApiDataBase], (2) mapping the
/// `Map<String, dynamic>` profile Roble returns into [AuthenticationUser],
/// and (3) the institutional-email business rule, which is specific to
/// this app and not something Roble enforces.
class AuthenticationSourceService implements IAuthenticationSource {
  AuthenticationSourceService({
    RobleApiDataBase? client,
    RobleAuthConfig? config,
  }) : config = config ?? RobleAuthConfig.fromEnvironment(),
       _injectedClient = client;

  final RobleAuthConfig config;
  final RobleApiDataBase? _injectedClient;
  RobleApiDataBase? _lazyClient;

  /// Built on first real use rather than in the constructor, so the app
  /// (and widget tests) can still render the login screen with no
  /// `ROBLE_CONTRACT_ID` configured — the clear [AuthConfigurationException]
  /// only surfaces once the user actually tries to log in.
  RobleApiDataBase get _client {
    if (_injectedClient != null) return _injectedClient;
    if (!config.isConfigured) {
      throw const AuthConfigurationException(
        'Falta configurar ROBLE_CONTRACT_ID. No se puede iniciar sesion '
        'contra Roble sin el identificador del proyecto.',
      );
    }
    return _lazyClient ??= RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: config.baseUrl,
        contractId: config.contractId,
      ),
      googleIosClientId: config.googleIosClientId.trim().isEmpty
          ? null
          : config.googleIosClientId,
      ssoRedirect: config.ssoRedirect.trim().isEmpty
          ? null
          : config.ssoRedirect,
    );
  }

  @override
  Future<AuthenticationUser> login(String email, String password) async {
    final profile = await _client.login(
      email: email.trim(),
      password: password,
    );
    return AuthenticationUser.fromProfile(profile);
  }

  @override
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) async {
    if (!config.isInstitutionalEmail(email)) {
      throw NonInstitutionalEmailException(config.institutionalEmailDomain);
    }
    await _client.registerWithVerification(
      email: email.trim(),
      password: password,
      name: name.trim(),
      extra: extra,
    );
  }

  @override
  Future<void> verifyEmail(String email, String code) =>
      _client.verifyEmail(email: email.trim(), code: code.trim());

  @override
  Future<void> resendCode(String email) =>
      _client.resendCode(email: email.trim());

  @override
  Future<AuthenticationUser> signInWithGoogle() async {
    final profile = await _client.signInWithGoogle();
    return AuthenticationUser.fromProfile(profile);
  }

  @override
  bool get isLoggedIn => _client.isLoggedIn;

  @override
  Future<bool> restoreSession() => _client.restoreSession();

  @override
  Future<AuthenticationUser?> currentUser() async {
    if (!_client.isLoggedIn) return null;
    final profile = await _client.currentUser();
    return AuthenticationUser.fromProfile(profile);
  }

  @override
  Future<void> logOut() => _client.logout();

  @override
  Future<void> forgotPassword(String email) =>
      _client.forgotPassword(email: email.trim());

  @override
  Future<void> resetPassword(String token, String newPassword) =>
      _client.resetPassword(token: token.trim(), newPassword: newPassword);
}
