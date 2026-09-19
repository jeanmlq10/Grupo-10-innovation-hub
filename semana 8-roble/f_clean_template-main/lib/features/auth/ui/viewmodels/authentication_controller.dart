import 'dart:async';

import 'package:f_clean_template/features/auth/domain/auth_exceptions.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/password_policy.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';

class AuthenticationController extends GetxController with UiLoggy {
  AuthenticationController(this.repoAuthentication);

  /// Wait applied on the first `429` when the server sends no `Retry-After`.
  /// Consecutive `429`s double it, up to [maxRateLimitWait].
  static const defaultRateLimitWait = Duration(seconds: 60);
  static const maxRateLimitWait = Duration(minutes: 15);
  static const _maxServerRetryAfter = Duration(hours: 1);
  static const _resendCooldown = Duration(seconds: 30);

  final IAuthRepository repoAuthentication;
  final _logged = false.obs;
  final _loggedUser = Rxn<AuthenticationUser>();
  final _isLoading = false.obs;
  final _isRestoring = true.obs;

  /// Email awaiting a verification code from [register].
  /// Null when there is no registration in progress.
  final _pendingVerificationEmail = Rxn<String>();

  /// null = not known yet, otherwise whether Roble has Microsoft enabled.
  final _microsoftEnabled = Rxn<bool>();

  /// Seconds left of the temporary block after a `429`. 0 = not blocked.
  final _retrySecondsLeft = 0.obs;

  final RxString error = ''.obs;

  // Plain fields, not observables: they must flip synchronously, before any
  // rebuild could happen, so two taps in the same frame cannot both pass.
  bool _requestInFlight = false;
  bool _loadingProviders = false;
  int _consecutiveRateLimits = 0;
  DateTime? _resendBlockedUntil;

  /// Password typed at sign-up, kept only in memory until the email is
  /// verified so the app can sign the user straight in. Cleared as soon as it
  /// is used, and on any failure or logout. Never persisted or logged.
  String? _pendingPassword;
  Timer? _cooldownTimer;

  bool get isLoading => _isLoading.value;
  bool get isRestoring => _isRestoring.value;
  bool get isLogged => _logged.value;
  String get loggedEmail => _loggedUser.value?.email ?? '';
  AuthenticationUser? get loggedUser => _loggedUser.value;
  String? get pendingVerificationEmail => _pendingVerificationEmail.value;
  bool? get microsoftEnabled => _microsoftEnabled.value;

  /// True while Roble told us to slow down. Forms must disable submit.
  bool get isBlocked => _retrySecondsLeft.value > 0;
  int get retrySecondsLeft => _retrySecondsLeft.value;

  /// Convenience for the UI: no auth action can be started right now.
  bool get isBusy => isLoading || isBlocked;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }

  Future<void> _restoreSession() async {
    _isRestoring.value = true;
    try {
      _logged.value = await repoAuthentication.restoreSession();
      _loggedUser.value = _logged.value
          ? await repoAuthentication.currentUser()
          : null;
    } on AuthRateLimitedException catch (exception) {
      _logged.value = false;
      _loggedUser.value = null;
      _startCooldown(exception.retryAfter);
    } catch (exception) {
      loggy.warning(
        'AuthenticationController: Could not restore session: $exception',
      );
      _logged.value = false;
      _loggedUser.value = null;
    } finally {
      _isRestoring.value = false;
    }
  }

  /// Runs one authentication request, and only one at a time.
  ///
  /// While a request is in flight further calls are ignored (return false),
  /// and while a `429` block is active they fail without touching the
  /// network. State is always restored in `finally`, on success and error.
  Future<bool> _guarded(Future<bool> Function() action) async {
    if (_requestInFlight) return false;
    if (isBlocked) {
      error.value = _blockedMessage();
      return false;
    }
    _requestInFlight = true;
    _isLoading.value = true;
    error.value = '';
    try {
      final ok = await action();
      if (ok) _consecutiveRateLimits = 0;
      return ok;
    } on AuthRateLimitedException catch (exception) {
      loggy.warning('AuthenticationController: rate limited by Roble');
      _startCooldown(exception.retryAfter);
      return false;
    } catch (exception) {
      loggy.error('AuthenticationController: request failed: $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _requestInFlight = false;
      _isLoading.value = false;
    }
  }

  /// Wait for the [consecutive]-th `429` in a row when the server gave no
  /// `Retry-After`: 60s, 120s, 240s... capped at [maxRateLimitWait].
  static Duration rateLimitBackoff(int consecutive) {
    final steps = consecutive < 1 ? 0 : consecutive - 1;
    // Past 4 doublings the cap is already exceeded; avoid huge shifts.
    if (steps > 4) return maxRateLimitWait;
    final backoff = defaultRateLimitWait * (1 << steps);
    return backoff > maxRateLimitWait ? maxRateLimitWait : backoff;
  }

  void _startCooldown(Duration? serverRetryAfter) {
    _consecutiveRateLimits++;
    final Duration wait;
    if (serverRetryAfter != null) {
      // Respect what the server asked for.
      wait = serverRetryAfter > _maxServerRetryAfter
          ? _maxServerRetryAfter
          : serverRetryAfter;
    } else {
      wait = rateLimitBackoff(_consecutiveRateLimits);
    }

    _cooldownTimer?.cancel();
    _retrySecondsLeft.value = wait.inSeconds < 1 ? 1 : wait.inSeconds;
    error.value = _blockedMessage();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _retrySecondsLeft.value--;
      if (_retrySecondsLeft.value <= 0) {
        timer.cancel();
        _retrySecondsLeft.value = 0;
        error.value = '';
      } else {
        error.value = _blockedMessage();
      }
    });
  }

  String _blockedMessage() =>
      'Demasiados intentos. Espera ${_retrySecondsLeft.value} s antes de '
      'volver a intentarlo.';

  Future<bool> login(String email, String password) {
    if (!_validEmail(email) || password.isEmpty) {
      error.value = 'Ingresa un correo valido y tu contrasena.';
      return Future.value(false);
    }
    return _guarded(() async {
      _loggedUser.value = await repoAuthentication.login(
        _normalizeEmail(email),
        password,
      );
      _logged.value = true;
      return true;
    });
  }

  /// Loads which social providers Roble has enabled. Called once from the
  /// login screen so the sign-in tap itself never has to wait on a request.
  Future<void> loadProviders() async {
    if (_microsoftEnabled.value != null || _loadingProviders) return;
    _loadingProviders = true;
    try {
      _microsoftEnabled.value = await repoAuthentication.isMicrosoftEnabled();
    } on AuthRateLimitedException catch (exception) {
      _startCooldown(exception.retryAfter);
    } catch (exception) {
      loggy.warning('AuthenticationController: could not list providers');
      loggy.debug('AuthenticationController: providers diagnostic: $exception');
    } finally {
      _loadingProviders = false;
    }
  }

  Future<bool> signInWithMicrosoft() {
    if (_microsoftEnabled.value == false) {
      error.value = const AuthProviderUnavailableException(
        'Microsoft',
      ).toString();
      return Future.value(false);
    }
    // No await before this call: the browser only allows the login popup
    // shortly after the user's tap.
    return _guarded(() async {
      _loggedUser.value = await repoAuthentication.signInWithMicrosoft();
      _logged.value = true;
      return true;
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) {
    final passwordProblem = PasswordPolicy.validate(password);
    if (!_validEmail(email) || name.trim().isEmpty) {
      error.value = 'Completa tu nombre y un correo valido.';
      return Future.value(false);
    }
    if (passwordProblem != null) {
      error.value = passwordProblem;
      return Future.value(false);
    }
    return _guarded(() async {
      final normalized = _normalizeEmail(email);
      await repoAuthentication.registerWithVerification(
        email: normalized,
        password: password,
        name: name.trim(),
        extra: extra,
      );
      _pendingVerificationEmail.value = normalized;
      _pendingPassword = password;
      return true;
    });
  }

  /// Verifies the emailed code and, right after, signs the user in with the
  /// password given at sign-up, so they land in the app without going back to
  /// the login screen. Returns true when the email was verified; check
  /// [isLogged] to know whether the automatic sign-in also worked.
  Future<bool> verifyEmail(String code) {
    final email = _pendingVerificationEmail.value;
    if (email == null) {
      error.value = 'No hay un registro pendiente de verificacion.';
      return Future.value(false);
    }
    return _guarded(() async {
      await repoAuthentication.verifyEmail(email, code);
      _pendingVerificationEmail.value = null;
      final password = _pendingPassword;
      _pendingPassword = null;
      if (password != null) {
        // The account is verified at this point, so a failure here must not
        // turn into a "verification failed": the user can still log in by hand.
        try {
          _loggedUser.value = await repoAuthentication.login(email, password);
          _logged.value = true;
        } on AuthRateLimitedException catch (exception) {
          _startCooldown(exception.retryAfter);
        } catch (exception) {
          loggy.warning('AuthenticationController: auto sign-in failed');
          loggy.debug('AuthenticationController: auto sign-in: $exception');
        }
      }
      return true;
    });
  }

  Future<bool> resendVerificationCode() {
    final email = _pendingVerificationEmail.value;
    if (email == null) return Future.value(false);
    final until = _resendBlockedUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      error.value = 'Espera unos segundos antes de reenviar el codigo.';
      return Future.value(false);
    }
    return _guarded(() async {
      await repoAuthentication.resendCode(email);
      _resendBlockedUntil = DateTime.now().add(_resendCooldown);
      return true;
    });
  }

  Future<bool> forgotPassword(String email) {
    if (!_validEmail(email)) {
      error.value = 'Ingresa un correo valido.';
      return Future.value(false);
    }
    return _guarded(() async {
      await repoAuthentication.forgotPassword(_normalizeEmail(email));
      return true;
    });
  }

  Future<bool> resetPassword(String token, String newPassword) {
    final problem = PasswordPolicy.validate(newPassword);
    if (problem != null) {
      error.value = problem;
      return Future.value(false);
    }
    return _guarded(() async {
      await repoAuthentication.resetPassword(token, newPassword);
      return true;
    });
  }

  /// Always clears the local session, even if the remote call fails.
  Future<bool> logOut() async {
    error.value = '';
    _pendingPassword = null;
    try {
      await repoAuthentication.logOut();
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Logout error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _logged.value = false;
      _loggedUser.value = null;
    }
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static bool _validEmail(String email) {
    final value = email.trim();
    return value.contains('@') &&
        !value.startsWith('@') &&
        !value.endsWith('@');
  }
}
