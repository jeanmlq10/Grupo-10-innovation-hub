import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/authentication_controller.dart';
import 'signup_page.dart';

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

  @override
  void initState() {
    super.initState();
    // Learn which providers Roble has enabled now, so tapping the Microsoft
    // button does not have to wait on a request first.
    _auth.loadProviders();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Enter on the keyboard bypasses the disabled button, so check here too.
    if (_auth.isBusy) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await _auth.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!loggedIn) _showError();
  }

  Future<void> _microsoftLogin() async {
    if (_auth.isBusy) return;
    final loggedIn = await _auth.signInWithMicrosoft();
    if (!loggedIn) _showError();
  }

  void _showError() {
    final message = _auth.error.value;
    // Empty when a duplicate tap was ignored while a request was running.
    if (message.isEmpty) return;
    Get.snackbar(
      'Autenticacion',
      message,
      icon: const Icon(Icons.lock_outline, color: Colors.red),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 54,
                      color: HomeColors.primaryPurple,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Innovation Hub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa con tu cuenta institucional.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: HomeColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo institucional',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Ingresa tu correo.';
                        if (!email.contains('@')) return 'Correo invalido.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      // Login only asks for a value: existing passwords must be
                      // sent as typed, the complexity rule applies at sign-up.
                      validator: (value) => (value ?? '').isEmpty
                          ? 'Ingresa tu contrasena.'
                          : null,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    Obx(
                      () => _auth.isBlocked
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Demasiados intentos. Podras volver a '
                                'intentarlo en ${_auth.retrySecondsLeft} s.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => FilledButton(
                        onPressed: _auth.isBusy ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: HomeColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Iniciar sesion'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => OutlinedButton.icon(
                        onPressed: _auth.isBusy ? null : _microsoftLogin,
                        icon: const Icon(Icons.window, size: 22),
                        label: const Text('Continuar con Microsoft'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      ),
                      child: const Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
