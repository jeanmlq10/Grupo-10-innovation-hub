import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/project_detail_controller.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';
import 'package:f_clean_template/features/projects/ui/widgets/confetti_check_illustration.dart';

/// "¡Proyecto publicado!" — the final screen of the wizard.
class ProjectPublishedPage extends StatelessWidget {
  const ProjectPublishedPage({
    super.key,
    required this.projectId,
    this.isPrivate = false,
  });

  final String projectId;

  final bool isPrivate;

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
              Text(
                isPrivate ? '¡Proyecto guardado!' : '¡Proyecto publicado!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isPrivate
                    ? 'Tu proyecto quedó guardado en Mis borradores.\n'
                          'Solo tú puedes verlo.'
                    : 'Tu proyecto ya está disponible en Explorar proyectos.\n'
                          '¡Ahora otros usuarios podrán unirse!\n'
                          'Las tareas y convocatorias muestran su fecha límite.',
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
                  onPressed: () => _openMyProject(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isPrivate ? 'Editar mi proyecto' : 'Ver mi proyecto',
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

  Future<void> _openMyProject() async {
    final project = await Get.find<ProjectDetailController>()
        .projectById(projectId);
    if (project == null) {
      Get.offAllNamed('/mis-proyectos');
      return;
    }
    if (project.audience == 'Solo yo') {
      Get.to(() => CreateProjectPage(editProjectId: project.id));
    } else {
      Get.to(() => ProjectDetailPage(project: project));
    }
  }
}
