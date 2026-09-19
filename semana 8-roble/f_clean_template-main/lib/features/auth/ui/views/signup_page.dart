import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../../domain/password_policy.dart';
import '../viewmodels/authentication_controller.dart';

/// Institutional sign-up. Roble owns the account: this screen only calls
/// `registerWithVerification` and then the email-code confirmation step —
/// it never stores a password itself and never logs the user in directly,
/// so a verified account still goes through the normal login screen.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _careerController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthenticationController _auth = Get.find();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _careerController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_auth.isBusy) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final ok = await _auth.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      extra: _careerController.text.trim().isEmpty
          ? const {}
          : {'career': _careerController.text.trim()},
    );
    if (!ok) {
      _showError();
    } else {
      Get.snackbar(
        'Registro',
        'Te enviamos un codigo de verificacion a tu correo institucional.',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {});
    }
  }

  Future<void> _verify() async {
    if (_auth.isBusy) return;
    FocusScope.of(context).unfocus();
    if (!_codeFormKey.currentState!.validate()) return;

    final ok = await _auth.verifyEmail(_codeController.text.trim());
    if (!ok) {
      _showError();
      return;
    }
    if (!mounted) return;
    Get.snackbar(
      'Cuenta verificada',
      'Ya puedes iniciar sesion con tu correo y contrasena.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Navigator.of(context).pop();
  }

  Future<void> _resendCode() async {
    final ok = await _auth.resendVerificationCode();
    if (!ok) _showError();
  }

  void _showError() {
    final message = _auth.error.value;
    // Empty when a duplicate tap was ignored while a request was running.
    if (message.isEmpty) return;
    Get.snackbar(
      'Registro',
      message,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alta institucional')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(
                () => _auth.pendingVerificationEmail == null
                    ? _buildRegisterForm()
                    : _buildVerifyForm(_auth.pendingVerificationEmail!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: HomeColors.primaryPurple,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Crea tu cuenta institucional',
            style: TextStyle(
              color: HomeColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Ingresa tu nombre.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo institucional',
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
            controller: _careerController,
            decoration: const InputDecoration(
              labelText: 'Carrera o programa (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
            // Same rule Roble enforces, so a weak password never costs one of
            // the 5 sign-up requests per hour the server allows.
            validator: (value) => PasswordPolicy.validate(value ?? ''),
          ),
          Obx(
            () => _auth.isBlocked
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Demasiados intentos. Podras volver a intentarlo en '
                      '${_auth.retrySecondsLeft} s.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Obx(
            () => FilledButton(
              onPressed: _auth.isBusy ? null : _register,
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
                  : const Text('Registrarme'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyForm(String email) {
    return Form(
      key: _codeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            color: HomeColors.primaryPurple,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Enviamos un codigo a $email',
            style: const TextStyle(color: HomeColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Codigo de verificacion',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Ingresa el codigo.' : null,
          ),
          const SizedBox(height: 20),
          Obx(
            () => FilledButton(
              onPressed: _auth.isBusy ? null : _verify,
              style: FilledButton.styleFrom(
                backgroundColor: HomeColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Verificar'),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => TextButton(
              onPressed: _auth.isBusy ? null : _resendCode,
              child: const Text('Reenviar codigo'),
            ),
          ),
        ],
      ),
    );
  }
}
