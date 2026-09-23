import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';
import '../../../home/domain/models/project.dart';

import '../../../shared_projects/domain/models/participation_request.dart';
import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';
import '../../domain/models/my_project.dart';
import '../../domain/repositories/i_my_projects_repository.dart';

/// ViewModel for "Mis proyectos". Owns the reactive state the View
/// observes with [Obx] — it never talks to a data source directly, only
/// to [IMyProjectsRepository] (for the example entries) and
/// [ISharedProjectsRepository] (for anything created through "Crear
/// proyecto").
///
/// The two lists are merged here, at read time, into a single
/// `MyProject` list — the shared, user-created projects are converted
/// into `MyProject` only for *display* (so the existing `MyProjectCard`
/// widget can render them unchanged); the one real, persisted copy of
/// each stays in `ISharedProjectsRepository`.
class MyProjectsController extends GetxController with UiLoggy {
  MyProjectsController(this.repository, this.sharedRepository);

  final IMyProjectsRepository repository;
  final ISharedProjectsRepository sharedRepository;

  final RxList<MyProject> _all = <MyProject>[].obs;

  /// The user's Roble projects from the last load, by id — used to open
  /// the right screen when a card is tapped.
  final Map<String, Project> _userProjects = {};

  bool isUserProject(String id) => _userProjects.containsKey(id);

  Project? userProject(String id) => _userProjects[id];
  final RxBool isLoading = false.obs;

  /// `false` shows the "Mis proyectos" (published) tab, `true` shows
  /// "Mis borradores".
  final RxBool showingDrafts = false.obs;

  List<MyProject> get publishedProjects =>
      _all.where((project) => !project.isDraft).toList();

  List<MyProject> get draftProjects =>
      _all.where((project) => project.isDraft).toList();

  /// The list the currently-selected tab should render.
  List<MyProject> get visibleProjects =>
      showingDrafts.value ? draftProjects : publishedProjects;

  @override
  void onInit() {
    getMyProjects();
    super.onInit();
  }

  /// Reloads from Roble: projects created by the current user (drafts =
  /// `isDraft == true`, published = `false`) and pending requests.
  Future<void> getMyProjects() async {
    loggy.debug('MyProjectsController: Getting my projects');
    isLoading.value = true;
    try {
      final examples = await repository.getMyProjects();
      final results = await Future.wait([
        sharedRepository.getMine(),
        sharedRepository.requestsForMyProjects(),
      ]);
      final mine = results[0] as List<Project>;
      final requests = results[1] as List<ParticipationRequest>;

      _userProjects
        ..clear()
        ..addEntries(mine.map((project) => MapEntry(project.id, project)));

      // Specific tasks per project (table project_tasks), for the card.
      final taskCounts = await Future.wait(
        mine.map(
          (project) => sharedRepository
              .tasksFor(project.id)
              .then((tasks) => tasks.length)
              .catchError((_) => 0),
        ),
      );
      final taskCountById = {
        for (var i = 0; i < mine.length; i++) mine[i].id: taskCounts[i],
      };

      final userProjects = mine.map((project) {
        final pendingRequests = requests
            .where(
              (request) =>
                  request.projectId == project.id &&
                  request.status == RequestStatus.pending,
            )
            .length;
        return MyProject(
          id: project.id,
          name: project.name.isEmpty ? 'Borrador sin nombre' : project.name,
          description: project.description,
          status: project.isDraft ? 'Borrador' : 'Publicado',
          isDraft: project.isDraft,
          // Real members who joined (accepted requests).
          membersCount: project.acceptedMembersCount,
          tasksCount: taskCountById[project.id] ?? 0,
          requestsCount: pendingRequests,
        );
      }).toList();
      _all.value = [...examples, ...userProjects];
    } catch (error) {
      loggy.error('MyProjectsController: could not load: $error');
      Get.snackbar(
        'Mis proyectos',
        errorMessage(error, fallback: 'No se pudieron cargar tus proyectos.'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showPublished() => showingDrafts.value = false;

  void showDrafts() => showingDrafts.value = true;
}
