import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:roble/roble.dart';

import 'package:f_clean_template/features/auth/domain/auth_exceptions.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/auth/data/retry_policy.dart';
import 'package:f_clean_template/core/roble/roble_config.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';

/// Thin adapter over the official `roble` SDK ([RobleApiDataBase]).
class AuthenticationSourceService implements IAuthenticationSource {
  AuthenticationSourceService({
    RobleClient? roble,
    RobleApiDataBase? client,
    RobleAuthConfig? config,
    this.retryPolicy = const RetryPolicy(),
  }) : _roble = roble ?? RobleClient(config: config, database: client);

  final RobleClient _roble;
  final RetryPolicy retryPolicy;
  List<RobleProviderInfo>? _providers;

  RobleAuthConfig get config => _roble.config;

  RobleApiDataBase get _client {
    if (!_roble.isConfigured) {
      throw const AuthConfigurationException(
        'Falta configurar ROBLE_CONTRACT_ID. No se puede iniciar sesion '
        'contra Roble sin el identificador del proyecto.',
      );
    }
    return _roble.db;
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RobleApiHttpException catch (error) {
      if (error.statusCode == 429) {
        throw AuthRateLimitedException(_roble.retryAfterClient.takeRetryAfter());
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
    final providers = _providers;
    if (providers != null &&
        !providers.any((p) => p.name == RobleSocialProvider.microsoft.name)) {
      throw const AuthProviderUnavailableException('Microsoft');
    }
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
