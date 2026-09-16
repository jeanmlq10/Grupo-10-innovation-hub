import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/wizard_nav_buttons.dart';
import 'project_published_page.dart';

/// "Revisar y publicar" — the last numbered step (still shown as 4/4,
/// same as "Audiencia": the reference doesn't give this screen its own
/// fraction). Summarizes everything collected so far and, on "Publicar
/// proyecto", flips the SAME project the wizard has been editing from
/// draft to published — see `CreateProjectController.publish()`. No new
/// project object is created here; this screen only triggers that
/// transition.
class ReviewPublishPage extends StatelessWidget {
  const ReviewPublishPage({super.key});

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
                'Revisar y publicar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Verifica la información de tu proyecto',
                style: TextStyle(fontSize: 14.5, color: HomeColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Proyecto ---
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: HomeColors.borderGrey),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCEFE1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.eco_outlined,
                                  color: Color(0xFF3E8E5C),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.name.value.isEmpty
                                          ? '(Sin nombre)'
                                          : controller.name.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: HomeColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.description.value.isEmpty
                                          ? 'Sin descripción todavía.'
                                          : controller.description.value,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: HomeColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // --- Equipo necesario ---
                        const Text(
                          'Equipo necesario',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (controller.teamRoles.values.every((c) => c == 0))
                          const Text(
                            'No se especificó equipo todavía.',
                            style: TextStyle(
                              fontSize: 13,
                              color: HomeColors.textSecondary,
                            ),
                          )
                        else
                          ...CreateProjectController.teamRoleOrder
                              .where((role) => controller.roleCount(role) > 0)
                              .map(
                                (role) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${controller.roleCount(role)} '
                                    '${role == 'Otro' && controller.otherRoleName.value.trim().isNotEmpty ? controller.otherRoleName.value.trim() : role}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: HomeColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                        // --- Tiempo estimado ---
                        const Text(
                          'Tiempo estimado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: HomeColors.navSelectedBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.duration.value ?? 'No seleccionado',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: HomeColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // --- Audiencia ---
                        const Text(
                          'Audiencia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.groups_outlined,
                              size: 18,
                              color: HomeColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.audience.value ?? 'No seleccionada',
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: HomeColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              WizardNavButtons(
                onBack: () => Get.back(),
                nextLabel: controller.isEditing
                    ? 'Guardar cambios'
                    : 'Publicar proyecto',
                onNext: () => _publish(controller),
              ),
              if (!controller.isEditing &&
                  controller.audience.value == 'Solo yo') ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      controller.saveDraft();
                      Get.offAllNamed('/mis-proyectos');
                    },
                    child: const Text('Guardar como borrador'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _publish(CreateProjectController controller) {
    if (controller.isEditing) {
      controller.saveChanges();
      Get.offAllNamed('/mis-proyectos');
      return;
    }
    controller.publish();
    Get.offAll(() => ProjectPublishedPage(projectId: controller.draftId));
  }
}
