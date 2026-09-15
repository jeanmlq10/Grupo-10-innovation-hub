import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

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
      final membersNeeded = project.teamRoles.values.fold(
        0,
        (sum, count) => sum + count,
      );
      return MyProject(
        id: project.id,
        name: project.name.isEmpty ? 'Borrador sin nombre' : project.name,
        description: project.description,
        status: 'En desarrollo',
        isDraft: project.isDraft,
        membersCount: membersNeeded,
        tasksCount: project.teamRoles.length,
        requestsCount: 0,
      );
    }).toList();
    _all.value = [...examples, ...userProjects];
    isLoading.value = false;
  }

  void showPublished() => showingDrafts.value = false;

  void showDrafts() => showingDrafts.value = true;
}
