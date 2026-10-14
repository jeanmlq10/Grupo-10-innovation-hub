import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/views/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

/// Stand-in for Central: Home when logged in, Welcome otherwise. Home itself
/// needs many unrelated controllers, so a marker text is enough to prove that
/// the user ends up on the logged-in side.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthenticationController>();
    return Obx(
      () => auth.isLogged
          ? const Scaffold(body: Text('HOME'))
          : const WelcomePage(),
    );
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> goToVerifyStep(WidgetTester tester) async {
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      'Ana Garcia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo institucional'),
      'ana@uninorte.edu.co',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'Password1!',
    );
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Verificación'), findsOneWidget);
  }

  testWidgets('after verifying the code a new user sees the first-access choice over Home', (
    tester,
  ) async {
    useTallScreen(tester);
    final repo = _Repo();
    Get.put(AuthenticationController(repo));
    await tester.pumpWidget(const GetMaterialApp(home: _Root()));
    await tester.pumpAndSettle();

    await goToVerifyStep(tester);
    await tester.enterText(
      find.byKey(const Key('verification_code_field')),
      '123456',
    );
    await tester.tap(find.text('Verificar'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('¿Qué quieres hacer?'), findsOneWidget);
    expect(find.text('Alta institucional'), findsNothing);
    expect(find.text('¡Bienvenido!'), findsNothing);
    expect(repo.loginPassword, 'Password1!');

    await tester.tap(find.text('Explorar proyectos'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets(
    'if the automatic sign-in fails, the user goes back to Welcome with the account verified',
    (tester) async {
      useTallScreen(tester);
      final repo = _Repo()..loginError = const RobleApiNetworkException('down');
      Get.put(AuthenticationController(repo));
      await tester.pumpWidget(const GetMaterialApp(home: _Root()));
      await tester.pumpAndSettle();

      await goToVerifyStep(tester);
      await tester.enterText(
        find.byKey(const Key('verification_code_field')),
        '123456',
      );
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('HOME'), findsNothing);
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('Alta institucional'), findsNothing);
    },
  );
}

class _Repo implements IAuthRepository {
  Object? loginError;
  String? loginPassword;

  @override
  bool get isLoggedIn => false;

  @override
  Future<bool> restoreSession() async => false;

  @override
  Future<AuthenticationUser?> currentUser() async => null;

  @override
  Future<AuthenticationUser> login(String email, String password) async {
    loginPassword = password;
    if (loginError != null) throw loginError!;
    return AuthenticationUser(
      id: 'p1',
      userId: 'u1',
      email: email,
      name: 'Ana Garcia',
    );
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
  Future<bool> isMicrosoftEnabled() async => true;

  @override
  Future<AuthenticationUser> signInWithMicrosoft() =>
      throw UnimplementedError();

  @override
  Future<void> logOut() async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword(String token, String newPassword) async {}
}
