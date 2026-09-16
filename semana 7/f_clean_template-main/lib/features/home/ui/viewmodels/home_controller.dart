import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

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
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  /// `false` = "Todos", `true` = "Seguidos".
  final RxBool showingFollowed = false.obs;

  List<Project> get projects => _projects;

  /// Projects filtered by the "Todos"/"Seguidos" toggle and by
  /// [searchQuery] (case-insensitive, matches name). Which projects are
  /// followed lives in `ISharedProjectsRepository` (the single shared
  /// store), not a copy kept here — "Seguir" in the participation flow
  /// writes to that same place.
  List<Project> get filteredProjects {
    final base = showingFollowed.value
        ? _projects
            .where((project) => sharedRepository.isFollowing(project.id))
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

  Future<void> getProjects() async {
    loggy.debug('HomeController: Getting projects');
    isLoading.value = true;
    final examples = await repository.getProjects();
    final published = sharedRepository
        .getAll()
        .where(
          (project) =>
              !project.isDraft && project.audience == 'Toda la comunidad',
        )
        .toList();
    _projects.value = [...examples, ...published];
    isLoading.value = false;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void showAll() => showingFollowed.value = false;

  void showFollowed() => showingFollowed.value = true;
}
