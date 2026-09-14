import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/my_project.dart';
import '../../domain/repositories/i_my_projects_repository.dart';

/// ViewModel for "Mis proyectos". Owns the reactive state the View
/// observes with [Obx] — it never talks to a data source directly, only
/// to [IMyProjectsRepository]. Same pattern as `HomeController`.
class MyProjectsController extends GetxController with UiLoggy {
  MyProjectsController(this.repository);

  final IMyProjectsRepository repository;

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
    _all.value = await repository.getMyProjects();
    isLoading.value = false;
  }

  void showPublished() => showingDrafts.value = false;

  void showDrafts() => showingDrafts.value = true;
}
