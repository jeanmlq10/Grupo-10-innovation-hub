import 'dart:async';

import 'package:f_clean_template/features/auth/domain/auth_exceptions.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

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
    Future<AuthenticationController> ready(_FakeAuthRepository repo) async {
      final controller = Get.put(AuthenticationController(repo));
      await Future<void>.delayed(Duration.zero);
      return controller;
    }

    group('session restore', () {
      test(
        'starts restoring, then not logged in without a saved session',
        () async {
          final repo = _FakeAuthRepository()..restoreResult = false;
          final controller = Get.put(AuthenticationController(repo));

          expect(controller.isRestoring, isTrue);
          await Future<void>.delayed(Duration.zero);

          expect(controller.isRestoring, isFalse);
          expect(controller.isLogged, isFalse);
          expect(controller.loggedUser, isNull);
        },
      );

      test('restores a valid session into an authenticated state', () async {
        final repo = _FakeAuthRepository()
          ..restoreResult = true
          ..currentUserResult = user();
        final controller = await ready(repo);

        expect(controller.isLogged, isTrue);
        expect(controller.loggedUser?.email, 'ana@uninorte.edu.co');
      });

      test('an error while restoring means logged out, not a crash', () async {
        final repo = _FakeAuthRepository()
          ..restoreError = Exception('network down');
        final controller = await ready(repo);

        expect(controller.isLogged, isFalse);
        expect(controller.isRestoring, isFalse);
      });

      test('a 429 while restoring starts the cooldown', () async {
        final repo = _FakeAuthRepository()
          ..restoreError = const AuthRateLimitedException(
            Duration(seconds: 30),
          );
        final controller = await ready(repo);

        expect(controller.isLogged, isFalse);
        expect(controller.isBlocked, isTrue);
      });
    });

    group('login', () {
      test('success sets the authenticated state', () async {
        final repo = _FakeAuthRepository()..loginResult = user();
        final controller = await ready(repo);

        final ok = await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(ok, isTrue);
        expect(controller.isLogged, isTrue);
        expect(controller.loggedEmail, 'ana@uninorte.edu.co');
        expect(controller.error.value, isEmpty);
        expect(controller.isLoading, isFalse);
      });

      test(
        'failure surfaces an error, stays logged out and resets loading',
        () async {
          final repo = _FakeAuthRepository()..loginError = Exception('bad');
          final controller = await ready(repo);

          final ok = await controller.login(
            'ana@uninorte.edu.co',
            'Password1!',
          );

          expect(ok, isFalse);
          expect(controller.isLogged, isFalse);
          expect(controller.error.value, isNotEmpty);
          expect(controller.isLoading, isFalse);
        },
      );

      test('normalizes the email before calling the repository', () async {
        final repo = _FakeAuthRepository()..loginResult = user();
        final controller = await ready(repo);

        await controller.login('  Ana@Uninorte.EDU.co ', 'Password1!');

        expect(repo.lastLoginEmail, 'ana@uninorte.edu.co');
      });

      test('an invalid form never reaches the repository', () async {
        final repo = _FakeAuthRepository();
        final controller = await ready(repo);

        expect(await controller.login('not-an-email', 'x'), isFalse);
        expect(await controller.login('ana@uninorte.edu.co', ''), isFalse);
        expect(repo.loginCalls, 0);
      });

      test(
        'an existing password is sent as typed, whatever its complexity',
        () async {
          final repo = _FakeAuthRepository()..loginResult = user();
          final controller = await ready(repo);

          await controller.login('ana@uninorte.edu.co', 'abc');

          expect(repo.loginCalls, 1);
        },
      );

      test('isLoading is true while the request is in flight', () async {
        final repo = _FakeAuthRepository()
          ..loginResult = user()
          ..loginGate = Completer<void>();
        final controller = await ready(repo);

        final future = controller.login('ana@uninorte.edu.co', 'Password1!');
        expect(controller.isLoading, isTrue);
        repo.loginGate!.complete();
        await future;

        expect(controller.isLoading, isFalse);
      });
    });

    group('one request at a time', () {
      test('a second login while one is running is ignored', () async {
        final repo = _FakeAuthRepository()
          ..loginResult = user()
          ..loginGate = Completer<void>();
        final controller = await ready(repo);

        final first = controller.login('ana@uninorte.edu.co', 'Password1!');
        final second = controller.login('ana@uninorte.edu.co', 'Password1!');
        final third = controller.signInWithMicrosoft();

        expect(await second, isFalse);
        expect(await third, isFalse);
        repo.loginGate!.complete();
        expect(await first, isTrue);
        expect(repo.loginCalls, 1);
        expect(repo.microsoftCalls, 0);
      });

      test('the lock is released after an error, so retry works', () async {
        final repo = _FakeAuthRepository()..loginError = Exception('bad');
        final controller = await ready(repo);

        await controller.login('ana@uninorte.edu.co', 'Password1!');
        repo
          ..loginError = null
          ..loginResult = user();
        final ok = await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(ok, isTrue);
        expect(repo.loginCalls, 2);
      });
    });

    group('429 Too Many Requests', () {
      test('blocks further attempts without touching the network', () async {
        final repo = _FakeAuthRepository()
          ..loginError = const AuthRateLimitedException(Duration(seconds: 30));
        final controller = await ready(repo);

        expect(
          await controller.login('ana@uninorte.edu.co', 'Password1!'),
          isFalse,
        );
        expect(controller.isBlocked, isTrue);
        expect(controller.isBusy, isTrue);
        expect(controller.error.value, contains('30'));

        expect(
          await controller.login('ana@uninorte.edu.co', 'Password1!'),
          isFalse,
        );
        expect(await controller.signInWithMicrosoft(), isFalse);
        expect(repo.loginCalls, 1, reason: 'no automatic or repeated retries');
        expect(repo.microsoftCalls, 0);
      });

      test('respects the Retry-After the server sent', () async {
        final repo = _FakeAuthRepository()
          ..loginError = const AuthRateLimitedException(Duration(seconds: 42));
        final controller = await ready(repo);

        await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(controller.retrySecondsLeft, 42);
      });

      test('uses the default wait when there is no Retry-After', () async {
        final repo = _FakeAuthRepository()
          ..loginError = const AuthRateLimitedException();
        final controller = await ready(repo);

        await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(
          controller.retrySecondsLeft,
          AuthenticationController.defaultRateLimitWait.inSeconds,
        );
      });

      test('the block lifts by itself and login works again', () async {
        final repo = _FakeAuthRepository()
          ..loginError = const AuthRateLimitedException(Duration(seconds: 1));
        final controller = await ready(repo);
        await controller.login('ana@uninorte.edu.co', 'Password1!');
        expect(controller.isBlocked, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 1300));
        expect(controller.isBlocked, isFalse);

        repo
          ..loginError = null
          ..loginResult = user();
        expect(
          await controller.login('ana@uninorte.edu.co', 'Password1!'),
          isTrue,
        );
      });

      test('a successful request resets the backoff', () async {
        final repo = _FakeAuthRepository()
          ..loginError = const AuthRateLimitedException(Duration(seconds: 1));
        final controller = await ready(repo);
        await controller.login('ana@uninorte.edu.co', 'Password1!');
        await Future<void>.delayed(const Duration(milliseconds: 1300));

        repo
          ..loginError = null
          ..loginResult = user();
        await controller.login('ana@uninorte.edu.co', 'Password1!');
        await controller.logOut();
        repo
          ..loginError = const AuthRateLimitedException()
          ..loginResult = null;
        await controller.login('ana@uninorte.edu.co', 'Password1!');

        expect(
          controller.retrySecondsLeft,
          AuthenticationController.defaultRateLimitWait.inSeconds,
        );
      });

      test('consecutive 429s without Retry-After back off progressively', () {
        expect(
          AuthenticationController.rateLimitBackoff(1),
          const Duration(seconds: 60),
        );
        expect(
          AuthenticationController.rateLimitBackoff(2),
          const Duration(seconds: 120),
        );
        expect(
          AuthenticationController.rateLimitBackoff(3),
          const Duration(seconds: 240),
        );
        expect(
          AuthenticationController.rateLimitBackoff(4),
          const Duration(seconds: 480),
        );
        expect(
          AuthenticationController.rateLimitBackoff(5),
          const Duration(minutes: 15),
        );
        expect(
          AuthenticationController.rateLimitBackoff(50),
          const Duration(minutes: 15),
        );
      });
    });

    group('no automatic retries on definitive errors', () {
      for (final status in [401, 403]) {
        test('HTTP $status is reported once and never retried', () async {
          final repo = _FakeAuthRepository()
            ..loginError = RobleApiHttpException(status, 'no');
          final controller = await ready(repo);

          final ok = await controller.login(
            'ana@uninorte.edu.co',
            'Password1!',
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(ok, isFalse);
          expect(repo.loginCalls, 1);
          expect(controller.isBlocked, isFalse);
          expect(controller.error.value, isNotEmpty);
        });
      }
    });

    group('microsoft', () {
      test('signs the user in', () async {
        final repo = _FakeAuthRepository()
          ..microsoftResult = user(email: 'ana@uninorte.edu.co');
        final controller = await ready(repo);

        final ok = await controller.signInWithMicrosoft();

        expect(ok, isTrue);
        expect(controller.isLogged, isTrue);
        expect(controller.loggedEmail, 'ana@uninorte.edu.co');
      });

      test('a cancelled or blocked popup is an error, not a session', () async {
        final repo = _FakeAuthRepository()
          ..microsoftError = const RobleApiAuthException('cerrada');
        final controller = await ready(repo);

        final ok = await controller.signInWithMicrosoft();

        expect(ok, isFalse);
        expect(controller.isLogged, isFalse);
        expect(controller.error.value, isNotEmpty);
        expect(controller.isLoading, isFalse);
      });

      test(
        'an email that belongs to another sign-in method shows a clear message',
        () async {
          final repo = _FakeAuthRepository()
            ..microsoftError = const RobleApiConflictException('conflict');
          final controller = await ready(repo);

          await controller.signInWithMicrosoft();

          expect(controller.error.value, contains('Ya existe una cuenta'));
        },
      );

      test(
        'is refused locally, without a request, when Roble has it disabled',
        () async {
          final repo = _FakeAuthRepository()..microsoftEnabledResult = false;
          final controller = await ready(repo);
          await controller.loadProviders();

          final ok = await controller.signInWithMicrosoft();

          expect(ok, isFalse);
          expect(repo.microsoftCalls, 0);
          expect(controller.error.value, contains('Microsoft'));
        },
      );

      test('providers are only requested once', () async {
        final repo = _FakeAuthRepository()..microsoftEnabledResult = true;
        final controller = await ready(repo);

        await Future.wait([
          controller.loadProviders(),
          controller.loadProviders(),
        ]);
        await controller.loadProviders();

        expect(repo.providerCalls, 1);
        expect(controller.microsoftEnabled, isTrue);
      });
    });

    group('register', () {
      test(
        'goes to pending verification, not logged in, with a normalized email',
        () async {
          final repo = _FakeAuthRepository();
          final controller = await ready(repo);

          final ok = await controller.register(
            email: ' Ana@Uninorte.edu.co ',
            password: 'Password1!',
            name: 'Ana',
          );

          expect(ok, isTrue);
          expect(controller.isLogged, isFalse);
          expect(controller.pendingVerificationEmail, 'ana@uninorte.edu.co');
          expect(repo.lastRegisterEmail, 'ana@uninorte.edu.co');
        },
      );

      test('a password that breaks the policy never costs a request', () async {
        final repo = _FakeAuthRepository();
        final controller = await ready(repo);

        for (final weak in ['abc', 'password1!', 'Password1%', 'Password!!']) {
          final ok = await controller.register(
            email: 'ana@uninorte.edu.co',
            password: weak,
            name: 'Ana',
          );
          expect(ok, isFalse, reason: weak);
        }

        expect(repo.registerCalls, 0);
        expect(controller.error.value, isNotEmpty);
      });

      test('a duplicate tap on Register sends a single request', () async {
        final repo = _FakeAuthRepository()..registerGate = Completer<void>();
        final controller = await ready(repo);

        final first = controller.register(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        );
        final second = controller.register(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        );
        repo.registerGate!.complete();

        expect(await second, isFalse);
        expect(await first, isTrue);
        expect(repo.registerCalls, 1);
      });

      test(
        'an already registered email is reported with the server message',
        () async {
          final repo = _FakeAuthRepository()
            ..registerError = const RobleApiHttpException(
              400,
              'El correo ya está registrado',
            );
          final controller = await ready(repo);

          final ok = await controller.register(
            email: 'ana@uninorte.edu.co',
            password: 'Password1!',
            name: 'Ana',
          );

          expect(ok, isFalse);
          expect(controller.error.value, 'El correo ya está registrado');
          expect(controller.pendingVerificationEmail, isNull);
        },
      );

      test(
        'verifyEmail clears the pending state once the code is accepted',
        () async {
          final repo = _FakeAuthRepository();
          final controller = await ready(repo);
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

      test('resending the code twice in a row is throttled', () async {
        final repo = _FakeAuthRepository();
        final controller = await ready(repo);
        await controller.register(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        );

        expect(await controller.resendVerificationCode(), isTrue);
        expect(await controller.resendVerificationCode(), isFalse);
        expect(repo.resendCalls, 1);
      });
    });

    test('resetPassword enforces the password policy locally', () async {
      final repo = _FakeAuthRepository();
      final controller = await ready(repo);

      expect(await controller.resetPassword('123456', 'weak'), isFalse);
      expect(repo.resetCalls, 0);
      expect(await controller.resetPassword('123456', 'Password1!'), isTrue);
      expect(repo.resetCalls, 1);
    });

    test('logout clears the session even if the remote call fails', () async {
      final repo = _FakeAuthRepository()
        ..restoreResult = true
        ..currentUserResult = user();
      final controller = await ready(repo);
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
  Completer<void>? loginGate;
  int loginCalls = 0;
  String? lastLoginEmail;

  AuthenticationUser? microsoftResult;
  Object? microsoftError;
  int microsoftCalls = 0;
  bool microsoftEnabledResult = true;
  int providerCalls = 0;

  Object? registerError;
  Completer<void>? registerGate;
  int registerCalls = 0;
  String? lastRegisterEmail;

  int resendCalls = 0;
  int resetCalls = 0;
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
    lastLoginEmail = email;
    if (loginGate != null) await loginGate!.future;
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<bool> isMicrosoftEnabled() async {
    providerCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return microsoftEnabledResult;
  }

  @override
  Future<AuthenticationUser> signInWithMicrosoft() async {
    microsoftCalls++;
    if (microsoftError != null) throw microsoftError!;
    return microsoftResult!;
  }

  @override
  Future<void> registerWithVerification({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic> extra = const {},
  }) async {
    registerCalls++;
    lastRegisterEmail = email;
    if (registerGate != null) await registerGate!.future;
    if (registerError != null) throw registerError!;
  }

  @override
  Future<void> verifyEmail(String email, String code) async {}

  @override
  Future<void> resendCode(String email) async => resendCalls++;

  @override
  Future<void> logOut() async {
    if (logoutError != null) throw logoutError!;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async =>
      resetCalls++;
}
