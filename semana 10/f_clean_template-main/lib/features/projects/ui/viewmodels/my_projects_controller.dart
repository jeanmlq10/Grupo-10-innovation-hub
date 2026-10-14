import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';

import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/requests/domain/repositories/i_request_repository.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/my_project.dart';

/// ViewModel for "Mis proyectos". Owns the reactive state the View
/// observes with [Obx] — it never talks to a data source directly, only
/// to [the feature repositories] (for the example entries) and
/// the feature repositories (for anything created through "Crear
/// proyecto").
class MyProjectsController extends GetxController with UiLoggy {
  MyProjectsController(this.projectRepository, this.taskRepository, this.requestRepository, this.session);

  final IProjectRepository projectRepository;
  final ITaskRepository taskRepository;
  final IRequestRepository requestRepository;
  final AuthenticationController session;

  final RxList<MyProject> _all = <MyProject>[].obs;

  final Map<String, Project> _userProjects = {};

  bool isUserProject(String id) => _userProjects.containsKey(id);

  Project? userProject(String id) => _userProjects[id];
  final RxBool isLoading = false.obs;

  final RxBool showingDrafts = false.obs;

  List<MyProject> get publishedProjects =>
      _all.where((project) => !project.isDraft).toList();

  List<MyProject> get draftProjects =>
      _all.where((project) => project.isDraft).toList();

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
    try {
      final userId = session.loggedUser?.userId;
      final mine = userId == null
          ? <Project>[]
          : await projectRepository.ownedBy(userId);
      final received = userId == null
          ? <ParticipationRequest>[]
          : await requestRepository.forProjects(
              {for (final p in mine) p.id: p.name},
              ownerId: userId,
            );

      _userProjects
        ..clear()
        ..addEntries(mine.map((project) => MapEntry(project.id, project)));

      final taskCounts = await Future.wait(
        mine.map(
          (project) => taskRepository
              .forProject(project.id)
              .then((list) => list.length)
              .catchError((_) => 0),
        ),
      );
      final taskCountById = {
        for (var i = 0; i < mine.length; i++) mine[i].id: taskCounts[i],
      };

      final userProjects = mine.map((project) {
        final pendingRequests = received
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
          membersCount: project.acceptedMembersCount,
          tasksCount: taskCountById[project.id] ?? 0,
          requestsCount: pendingRequests,
        );
      }).toList();
      _all.value = userProjects;
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

  Future<bool> deleteDraft(String id) async {
    final me = session.loggedUser?.userId;
    final project = _userProjects[id];
    if (me == null || project == null || project.createdBy != me) {
      Get.snackbar(
        'Eliminar borrador',
        'Solo puedes eliminar tus propios borradores.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (!project.isDraft) {
      Get.snackbar(
        'Eliminar borrador',
        'Solo se pueden eliminar borradores.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    try {
      await projectRepository.delete(id);
      try {
        await taskRepository.deleteForProject(id);
      } catch (error) {
        loggy.warning('MyProjectsController: tareas sin borrar: $error');
      }
      _userProjects.remove(id);
      _all.removeWhere((p) => p.id == id);
      return true;
    } catch (error) {
      loggy.error('MyProjectsController: could not delete: $error');
      Get.snackbar(
        'Eliminar borrador',
        errorMessage(error, fallback: 'No se pudo eliminar el borrador.'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void showPublished() => showingDrafts.value = false;

  void showDrafts() => showingDrafts.value = true;
}
