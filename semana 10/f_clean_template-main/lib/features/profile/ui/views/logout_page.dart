import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';

/// "¿Cerrar sesión?" (pantalla 9 del perfil).
class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: HomeColors.flowLavender,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: HomeColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Se cerrará tu sesión en este dispositivo.\n'
                'Podrás volver a iniciar sesión cuando quieras.',
                textAlign: TextAlign.center,
                style: TextStyle(color: HomeColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    await controller.logOut();
                    Get.offAllNamed('/');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeColors.primaryPurple,
                    side: const BorderSide(color: HomeColors.primaryPurple),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
