import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';

class AuthenticationController extends GetxController with UiLoggy {
  AuthenticationController(this.repoAuthentication);

  final IAuthRepository repoAuthentication;
  final _logged = false.obs;
  final _loggedUser = Rxn<AuthenticationUser>();
  final _isLoading = false.obs;
  final _isRestoring = true.obs;

  /// Email awaiting a verification code from [registerWithVerification].
  /// Null when there is no registration in progress.
  final _pendingVerificationEmail = Rxn<String>();

  final RxString error = ''.obs;

  bool get isLoading => _isLoading.value;
  bool get isRestoring => _isRestoring.value;
  bool get isLogged => _logged.value;
  String get loggedEmail => _loggedUser.value?.email ?? '';
  AuthenticationUser? get loggedUser => _loggedUser.value;
  String? get pendingVerificationEmail => _pendingVerificationEmail.value;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    _isRestoring.value = true;
    try {
      _logged.value = await repoAuthentication.restoreSession();
      _loggedUser.value = _logged.value
          ? await repoAuthentication.currentUser()
          : null;
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

  Future<bool> login(String email, String password) async {
    error.value = '';
    if (!_validate(email, password)) {
      error.value =
          'Ingresa un correo valido y una contrasena de al menos 7 caracteres.';
      return false;
    }
    _isLoading.value = true;
    try {
      _loggedUser.value = await repoAuthentication.login(
        email.trim(),
        password,
      );
      _logged.value = true;
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Login error $exception');
      error.value = errorMessage(exception);
      _logged.value = false;
      _loggedUser.value = null;
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    error.value = '';
    _isLoading.value = true;
    try {
      _loggedUser.value = await repoAuthentication.signInWithGoogle();
      _logged.value = true;
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Google login error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) async {
    error.value = '';
    if (!_validate(email, password) || name.trim().isEmpty) {
      error.value =
          'Completa nombre, correo y una contrasena de al menos 7 caracteres.';
      return false;
    }
    _isLoading.value = true;
    try {
      await repoAuthentication.registerWithVerification(
        email: email.trim(),
        password: password,
        name: name.trim(),
        extra: extra,
      );
      _pendingVerificationEmail.value = email.trim();
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Register error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> verifyEmail(String code) async {
    final email = _pendingVerificationEmail.value;
    if (email == null) {
      error.value = 'No hay un registro pendiente de verificacion.';
      return false;
    }
    error.value = '';
    _isLoading.value = true;
    try {
      await repoAuthentication.verifyEmail(email, code);
      _pendingVerificationEmail.value = null;
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Verify email error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resendVerificationCode() async {
    final email = _pendingVerificationEmail.value;
    if (email == null) return false;
    try {
      await repoAuthentication.resendCode(email);
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Resend code error $exception');
      error.value = errorMessage(exception);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    error.value = '';
    try {
      await repoAuthentication.forgotPassword(email.trim());
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Forgot password error $exception');
      error.value = errorMessage(exception);
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    error.value = '';
    try {
      await repoAuthentication.resetPassword(token, newPassword);
      return true;
    } catch (exception) {
      loggy.error('AuthenticationController: Reset password error $exception');
      error.value = errorMessage(exception);
      return false;
    }
  }

  Future<bool> logOut() async {
    error.value = '';
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

  bool _validate(String email, String password) =>
      email.trim().contains('@') && password.length > 6;
}
