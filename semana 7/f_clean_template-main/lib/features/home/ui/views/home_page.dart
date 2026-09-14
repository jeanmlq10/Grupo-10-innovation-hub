import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_colors.dart';
import '../viewmodels/home_controller.dart';
import '../widgets/create_idea_card.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';

/// "Explorar proyectos" — the Home of Movil.
///
/// This is the View: it only renders what [HomeController] exposes. All
/// business logic (fetching projects, filtering, loading state) lives in
/// the controller/repository/data source, never here.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar proyectos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Descubre ideas y únete\na las que te inspiren',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: HomeColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ProjectSearchBar(onChanged: controller.updateSearch),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final projects = controller.filteredProjects;

                if (projects.isEmpty) {
                  return const Center(
                    child: Text(
                      'No encontramos proyectos con ese nombre.',
                      style: TextStyle(color: HomeColors.textSecondary),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.getProjects,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: projects.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const CreateIdeaCard();
                      }
                      final project = projects[index - 1];
                      return ProjectCard(project: project);
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
