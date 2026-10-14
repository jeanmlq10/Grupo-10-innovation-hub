import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/views/login_page.dart';

/// Regla de acceso del modo visitante:
/// sin sesión solo se puede explorar y consultar proyectos; cualquier otra
/// acción (participar, seguir, comentar, crear, ver Mis proyectos...) pide
/// iniciar sesión.
bool requireSession() {
  final auth = Get.find<AuthenticationController>();
  if (auth.isLogged) return true;
  Get.dialog<void>(const LoginRequiredDialog(), barrierDismissible: true);
  return false;
}

/// Aviso "Necesitas iniciar sesión" (pantalla 5 del flujo actualizado).
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: HomeColors.flowNavy),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: HomeColors.flowLavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: HomeColors.flowPurple,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Necesitas iniciar sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: HomeColors.flowNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para participar en el proyecto o realizar otras acciones, '
              'primero debes iniciar sesión.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: HomeColors.flowSlate,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const LoginPage());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: HomeColors.flowPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Iniciar sesión'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HomeColors.flowPurple,
                  side: const BorderSide(color: HomeColors.flowPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
