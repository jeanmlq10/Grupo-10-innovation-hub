import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/selectable_option_tile.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/wizard_nav_buttons.dart';
import 'review_publish_page.dart';

/// "Audiencia" — step 4 of 4. Single choice between a private project
/// and one visible to the whole community.
class AudiencePage extends StatelessWidget {
  const AudiencePage({super.key});

  static const _options = [
    _AudienceInfo(
      'Solo yo',
      'Tu proyecto será privado, solo tú podrás verlo',
      Icons.lock_outline,
    ),
    _AudienceInfo(
      'Toda la comunidad',
      'Tu proyecto será visible para todos los usuarios',
      Icons.groups_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final CreateProjectController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: StepProgressBar(currentStep: 4, totalSteps: 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Audiencia',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Quién puede ver tu proyecto?',
                style: TextStyle(fontSize: 14.5, color: HomeColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final option in _options)
                          SelectableOptionTile(
                            icon: option.icon,
                            title: option.label,
                            subtitle: option.subtitle,
                            selected: controller.audience.value == option.label,
                            onTap: () => controller.selectAudience(option.label),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: [
                    if (controller.audience.value == 'Solo yo')
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            controller.saveDraft();
                            Get.offAllNamed('/mis-proyectos');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HomeColors.primaryPurple,
                            side: const BorderSide(color: HomeColors.primaryPurple),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Guardar como borrador'),
                        ),
                      ),
                    if (controller.audience.value == 'Solo yo')
                      const SizedBox(height: 8),
                    WizardNavButtons(
                      onBack: () => Get.back(),
                      onNext: controller.audience.value == null
                          ? () => Get.snackbar(
                                'Audiencia requerida',
                                'Selecciona quién puede ver tu proyecto.',
                                snackPosition: SnackPosition.BOTTOM,
                              )
                          : () => Get.to(() => const ReviewPublishPage()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudienceInfo {
  const _AudienceInfo(this.label, this.subtitle, this.icon);
  final String label;
  final String subtitle;
  final IconData icon;
}
