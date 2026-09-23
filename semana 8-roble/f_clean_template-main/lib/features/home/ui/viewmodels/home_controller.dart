import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';

import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// ViewModel for the Home ("Explorar proyectos"). Owns the reactive state
/// the View observes with [Obx] — it never talks to a data source
/// directly, only to [IProjectRepository] (for the example projects) and
/// [ISharedProjectsRepository] (for anything published through "Crear
/// proyecto").
///
/// Only PUBLISHED shared projects with audience "Toda la comunidad" join
/// this feed — a project still being drafted, or published privately
/// ("Solo yo"), has no business showing up in public "Explorar
/// proyectos". They're merged in as the exact same [Project] object the
/// wizard was editing, never a converted copy.
class HomeController extends GetxController with UiLoggy {
  HomeController(this.repository, this.sharedRepository);

  final IProjectRepository repository;
  final ISharedProjectsRepository sharedRepository;

  final RxList<Project> _projects = <Project>[].obs;

  /// Ids the current user follows, loaded from Roble (`project_follows`).
  final RxSet<String> _followedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  /// `false` = "Todos", `true` = "Seguidos".
  final RxBool showingFollowed = false.obs;

  List<Project> get projects => _projects;

  /// Projects filtered by the "Todos"/"Seguidos" toggle and by
  /// [searchQuery] (case-insensitive, matches name). Which projects are
  /// followed comes from Roble, reloaded in [getProjects].
  List<Project> get filteredProjects {
    final base = showingFollowed.value
        ? _projects
              .where((project) => _followedIds.contains(project.id))
              .toList()
        : _projects;
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return base;
    return base
        .where((project) => project.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    getProjects();
    super.onInit();
  }

  /// Reloads the feed from Roble every time (never trusts old data):
  /// published "Toda la comunidad" projects and the user's follows.
  Future<void> getProjects() async {
    loggy.debug('HomeController: Getting projects');
    isLoading.value = true;
    try {
      final examples = await repository.getProjects();
      final results = await Future.wait([
        sharedRepository.getExplorable(),
        sharedRepository.followedProjectIds(),
      ]);
      _projects.value = [...examples, ...(results[0] as List<Project>)];
      _followedIds
        ..clear()
        ..addAll(results[1] as Set<String>);
    } catch (error) {
      loggy.error('HomeController: could not load projects: $error');
      Get.snackbar(
        'Explorar proyectos',
        errorMessage(error, fallback: 'No se pudieron cargar los proyectos.'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void showAll() => showingFollowed.value = false;

  void showFollowed() => showingFollowed.value = true;
}
