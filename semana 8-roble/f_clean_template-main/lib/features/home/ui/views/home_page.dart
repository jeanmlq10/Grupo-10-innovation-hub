import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_colors.dart';
import '../viewmodels/home_controller.dart';
import '../widgets/create_idea_card.dart';
import '../widgets/explore_filter_tabs.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';
import '../../../auth/ui/viewmodels/authentication_controller.dart';
import '../../../shared_projects/ui/views/project_detail_page.dart';

/// "Explorar proyectos" — the Home of Movil.
///
/// This is the View: it only renders what [HomeController] exposes. All
/// business logic (fetching projects, filtering, loading state) lives in
/// the controller/repository/data source, never here.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthenticationController>();

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Explorar proyectos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                      ),
                      Obx(() {
                        final user = auth.loggedUser;
                        return IconButton(
                          tooltip: user == null
                              ? 'Cerrar sesion'
                              : '${user.name}\n${user.email}',
                          onPressed: () async {
                            await auth.logOut();
                            Get.offAllNamed('/');
                          },
                          icon: CircleAvatar(
                            radius: 18,
                            backgroundImage: user?.photoUrl == null
                                ? null
                                : NetworkImage(user!.photoUrl!),
                            backgroundColor: HomeColors.navSelectedBackground,
                            child: user?.photoUrl == null
                                ? const Icon(
                                    Icons.logout,
                                    color: HomeColors.primaryPurple,
                                    size: 19,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                  Obx(
                    () => auth.loggedUser == null
                        ? const SizedBox.shrink()
                        : Text(
                            auth.loggedUser!.career?.isNotEmpty == true
                                ? '${auth.loggedUser!.name} · ${auth.loggedUser!.career}'
                                : auth.loggedUser!.email,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: HomeColors.textSecondary,
                            ),
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
                  Obx(
                    () => ExploreFilterTabs(
                      showingFollowed: controller.showingFollowed.value,
                      onSelectAll: controller.showAll,
                      onSelectFollowed: controller.showFollowed,
                    ),
                  ),
                  const SizedBox(height: 14),
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
                final hasSearch = controller.searchQuery.value
                    .trim()
                    .isNotEmpty;

                // A search with no matches is its own message and skips
                // "Crea otra idea" — that's about narrowing an existing
                // list, not the "nothing published yet" empty state.
                if (projects.isEmpty && hasSearch) {
                  return const Center(
                    child: Text(
                      'No encontramos proyectos con ese nombre.',
                      style: TextStyle(color: HomeColors.textSecondary),
                    ),
                  );
                }

                final emptyMessage = controller.showingFollowed.value
                    ? 'Todavía no sigues ningún proyecto.'
                    : 'Todavía no hay proyectos publicados. '
                          '¡Crea el primero!';

                return RefreshIndicator(
                  onRefresh: controller.getProjects,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: projects.isEmpty ? 2 : projects.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const CreateIdeaCard();
                      }
                      if (projects.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: HomeColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      final project = projects[index - 1];
                      return ProjectCard(
                        project: project,
                        onTap: () =>
                            Get.to(() => ProjectDetailPage(project: project)),
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
