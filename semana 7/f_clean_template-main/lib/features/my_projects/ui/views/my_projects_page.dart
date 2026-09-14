import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../../../home/ui/widgets/home_bottom_navigation.dart';
import '../../domain/models/my_project.dart';
import '../viewmodels/my_projects_controller.dart';
import '../widgets/my_project_card.dart';
import '../widgets/my_project_placeholder_card.dart';
import '../widgets/my_projects_tabs.dart';

/// "Mis proyectos" — this entrega's only new screen. It only renders what
/// [MyProjectsController] exposes; all business logic (fetching, tab
/// filtering, loading state) lives in the controller/repository/data
/// source, never here — same rule `HomePage` follows.
class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProjectsController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      // index 1 = "Mis proyectos" tab selected in the shared bottom nav.
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis proyectos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: HomeColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // El flujo de creación completo llega en una
                          // próxima etapa; por ahora el botón solo debe
                          // estar presente y preparado.
                          Get.snackbar(
                            'Crear proyecto',
                            'Publicar un proyecto nuevo llega en una próxima entrega.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: HomeColors.circlePurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Proyectos que creas',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(
                    () => MyProjectsTabs(
                      publishedCount: controller.publishedProjects.length,
                      draftsCount: controller.draftProjects.length,
                      showingDrafts: controller.showingDrafts.value,
                      onSelectPublished: controller.showPublished,
                      onSelectDrafts: controller.showDrafts,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<MyProject> items = controller.visibleProjects;

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      controller.showingDrafts.value
                          ? 'Todavía no tienes borradores.'
                          : 'Todavía no has creado proyectos.',
                      style: const TextStyle(color: HomeColors.textSecondary),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.getMyProjects,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item.isPlaceholder) {
                        return const MyProjectPlaceholderCard();
                      }
                      return MyProjectCard(project: item);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
