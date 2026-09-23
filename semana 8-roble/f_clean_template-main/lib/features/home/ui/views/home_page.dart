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
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'Explorar proyectos',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: HomeColors.flowNavy,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Obx(() {
                        final user = auth.loggedUser;
                        return Tooltip(
                          message: user == null
                              ? 'Cerrar sesión'
                              : 'Cerrar sesión\n${user.email}',
                          child: Material(
                            color: HomeColors.flowLavender,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () async {
                                await auth.logOut();
                                Get.offAllNamed('/');
                              },
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Icon(
                                  Icons.logout,
                                  color: HomeColors.flowAccent,
                                  size: 21,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => auth.loggedUser == null
                        ? const SizedBox.shrink()
                        : Text(
                            auth.loggedUser!.career?.isNotEmpty == true
                                ? '${auth.loggedUser!.name} - ${auth.loggedUser!.career}'
                                : auth.loggedUser!.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: HomeColors.flowMeta,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Descubre ideas y únete\na las que te inspiren',
                    style: TextStyle(
                      fontSize: 15.5,
                      color: HomeColors.flowDescription,
                      height: 1.35,
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
                      style: TextStyle(color: HomeColors.flowEmpty),
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
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const CreateIdeaCard();
                      }
                      if (projects.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: Center(
                            child: Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: HomeColors.flowEmpty,
                              ),
                            ),
                          ),
                        );
                      }
                      final project = projects[index - 1];
                      return ProjectCard(
                        project: project,
                        onTap: () async {
                          await Get.to(
                            () => ProjectDetailPage(project: project),
                          );
                          // Follows/comments may have changed: reload.
                          controller.getProjects();
                        },
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
