import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

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

  Future<void> getMyProjects() async {
    loggy.debug('MyProjectsController: Getting my projects');
    isLoading.value = true;
    final examples = await repository.getMyProjects();
    final userProjects = sharedRepository.getAll().map((project) {
      final pendingRequests = sharedRepository
          .requestsFor(project.id)
          .where((request) => request.status == RequestStatus.pending)
          .length;
      return MyProject(
        id: project.id,
        name: project.name.isEmpty ? 'Borrador sin nombre' : project.name,
        description: project.description,
        // No more "En desarrollo": a project is either still being
        // drafted ("Borrador") or already published ("Publicado") —
        // publicly (Toda la comunidad) or privately (Solo yo), the
        // label is the same; only Explorar cares about the difference.
        status: project.isDraft ? 'Borrador' : 'Publicado',
        isDraft: project.isDraft,
        // Real members who joined (an accepted request) — NOT how many
        // the creator is still looking for (that's `teamRoles`/"Tareas").
        membersCount: project.acceptedMembersCount,
        tasksCount: project.teamRoles.length,
        requestsCount: pendingRequests,
      );
    }).toList();
    _all.value = [...examples, ...userProjects];
    isLoading.value = false;
  }

  void showPublished() => showingDrafts.value = false;

  void showDrafts() => showingDrafts.value = true;
}
