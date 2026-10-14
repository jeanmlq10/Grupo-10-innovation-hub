import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/home_controller.dart';
import 'package:f_clean_template/features/projects/ui/widgets/create_idea_card.dart';
import 'package:f_clean_template/features/projects/ui/widgets/explore_filter_tabs.dart';
import 'package:f_clean_template/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:f_clean_template/features/projects/ui/widgets/project_card.dart';
import 'package:f_clean_template/features/projects/ui/widgets/project_search_bar.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/features/projects/ui/views/explore_filters_page.dart';
import 'package:f_clean_template/features/projects/ui/widgets/active_filters_bar.dart';
import 'package:f_clean_template/features/projects/ui/widgets/explore_filter_labels.dart';
import 'package:f_clean_template/features/auth/ui/widgets/login_required_dialog.dart';

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
                      // "Filtros" (requerimiento 1.2): abre el panel y
                      // muestra cuántas secciones están activas.
                      Obx(() {
                        final active = controller.filters.value.activeCount;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Badge(
                            isLabelVisible: active > 0,
                            label: Text('$active'),
                            backgroundColor: HomeColors.flowPurple,
                            child: Material(
                              color: HomeColors.flowLavender,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () =>
                                    Get.to(() => const ExploreFiltersPage()),
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: HomeColors.flowAccent,
                                    size: 21,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      Obx(() {
                        final user = auth.loggedUser;
                        // Visitante: en vez de "Cerrar sesión", vuelve a la
                        // bienvenida para iniciar sesión o registrarse.
                        if (auth.isGuest) {
                          return Tooltip(
                            message: 'Iniciar sesión',
                            child: Material(
                              color: HomeColors.flowLavender,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: auth.leaveGuestMode,
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(
                                    Icons.login_rounded,
                                    color: HomeColors.flowAccent,
                                    size: 21,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
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
                        ? (auth.isGuest
                              ? const Text(
                                  'Modo visitante · solo puedes explorar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: HomeColors.flowMeta,
                                  ),
                                )
                              : const SizedBox.shrink())
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
                      onSelectFollowed: () {
                        // Seguir proyectos requiere cuenta.
                        if (!requireSession()) return;
                        controller.showFollowed();
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  ProjectSearchBar(onChanged: controller.updateSearch),
                  // Filtros activos bajo el buscador (solo si hay alguno).
                  Obx(() {
                    final labels = ExploreFilterLabels.activeChips(
                      controller.filters.value,
                    );
                    if (labels.isEmpty) return const SizedBox(height: 16);
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: ActiveFiltersBar(
                        labels: labels,
                        onOpenFilters: () =>
                            Get.to(() => const ExploreFiltersPage()),
                        onClear: controller.clearFilters,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final projects = controller.filteredProjects;

                // No se pudo hablar con Roble (sin internet, tiempo agotado,
                // tabla no pública para el visitante...): se dice eso, no
                // "no hay proyectos", y se ofrece reintentar.
                if (controller.loadError.value.isNotEmpty &&
                    controller.projects.isEmpty) {
                  return _LoadErrorView(
                    message: controller.loadError.value,
                    onRetry: controller.getProjects,
                  );
                }
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

                final emptyMessage = !controller.filters.value.isEmpty
                    ? 'Ningún proyecto coincide con tus filtros.'
                    : controller.showingFollowed.value
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

/// Estado de error de Explorar: no se pudo cargar desde Roble.
class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: HomeColors.flowEmpty,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: HomeColors.flowSlate),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: HomeColors.flowPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
