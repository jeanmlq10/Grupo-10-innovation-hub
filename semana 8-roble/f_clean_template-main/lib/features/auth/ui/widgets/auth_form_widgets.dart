import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/authentication_controller.dart';

/// Kept for the widgets that referenced it; values now come from the
/// reference image tokens in [HomeColors].
abstract final class AuthColors {
  static const Color fieldBorder = HomeColors.flowBorder;
  static const Color fieldFill = HomeColors.flowFieldFill;
  static const Color successGreen = HomeColors.flowGreen;
}

/// Screen width used to size the flow screens, capped so tablets do not
/// blow the layout up.
double flowWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width > 480 ? 480 : width;
}

/// Body shared by the flow screens. Vertical gaps are [Spacer]s with the
/// same proportions as the reference image, so each element sits at the
/// same relative height on any phone; when the keyboard opens the spacers
/// shrink to zero and the content scrolls instead of overflowing.
class FlowScreenBody extends StatelessWidget {
  const FlowScreenBody({
    super.key,
    required this.children,
    this.horizontalFraction = 0.07,
  });

  final List<Widget> children;

  /// Side margin as a fraction of the screen width (reference: ~7%).
  final double horizontalFraction;

  @override
  Widget build(BuildContext context) {
    final width = flowWidth(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * horizontalFraction,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Back arrow inside a light grey circle (top-left of Login and
/// "Alta institucional").
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Regresar',
      child: Material(
        color: HomeColors.flowBackCircle,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back, color: HomeColors.flowNavy, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Solid purple button ("Iniciar sesión", "Ingresar", "Registrarme",
/// "Verificar").
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: HomeColors.flowPurple.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: HomeColors.flowPurple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: HomeColors.flowPurple.withValues(
              alpha: 0.6,
            ),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}

/// White button with a light purple outline ("¿No tienes cuenta?
/// Regístrate").
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: HomeColors.flowAccent,
          backgroundColor: Colors.white,
          side: const BorderSide(color: HomeColors.flowSoftPurple, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Text field of the flow. With [label] the title goes above a white box
/// (Login); with [filled] it is the grey box of "Alta institucional" with
/// only the placeholder. With [obscure] an eye icon toggles visibility.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.obscure = false,
    this.filled = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscure;
  final bool filled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hidden = true;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.filled
        ? HomeColors.flowFieldBorder
        : HomeColors.flowBorder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomeColors.flowNavy,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure && _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(fontSize: 14.5, color: HomeColors.flowNavy),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 14.5,
              color: widget.filled
                  ? HomeColors.flowFieldHint
                  : HomeColors.flowHint,
            ),
            errorMaxLines: 3,
            filled: true,
            fillColor: widget.filled ? HomeColors.flowFieldFill : Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(HomeColors.flowAccent, 1.4),
            errorBorder: _border(Colors.red),
            focusedErrorBorder: _border(Colors.red, 1.4),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    tooltip: _hidden
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF6B6B70),
                      size: 22,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Red countdown shown while Roble has temporarily blocked auth requests
/// (HTTP 429). Reads the existing state of [AuthenticationController].
class RateLimitNotice extends StatelessWidget {
  const RateLimitNotice({super.key, required this.auth});

  final AuthenticationController auth;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => auth.isBlocked
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Demasiados intentos. Podrás volver a intentarlo en '
                '${auth.retrySecondsLeft} s.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Lavender circle with a purple envelope and a green check
/// ("Verificación"). [size] is the circle diameter.
class MailBadgeIcon extends StatelessWidget {
  const MailBadgeIcon({super.key, this.size = 120});

  final double size;

  static const String _envelope = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 48" fill="none">
<rect x="2.5" y="2.5" width="59" height="43" rx="4" stroke="#4B309E" stroke-width="4"/>
<path d="M4.5 5.5L32 27L59.5 5.5" stroke="#4B309E" stroke-width="4" stroke-linejoin="round"/>
<path d="M4.5 43.5L24 22.5M59.5 43.5L40 22.5" stroke="#4B309E" stroke-width="4" stroke-linecap="round"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final envelopeWidth = size * 0.58;
    final envelopeHeight = envelopeWidth * 48 / 64;
    final check = size * 0.21;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: HomeColors.flowLavender,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: (size - envelopeWidth) / 2,
            top: (size - envelopeHeight) / 2,
            width: envelopeWidth,
            height: envelopeHeight,
            child: SvgPicture.string(_envelope),
          ),
          Positioned(
            left: size * 0.755 - check / 2,
            top: size * 0.70 - check / 2,
            width: check,
            height: check,
            child: Container(
              decoration: BoxDecoration(
                color: HomeColors.flowGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.check, size: check * 0.62, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
