import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';
import 'package:f_clean_template/features/projects/domain/models/my_project.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/projects/ui/widgets/my_project_card.dart';
import 'package:f_clean_template/features/projects/ui/widgets/my_project_placeholder_card.dart';
import 'package:f_clean_template/features/projects/ui/widgets/my_projects_tabs.dart';

/// "Mis proyectos": proyectos publicados y borradores, con editar y eliminar.
class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  late final MyProjectsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MyProjectsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyProjects();
    });
  }

  Future<void> _confirmDelete(MyProject item) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('¿Eliminar borrador?'),
        content: Text(
          'Se eliminará "${item.name}" y sus tareas. Esta acción no se puede '
          'deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFD9534F)),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (await controller.deleteDraft(item.id)) {
      Get.snackbar(
        'Borrador eliminado',
        '"${item.name}" ya no está en tus borradores.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        onTap: () => Get.to(() => const CreateProjectPage()),
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
                      final isUserProject = controller.isUserProject(
                        item.id,
                      );
                      return MyProjectCard(
                        project: item,
                        onTap: () async {
                          if (!isUserProject) return;
                          final project = controller.userProject(item.id);
                          if (project == null) return;
                          if (project.isDraft) {
                            await Get.to(
                              () =>
                                  CreateProjectPage(editProjectId: project.id),
                            );
                          } else {
                            await Get.to(
                              () => ProjectDetailPage(project: project),
                            );
                          }
                          controller.getMyProjects();
                        },
                        onEdit: isUserProject
                            ? () async {
                                await Get.to(
                                  () =>
                                      CreateProjectPage(editProjectId: item.id),
                                );
                                controller.getMyProjects();
                              }
                            : null,
                        onDelete: isUserProject && item.isDraft
                            ? () => _confirmDelete(item)
                            : null,
                      );
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
