import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../widgets/confetti_check_illustration.dart';

/// "¡Proyecto publicado!" — the final screen of the wizard. Both buttons
/// go to "Mis proyectos" today: there's no dedicated project-detail
/// screen yet for "Ver mi proyecto" to open, so it lands in the same
/// place as "Volver a mis proyectos" until that detail screen exists.
class ProjectPublishedPage extends StatelessWidget {
  const ProjectPublishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              const ConfettiCheckIllustration(),
              const SizedBox(height: 28),
              const Text(
                '¡Proyecto publicado!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu proyecto ya está disponible en Explorar proyectos.\n'
                '¡Ahora otros usuarios podrán unirse!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/mis-proyectos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ver mi proyecto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.offAllNamed('/mis-proyectos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeColors.primaryPurple,
                    backgroundColor: HomeColors.navSelectedBackground,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Volver a mis proyectos',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
