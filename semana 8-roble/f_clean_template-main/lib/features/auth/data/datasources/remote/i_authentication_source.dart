import '../../../domain/models/authentication_user.dart';

abstract class IAuthenticationSource {
  Future<AuthenticationUser> login(String email, String password);

  /// Registers the account and immediately sends a verification email.
  /// The account cannot log in until [verifyEmail] succeeds.
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra,
  });

  Future<void> verifyEmail(String email, String code);

  Future<void> resendCode(String email);

  Future<AuthenticationUser> signInWithGoogle();

  /// True when a session is present in memory (no network call).
  bool get isLoggedIn;

  /// Re-validates the session persisted on-device. Returns false (and
  /// clears it) if it is missing or no longer valid.
  Future<bool> restoreSession();

  Future<AuthenticationUser?> currentUser();

  Future<void> logOut();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String newPassword);
}
