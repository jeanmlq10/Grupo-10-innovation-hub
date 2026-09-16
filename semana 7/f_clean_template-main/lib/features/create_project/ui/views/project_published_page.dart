import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';
import '../../../shared_projects/ui/views/project_detail_page.dart';
import 'create_project_page.dart';
import '../widgets/confetti_check_illustration.dart';

/// "¡Proyecto publicado!" — the final screen of the wizard.
///
/// "Ver mi proyecto" opens the actual project that was just published
/// (looked up by id from the shared repository) — never just a generic
/// trip to "Mis proyectos". "Volver a mis proyectos" does go there,
/// where the same project also appears (same object, same id).
class ProjectPublishedPage extends StatelessWidget {
  const ProjectPublishedPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final project = Get.find<ISharedProjectsRepository>().getById(projectId);
    final isPrivate = project?.audience == 'Solo yo';

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

  void _openMyProject() {
    final repository = Get.find<ISharedProjectsRepository>();
    final project = repository.getById(projectId);
    if (project == null) {
      // Shouldn't happen — the id came straight from the wizard that
      // just published this exact project — but fall back gracefully.
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
