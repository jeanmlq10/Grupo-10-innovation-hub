import '../models/authentication_user.dart';

abstract class IAuthRepository {
  Future<AuthenticationUser> login(String email, String password);

  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra,
  });

  Future<void> verifyEmail(String email, String code);

  Future<void> resendCode(String email);

  Future<bool> isMicrosoftEnabled();

  Future<AuthenticationUser> signInWithMicrosoft();

  bool get isLoggedIn;

  Future<bool> restoreSession();

  Future<AuthenticationUser?> currentUser();

  Future<void> logOut();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String newPassword);
}
