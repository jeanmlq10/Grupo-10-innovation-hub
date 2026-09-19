import '../../domain/models/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/i_authentication_source.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository(this.authenticationSource);

  final IAuthenticationSource authenticationSource;

  @override
  Future<AuthenticationUser> login(String email, String password) =>
      authenticationSource.login(email, password);

  @override
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) => authenticationSource.registerWithVerification(
    email: email,
    password: password,
    name: name,
    extra: extra,
  );

  @override
  Future<void> verifyEmail(String email, String code) =>
      authenticationSource.verifyEmail(email, code);

  @override
  Future<void> resendCode(String email) =>
      authenticationSource.resendCode(email);

  @override
  Future<bool> isMicrosoftEnabled() =>
      authenticationSource.isMicrosoftEnabled();

  @override
  Future<AuthenticationUser> signInWithMicrosoft() =>
      authenticationSource.signInWithMicrosoft();

  @override
  bool get isLoggedIn => authenticationSource.isLoggedIn;

  @override
  Future<bool> restoreSession() => authenticationSource.restoreSession();

  @override
  Future<AuthenticationUser?> currentUser() =>
      authenticationSource.currentUser();

  @override
  Future<void> logOut() => authenticationSource.logOut();

  @override
  Future<void> forgotPassword(String email) =>
      authenticationSource.forgotPassword(email);

  @override
  Future<void> resetPassword(String token, String newPassword) =>
      authenticationSource.resetPassword(token, newPassword);
}
