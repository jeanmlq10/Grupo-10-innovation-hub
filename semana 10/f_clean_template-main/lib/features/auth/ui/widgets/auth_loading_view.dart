import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// "Iniciando sesión..." — shown while the Roble login request is in flight
/// and until the app moves to "Explorar proyectos".
class AuthLoadingView extends StatelessWidget {
  const AuthLoadingView({
    super.key,
    this.title = 'Iniciando sesión...',
    this.message = 'Redirigiendo a tu\npanel principal.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 9),
              const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    color: HomeColors.flowPurple,
                    backgroundColor: Color(0xFFE6E6EC),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: HomeColors.flowNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.5,
                  color: HomeColors.flowSlate,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 11),
            ],
          ),
        ),
      ),
    );
  }
}
