import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('AuthenticationController', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
    });

    AuthenticationUser user({String email = 'ana@uninorte.edu.co'}) =>
        AuthenticationUser(id: 'p1', userId: 'u1', email: email, name: 'Ana');

    // GetxController.onInit() only fires once the controller is registered
    // with GetX (Get.put), not from a bare constructor call.
    AuthenticationController controllerFor(_FakeAuthRepository repo) =>
        Get.put(AuthenticationController(repo));

    test(
      'starts restoring, then not logged in when there is no saved session',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);

        expect(controller.isRestoring, isTrue);
        await Future<void>.delayed(Duration.zero);

        expect(controller.isRestoring, isFalse);
        expect(controller.isLogged, isFalse);
        expect(controller.loggedUser, isNull);
      },
    );

    test(
      'restores an existing valid session into an authenticated state',
      () async {
        final repo = _FakeAuthRepository()
          ..restoreResult = true
          ..currentUserResult = user();
        final controller = controllerFor(repo);

        await Future<void>.delayed(Duration.zero);

        expect(controller.isLogged, isTrue);
        expect(controller.loggedUser?.email, 'ana@uninorte.edu.co');
      },
    );

    test(
      'an error while restoring is treated as session expired, not a crash',
      () async {
        final repo = _FakeAuthRepository()
          ..restoreError = Exception('network down');
        final controller = controllerFor(repo);

        await Future<void>.delayed(Duration.zero);

        expect(controller.isLogged, isFalse);
        expect(controller.isRestoring, isFalse);
      },
    );

    test(
      'login success sets the authenticated state and the logged-in user',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);
        repo.loginResult = user();

        final ok = await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(ok, isTrue);
        expect(controller.isLogged, isTrue);
        expect(controller.loggedEmail, 'ana@uninorte.edu.co');
        expect(controller.error.value, isEmpty);
      },
    );

    test(
      'login failure surfaces an error and keeps the user logged out',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);
        repo.loginError = Exception('bad credentials');

        final ok = await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(ok, isFalse);
        expect(controller.isLogged, isFalse);
        expect(controller.error.value, isNotEmpty);
      },
    );

    test(
      'rejects an invalid form before calling the repository at all',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);

        final ok = await controller.login('not-an-email', '123');

        expect(ok, isFalse);
        expect(repo.loginCalls, 0);
      },
    );

    test('sets isLoading true while the login call is in flight', () async {
      final repo = _FakeAuthRepository()..restoreResult = false;
      final controller = controllerFor(repo);
      await Future<void>.delayed(Duration.zero);
      repo.loginResult = user();
      repo.loginDelay = const Duration(milliseconds: 20);

      final future = controller.login('ana@uninorte.edu.co', 'Password1!');
      expect(controller.isLoading, isTrue);
      await future;
      expect(controller.isLoading, isFalse);
    });

    test('signInWithGoogle authenticates the user in one call', () async {
      final repo = _FakeAuthRepository()..restoreResult = false;
      final controller = controllerFor(repo);
      await Future<void>.delayed(Duration.zero);
      repo.googleResult = user(email: 'ana@gmail.com');

      final ok = await controller.signInWithGoogle();

      expect(ok, isTrue);
      expect(controller.loggedEmail, 'ana@gmail.com');
    });

    test(
      'signInWithGoogle surfaces a cancelled/failed social flow as an error',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);
        repo.googleError = Exception('user cancelled');

        final ok = await controller.signInWithGoogle();

        expect(ok, isFalse);
        expect(controller.isLogged, isFalse);
        expect(controller.error.value, isNotEmpty);
      },
    );

    test(
      'register succeeds into a pending-verification state, not a logged-in one',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);

        final ok = await controller.register(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        );

        expect(ok, isTrue);
        expect(controller.isLogged, isFalse);
        expect(controller.pendingVerificationEmail, 'ana@uninorte.edu.co');
      },
    );

    test(
      'verifyEmail clears the pending state once the code is accepted',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = false;
        final controller = controllerFor(repo);
        await Future<void>.delayed(Duration.zero);
        await controller.register(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        );

        final ok = await controller.verifyEmail('123456');

        expect(ok, isTrue);
        expect(controller.pendingVerificationEmail, isNull);
      },
    );

    test('logout clears the session even if the remote call fails', () async {
      final repo = _FakeAuthRepository()
        ..restoreResult = true
        ..currentUserResult = user();
      final controller = controllerFor(repo);
      await Future<void>.delayed(Duration.zero);
      repo.logoutError = Exception('network down');

      final ok = await controller.logOut();

      expect(ok, isFalse);
      expect(controller.isLogged, isFalse);
      expect(controller.loggedUser, isNull);
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  bool restoreResult = false;
  Object? restoreError;
  AuthenticationUser? currentUserResult;

  AuthenticationUser? loginResult;
  Object? loginError;
  Duration loginDelay = Duration.zero;
  int loginCalls = 0;

  AuthenticationUser? googleResult;
  Object? googleError;

  Object? logoutError;

  @override
  bool get isLoggedIn => currentUserResult != null;

  @override
  Future<bool> restoreSession() async {
    if (restoreError != null) throw restoreError!;
    return restoreResult;
  }

  @override
  Future<AuthenticationUser?> currentUser() async => currentUserResult;

  @override
  Future<AuthenticationUser> login(String email, String password) async {
    loginCalls++;
    if (loginDelay > Duration.zero) await Future<void>.delayed(loginDelay);
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthenticationUser> signInWithGoogle() async {
    if (googleError != null) throw googleError!;
    return googleResult!;
  }

  @override
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) async {}

  @override
  Future<void> verifyEmail(String email, String code) async {}

  @override
  Future<void> resendCode(String email) async {}

  @override
  Future<void> logOut() async {
    if (logoutError != null) throw logoutError!;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}
}
