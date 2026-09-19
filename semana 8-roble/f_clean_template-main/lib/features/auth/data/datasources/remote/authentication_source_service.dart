import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:roble/roble.dart';

import '../../../domain/auth_exceptions.dart';
import '../../../domain/models/authentication_user.dart';
import '../../retry_after_client.dart';
import '../../retry_policy.dart';
import '../../roble_auth_config.dart';
import 'i_authentication_source.dart';

/// Thin adapter over the official `roble` SDK ([RobleApiDataBase]).
///
/// Session persistence, token renewal and the Microsoft OAuth exchange are
/// handled inside the SDK. What is left here is (1) building one single
/// [RobleApiDataBase] from the `--dart-define` config, (2) mapping the profile
/// map Roble returns into [AuthenticationUser], (3) normalizing emails, (4)
/// translating `429` into [AuthRateLimitedException], and (5) the
/// institutional-email business rule, which Roble does not enforce.
class AuthenticationSourceService implements IAuthenticationSource {
  AuthenticationSourceService({
    RobleApiDataBase? client,
    RobleAuthConfig? config,
    this.retryPolicy = const RetryPolicy(),
  }) : config = config ?? RobleAuthConfig.fromEnvironment(),
       _injectedClient = client;

  final RobleAuthConfig config;
  final RobleApiDataBase? _injectedClient;
  final RetryPolicy retryPolicy;
  final RetryAfterClient _retryAfterClient = RetryAfterClient();
  RobleApiDataBase? _lazyClient;
  List<RobleProviderInfo>? _providers;

  /// Built on first real use rather than in the constructor, so the app
  /// (and widget tests) can still render the login screen with no
  /// `ROBLE_CONTRACT_ID` configured — the clear [AuthConfigurationException]
  /// only surfaces once the user actually tries to log in. Only one instance
  /// is ever created: a second one would have its own session.
  RobleApiDataBase get _client {
    if (_injectedClient != null) return _injectedClient;
    if (!config.isConfigured) {
      throw const AuthConfigurationException(
        'Falta configurar ROBLE_CONTRACT_ID. No se puede iniciar sesion '
        'contra Roble sin el identificador del proyecto.',
      );
    }
    final callbackScheme = config.nativeCallbackScheme.trim();
    return _lazyClient ??= RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: config.baseUrl,
        contractId: config.contractId,
      ),
      client: _retryAfterClient,
      ssoRedirect: config.ssoRedirect.trim().isEmpty
          ? null
          : config.ssoRedirect,
      socialOpener: kIsWeb || callbackScheme.isEmpty
          ? null
          : robleNativeOpener(callbackScheme),
    );
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Runs [action] and turns a `429` into [AuthRateLimitedException].
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RobleApiHttpException catch (error) {
      if (error.statusCode == 429) {
        throw AuthRateLimitedException(_retryAfterClient.takeRetryAfter());
      }
      rethrow;
    }
  }

  @override
  Future<AuthenticationUser> login(String email, String password) =>
      _run(() async {
        final profile = await _client.login(
          email: _normalizeEmail(email),
          password: password,
        );
        return AuthenticationUser.fromProfile(profile);
      });

  @override
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) => _run(() async {
    final normalized = _normalizeEmail(email);
    if (!config.isInstitutionalEmail(normalized)) {
      throw NonInstitutionalEmailException(config.institutionalEmailDomain);
    }
    await _client.registerWithVerification(
      email: normalized,
      password: password,
      name: name.trim(),
      extra: extra,
    );
  });

  @override
  Future<void> verifyEmail(String email, String code) => _run(
    () => _client.verifyEmail(email: _normalizeEmail(email), code: code.trim()),
  );

  @override
  Future<void> resendCode(String email) =>
      _run(() => _client.resendCode(email: _normalizeEmail(email)));

  @override
  Future<bool> isMicrosoftEnabled() => _run(() async {
    final providers = _providers ??= await _client.listProviders();
    return providers.any((p) => p.name == RobleSocialProvider.microsoft.name);
  });

  @override
  Future<AuthenticationUser> signInWithMicrosoft() => _run(() async {
    final client = _client;
    // The provider list is loaded ahead of time (see isMicrosoftEnabled) so
    // that no extra await sits between the tap and the popup, which browsers
    // block if it is opened too long after the user's gesture.
    final providers = _providers;
    if (providers != null &&
        !providers.any((p) => p.name == RobleSocialProvider.microsoft.name)) {
      throw const AuthProviderUnavailableException('Microsoft');
    }
    // Outside web the SDK needs the app's own URL scheme to get the return
    // from the browser; without it the flow would hang instead of failing.
    if (!kIsWeb && config.nativeCallbackScheme.trim().isEmpty) {
      throw const AuthConfigurationException(
        'Falta configurar ROBLE_NATIVE_CALLBACK_SCHEME para iniciar sesion '
        'con Microsoft en Android/iOS.',
      );
    }
    final profile = await client.signInWithProvider(
      RobleSocialProvider.microsoft,
    );
    return AuthenticationUser.fromProfile(profile);
  });

  @override
  bool get isLoggedIn => _client.isLoggedIn;

  /// Retried with backoff on transient failures only (network, timeout,
  /// 502/503/504); an invalid or expired session is answered with `false`
  /// by the SDK and is never retried.
  @override
  Future<bool> restoreSession() =>
      _run(() => retryPolicy.run(() => _client.restoreSession()));

  @override
  Future<AuthenticationUser?> currentUser() => _run(() async {
    if (!_client.isLoggedIn) return null;
    final profile = await retryPolicy.run(() => _client.currentUser());
    return AuthenticationUser.fromProfile(profile);
  });

  @override
  Future<void> logOut() => _run(() => _client.logout());

  @override
  Future<void> forgotPassword(String email) =>
      _run(() => _client.forgotPassword(email: _normalizeEmail(email)));

  @override
  Future<void> resetPassword(String token, String newPassword) => _run(
    () => _client.resetPassword(token: token.trim(), newPassword: newPassword),
  );
}
