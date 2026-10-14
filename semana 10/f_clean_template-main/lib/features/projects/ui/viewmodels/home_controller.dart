import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/follows/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/explore_filters.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// ViewModel for the Home ("Explorar proyectos"). Owns the reactive state
/// the View observes with [Obx] — it never talks to a data source
/// directly, only to [IProjectRepository] (for the example projects) and
/// the feature repositories (for anything published through "Crear
/// proyecto").
class HomeController extends GetxController with UiLoggy {
  HomeController(
    this.projectRepository,
    this.followRepository,
    this.session,
    this.taskRepository,
  );

  final IProjectRepository projectRepository;
  final IFollowRepository followRepository;
  final AuthenticationController session;

  final ITaskRepository taskRepository;

  final Rx<ExploreFilters> filters = ExploreFilters.none.obs;

  final RxSet<String> _openTaskProjectIds = <String>{}.obs;

  bool get isGuest => session.isGuest;

  final RxString loadError = ''.obs;

  Future<void>? _inFlight;

  final RxList<Project> _projects = <Project>[].obs;

  final RxSet<String> _followedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxBool showingFollowed = false.obs;

  List<Project> get projects => _projects;

  List<Project> get filteredProjects {
    final base = showingFollowed.value
        ? _projects
              .where((project) => _followedIds.contains(project.id))
              .toList()
        : _projects;
    final query = searchQuery.value.trim().toLowerCase();
    final searched = query.isEmpty
        ? base
        : base
              .where((project) => project.name.toLowerCase().contains(query))
              .toList();
    final active = filters.value;
    if (active.isEmpty) return searched;
    final now = DateTime.now();
    return searched
        .where(
          (project) => active.matches(
            project,
            hasOpenTasks: _openTaskProjectIds.contains(project.id),
            now: now,
          ),
        )
        .toList();
  }

  @override
  void onInit() {
    _sessionWorker = ever<bool>(session.loggedState, (logged) {
      if (logged) getProjects();
    });
    getProjects();
    super.onInit();
  }

  Worker? _sessionWorker;

  @override
  void onClose() {
    _sessionWorker?.dispose();
    super.onClose();
  }

  void applyFilters(ExploreFilters value) => filters.value = value;

  void clearFilters() => filters.value = ExploreFilters.none;

  Future<void> getProjects() =>
      _inFlight ??= _loadProjects().whenComplete(() => _inFlight = null);

  Future<void> _loadProjects() async {
    loggy.debug('HomeController: Getting projects');
    isLoading.value = true;
    try {
      final userId = session.loggedUser?.userId;
      final guest = session.isGuest;
      final results = await Future.wait([
        projectRepository.explorable(publicAccess: guest),
        userId == null
            ? Future.value(<String>{})
            : followRepository
                  .followedProjectIds(userId)
                  .catchError((Object _) => <String>{}),
        taskRepository
            .projectIdsWithOpenTasks(publicAccess: guest)
            .catchError((Object _) => <String>{}),
      ]);
      _projects.value = results[0] as List<Project>;
      _followedIds
        ..clear()
        ..addAll(results[1] as Set<String>);
      _openTaskProjectIds
        ..clear()
        ..addAll(results[2] as Set<String>);
      loadError.value = '';
    } catch (error) {
      loggy.error('HomeController: could not load projects: $error');
      final message = errorMessage(
        error,
        fallback: 'No se pudieron cargar los proyectos.',
      );
      loadError.value = message;
      Get.snackbar(
        'Explorar proyectos',
        message,
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
