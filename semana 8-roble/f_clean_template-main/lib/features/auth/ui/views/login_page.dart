import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../first_access_store.dart';
import '../viewmodels/authentication_controller.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/auth_loading_view.dart';
import 'what_to_do_page.dart';

/// "Iniciar sesión". The "Ingresar" button calls the existing
/// `AuthenticationController.login`, which authenticates against Roble.
/// While that request runs (and until the app moves on) the screen shows
/// "Iniciando sesión...". On success [Central], underneath, is already
/// showing Home, so this screen just pops back to it.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthenticationController _auth = Get.find();

  /// True from the tap on "Ingresar" until leaving this screen (or until the
  /// login fails), so "Iniciando sesión..." does not flicker back to the form.
  bool _signingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Enter on the keyboard bypasses the disabled button, so check here too.
    if (_auth.isBusy || _signingIn) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _signingIn = true);
    final loggedIn = await _auth.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (!loggedIn) {
      setState(() => _signingIn = false);
      _showError();
      return;
    }

    final firstAccess = await FirstAccessStore.consume(_auth.loggedEmail);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (firstAccess) Get.to(() => const WhatToDoPage());
  }

  Future<void> _forgotPassword() async {
    if (_auth.isBusy) return;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Recuperar contraseña',
        'Escribe tu correo electrónico y vuelve a tocar '
            '"¿Olvidaste tu contraseña?".',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final ok = await _auth.forgotPassword(email);
    if (!mounted) return;
    if (!ok) {
      _showError();
      return;
    }
    Get.snackbar(
      'Recuperar contraseña',
      'Si el correo está registrado, te enviamos las instrucciones para '
          'restablecer tu contraseña.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showError() {
    final message = _auth.error.value;
    // Empty when a duplicate tap was ignored while a request was running.
    if (message.isEmpty) return;
    Get.snackbar(
      'Autenticación',
      message,
      icon: const Icon(Icons.lock_outline, color: Colors.red),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_signingIn) return const AuthLoadingView();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: FlowScreenBody(
          children: [
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: AuthBackButton(),
            ),
            const SizedBox(height: 14),
            const Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: HomeColors.flowNavy,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingresa tus datos para\ncontinuar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: HomeColors.flowSlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            AuthTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              hint: 'ejemplo@correo.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Ingresa tu correo.';
                if (!email.contains('@')) return 'Correo inválido.';
                return null;
              },
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _passwordController,
              label: 'Contraseña',
              hint: '••••••••••••',
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              // Login only asks for a value: existing passwords must be
              // sent as typed, the complexity rule applies at sign-up.
              validator: (value) =>
                  (value ?? '').isEmpty ? 'Ingresa tu contraseña.' : null,
              onSubmitted: (_) => _login(),
            ),
            RateLimitNotice(auth: _auth),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: HomeColors.flowAccent,
                ),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // El espacio libre queda entre el formulario y el botón,
            // que se ubica abajo como en la pantalla de bienvenida.
            const SizedBox(height: 24),
            const Spacer(),
            Obx(
              () => AuthPrimaryButton(
                label: 'Ingresar',
                onPressed: _auth.isBusy ? null : _login,
                loading: _auth.isLoading,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
