import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/auth/domain/password_policy.dart';
import 'package:f_clean_template/features/auth/ui/first_access_store.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/widgets/auth_form_widgets.dart';
import 'package:f_clean_template/features/auth/ui/widgets/verification_code_input.dart';
import 'package:f_clean_template/features/auth/ui/views/what_to_do_page.dart';

/// Institutional sign-up. Roble owns the account: this screen calls
/// `registerWithVerification`, asks for the emailed code and, once it is
/// verified, the controller signs the user in with the password just typed.
/// A brand-new account then sees "¿Qué quieres hacer?" on top of Home. It
/// never stores the password itself.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  /// Visual countdown before "Reenviar código" is enabled again. The
  /// controller keeps its own (shorter) resend guard; this one only drives
  /// the "(00:45)" label of the design.
  static const _resendWait = 45;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _careerController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthenticationController _auth = Get.find();

  Timer? _resendTimer;
  int _resendSecondsLeft = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _careerController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendWait);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendSecondsLeft--);
      if (_resendSecondsLeft <= 0) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      }
    });
  }

  String get _resendLabel {
    if (_resendSecondsLeft <= 0) return 'Reenviar código';
    final minutes = (_resendSecondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendSecondsLeft % 60).toString().padLeft(2, '0');
    return 'Reenviar código ($minutes:$seconds)';
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
    if (!mounted) return;
    if (!ok) {
      _showError();
      return;
    }
    _codeController.clear();
    _startResendCountdown();
    Get.snackbar(
      'Registro',
      'Te enviamos un código de verificación a tu correo institucional.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _verify() async {
    if (_auth.isBusy) return;
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Get.snackbar(
        'Verificación',
        'Ingresa el código que te enviamos a tu correo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Read before verifying: the controller clears it once verified.
    final email = _auth.pendingVerificationEmail;
    final ok = await _auth.verifyEmail(code);
    if (!ok) {
      _showError();
      return;
    }
    if (!mounted) return;
    if (_auth.isLogged) {
      // Signed in automatically: drop the sign-up screens (Central already
      // shows Home underneath) and offer the first-access choice.
      Navigator.of(context).popUntil((route) => route.isFirst);
      Get.to(() => const WhatToDoPage());
      return;
    }
    // Verified, but the automatic sign-in did not go through (network, rate
    // limit): remember that this account still has to see the first-access
    // choice, and send the user back to log in by hand.
    if (email != null) await FirstAccessStore.markPending(email);
    if (!mounted) return;
    Get.snackbar(
      'Cuenta verificada',
      'Ya puedes iniciar sesión con tu correo y contraseña.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Navigator.of(context).pop();
  }

  Future<void> _resendCode() async {
    if (_resendSecondsLeft > 0) return;
    final ok = await _auth.resendVerificationCode();
    if (!mounted) return;
    if (!ok) {
      _showError();
      return;
    }
    _startResendCountdown();
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
      backgroundColor: Colors.white,
      body: Obx(
        () => _auth.pendingVerificationEmail == null
            ? _buildRegisterForm()
            : _buildVerifyForm(context),
      ),
    );
  }

  /// "Alta institucional" (reference screen A).
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: FlowScreenBody(
        children: [
          const SizedBox(height: 14),
          const Row(
            children: [
              AuthBackButton(),
              SizedBox(width: 16),
              Text(
                'Alta institucional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HomeColors.flowNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Spacer(flex: 4),
          const Icon(
            Icons.verified_user_outlined,
            color: HomeColors.flowAccent,
            size: 58,
          ),
          const SizedBox(height: 16),
          const Text(
            'Crea tu cuenta institucional',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HomeColors.flowNavy,
              fontSize: 20.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _nameController,
            hint: 'Nombre completo',
            filled: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Ingresa tu nombre.' : null,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _emailController,
            hint: 'Correo institucional',
            filled: true,
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
          const SizedBox(height: 12),
          AuthTextField(
            controller: _careerController,
            hint: 'Carrera o programa (opcional)',
            filled: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _passwordController,
            hint: 'Contraseña',
            filled: true,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            // Same rule Roble enforces, so a weak password never costs one of
            // the 5 sign-up requests per hour the server allows.
            validator: (value) => PasswordPolicy.validate(value ?? ''),
            onSubmitted: (_) => _register(),
          ),
          RateLimitNotice(auth: _auth),
          const SizedBox(height: 20),
          Obx(
            () => AuthPrimaryButton(
              label: 'Registrarme',
              onPressed: _auth.isBusy ? null : _register,
              loading: _auth.isLoading,
            ),
          ),
          const SizedBox(height: 24),
          const Spacer(flex: 5),
        ],
      ),
    );
  }

  /// "Verificación" (reference screen B).
  Widget _buildVerifyForm(BuildContext context) {
    final width = flowWidth(context);
    final contentWidth = width * (1 - 2 * 0.07);
    final badge = (width * 0.30).clamp(104.0, 136.0);

    return FlowScreenBody(
      children: [
        const SizedBox(height: 24),
        const Spacer(flex: 9),
        Center(child: MailBadgeIcon(size: badge)),
        const SizedBox(height: 22),
        const Text(
          'Verificación',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: HomeColors.flowNavy,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Te hemos enviado un código\na tu correo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: HomeColors.flowSlate,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        VerificationCodeInput(
          controller: _codeController,
          width: contentWidth,
          fieldKey: const Key('verification_code_field'),
        ),
        RateLimitNotice(auth: _auth),
        const SizedBox(height: 20),
        Center(
          child: Obx(
            () => TextButton(
              onPressed: (_auth.isBusy || _resendSecondsLeft > 0)
                  ? null
                  : _resendCode,
              style: TextButton.styleFrom(
                foregroundColor: HomeColors.flowAccent,
                disabledForegroundColor: HomeColors.flowAccent,
              ),
              child: Text(
                _resendLabel,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Spacer(flex: 4),
        Obx(
          () => AuthPrimaryButton(
            label: 'Verificar',
            onPressed: _auth.isBusy ? null : _verify,
            loading: _auth.isLoading,
          ),
        ),
        const SizedBox(height: 24),
        const Spacer(flex: 7),
      ],
    );
  }
}
