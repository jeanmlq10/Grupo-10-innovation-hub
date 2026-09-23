import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/welcome_cloud_illustration.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Pantalla de bienvenida del flujo de autenticación.
///
/// IMPORTANTE: esta pantalla conserva exactamente la navegación existente.
/// Los cambios aquí son únicamente visuales para reproducir la pantalla
/// "Bienvenido" del flujo de referencia.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = flowWidth(context);

    // La composición del Figma está muy compacta: título arriba, ilustración
    // grande inmediatamente debajo, texto y finalmente los dos botones.
    // Se calcula todo a partir del ancho para conservar las proporciones.
    final titleSize = (width * 0.075).clamp(27.0, 34.0).toDouble();
    final illustrationWidth = (width * 0.91).clamp(315.0, 370.0).toDouble();
    final bodyTextSize = (width * 0.044).clamp(15.5, 18.0).toDouble();
    final buttonHeight = (width * 0.135).clamp(52.0, 58.0).toDouble();
    final horizontalPadding = width * 0.07;

    // En pantallas altas se mantiene el mismo punto de partida que el flujo;
    // en pantallas pequeñas reducimos ligeramente el espacio para evitar
    // overflow sin cambiar la composición.
    final topSpace = (screen.height * 0.055).clamp(22.0, 38.0).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              // minHeight = alto visible: reparte título, nube y botones
              // en toda la pantalla; en pantallas pequeñas hace scroll.
              constraints: BoxConstraints(
                maxWidth: width,
                minHeight: viewport.maxHeight,
              ),
              child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topSpace,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screen.height * 0.06),
                    Text(
                      '¡Bienvenido!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: HomeColors.flowNavy,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                    // La nube ocupa el espacio central libre: título arriba,
                    // texto y botones abajo.
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width * 0.05,
                          ),
                          child: WelcomeCloudIllustration(
                            size: illustrationWidth,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Únete a proyectos que transforman\nideas en impacto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodyTextSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.28,
                      ),
                    ),
                    SizedBox(height: width * 0.035),
                    SizedBox(
                      height: buttonHeight,
                      child: FilledButton(
                        onPressed: () => Get.to(() => const LoginPage()),
                        style: FilledButton.styleFrom(
                          backgroundColor: HomeColors.flowPurple,
                          foregroundColor: Colors.white,
                          elevation: 1.5,
                          shadowColor: Colors.black.withValues(alpha: 0.28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: TextStyle(
                            fontSize: (width * 0.044).clamp(16.0, 18.0).toDouble(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
                    SizedBox(height: width * 0.018),
                    SizedBox(
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const SignUpPage()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomeColors.flowPurple,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: HomeColors.flowPurple,
                            width: width * 0.003,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: TextStyle(
                            fontSize: (width * 0.041).clamp(15.0, 17.0).toDouble(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    ),
                  ],
                ),
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
