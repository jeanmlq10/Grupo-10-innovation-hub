import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// ViewModel for the Home ("Explorar proyectos"). Owns the reactive state
/// the View observes with [Obx] — it never talks to a data source
/// directly, only to [IProjectRepository].
class HomeController extends GetxController with UiLoggy {
  HomeController(this.repository);

  final IProjectRepository repository;

  final RxList<Project> _projects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  List<Project> get projects => _projects;

  /// Projects filtered by [searchQuery] (case-insensitive, matches name).
  List<Project> get filteredProjects {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return _projects;
    return _projects
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
    _projects.value = await repository.getProjects();
    isLoading.value = false;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }
}
