import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// ViewModel shared by every step of the "Crear proyecto" wizard.
class CreateProjectController extends GetxController with UiLoggy {
  CreateProjectController(this.projectRepository, this.taskRepository, this.session);

  final IProjectRepository projectRepository;
  final ITaskRepository taskRepository;
  final AuthenticationController session;

  String? get _userId => session.loggedUser?.userId;

  static const Duration _typingDebounce = Duration(milliseconds: 700);

  String draftId = '';
  bool isEditing = false;

  static const List<String> teamRoleOrder = [
    'Desarrollador/a',
    'Diseñador/a',
    'Investigador/a',
    'Comunicador/a',
    'Líder de proyecto',
    'Otro',
  ];

  static const List<String> _fixedRoles = [
    'Desarrollador/a',
    'Diseñador/a',
    'Investigador/a',
    'Comunicador/a',
    'Líder de proyecto',
  ];

  final RxString name = ''.obs;
  final RxString description = ''.obs;

  final RxMap<String, int> teamRoles = <String, int>{}.obs;

  final RxString otherRoleName = ''.obs;

  final RxList<ProjectTask> tasks = <ProjectTask>[].obs;

  final RxnString duration = RxnString();
  final RxnString audience = RxnString();

  final Rxn<DateTime> teamDeadline = Rxn<DateTime>();

  final RxBool isSaving = false.obs;

  Project? _stored;
  Timer? _saveTimer;
  Future<void> _saveChain = Future.value();
  bool _tasksDirty = false;

  bool get canContinue => name.value.trim().isNotEmpty;

  int get totalTeamMembers =>
      teamRoles.values.fold(0, (sum, count) => sum + count);

  @override
  void onClose() {
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      unawaited(_enqueueSave().catchError((_) {}));
    }
    super.onClose();
  }

  void startNewDraft() {
    _saveTimer?.cancel();
    _stored = null;
    draftId = '';
    isEditing = false;
    _tasksDirty = false;
    name.value = '';
    description.value = '';
    teamRoles.clear();
    otherRoleName.value = '';
    tasks.clear();
    duration.value = null;
    audience.value = null;
    teamDeadline.value = null;
  }

  Future<bool> loadForEdit(String id) async {
    _saveTimer?.cancel();
    try {
      final project = await projectRepository.getById(id, viewerId: _userId);
      if (project == null || project.createdBy != _userId) {
        return false;
      }
      final projectTasks = await taskRepository.forProject(id);

      _stored = project;
      draftId = project.id;
      isEditing = true;
        _tasksDirty = false;
      name.value = project.name;
      description.value = project.description;

      teamRoles.clear();
      otherRoleName.value = '';
      project.teamRoles.forEach((role, count) {
        if (_fixedRoles.contains(role)) {
          teamRoles[role] = count;
        } else {
          teamRoles['Otro'] = (teamRoles['Otro'] ?? 0) + count;
          if (role != 'Otro') otherRoleName.value = role;
        }
      });

      tasks.assignAll(projectTasks);
      duration.value = project.duration;
      audience.value = project.audience;
      teamDeadline.value = project.teamDeadline;
      return true;
    } catch (error) {
      _reportError(error);
      return false;
    }
  }

  void updateName(String value) {
    name.value = value;
    _scheduleSave();
  }

  void updateDescription(String value) {
    description.value = value;
    _scheduleSave();
  }

  int roleCount(String role) => teamRoles[role] ?? 0;

  void incrementRole(String role) {
    teamRoles[role] = roleCount(role) + 1;
    _scheduleSave();
  }

  void decrementRole(String role) {
    final current = roleCount(role);
    if (current <= 0) return;
    teamRoles[role] = current - 1;
    _scheduleSave();
  }

  void setOtherRoleName(String value) {
    otherRoleName.value = value;
    _scheduleSave();
  }

  void addTask(String title) {
    final clean = title.trim();
    if (clean.isEmpty) return;
    tasks.add(ProjectTask(id: '', projectId: draftId, title: clean));
    _tasksDirty = true;
    _scheduleSave();
  }

  void removeTask(int index) {
    if (index < 0 || index >= tasks.length) return;
    tasks.removeAt(index);
    _tasksDirty = true;
    _scheduleSave();
  }

  void incrementTask(int index) {
    if (index < 0 || index >= tasks.length) return;
    final task = tasks[index];
    tasks[index] = task.copyWith(numberNeeded: task.numberNeeded + 1);
    _tasksDirty = true;
    _scheduleSave();
  }

  void decrementTask(int index) {
    if (index < 0 || index >= tasks.length) return;
    final task = tasks[index];
    if (task.numberNeeded <= 1) return;
    tasks[index] = task.copyWith(numberNeeded: task.numberNeeded - 1);
    _tasksDirty = true;
    _scheduleSave();
  }

  void setTeamDeadline(DateTime value) {
    teamDeadline.value = DateTime(value.year, value.month, value.day);
    _scheduleSave();
  }

  void updateTaskDescription(int index, String value) {
    if (index < 0 || index >= tasks.length) return;
    if (tasks[index].description == value) return;
    tasks[index] = tasks[index].copyWith(description: value);
    _tasksDirty = true;
    _scheduleSave();
  }

  void setTaskDeadline(int index, DateTime value) {
    if (index < 0 || index >= tasks.length) return;
    tasks[index] = tasks[index].copyWith(
      deadline: DateTime(value.year, value.month, value.day),
    );
    _tasksDirty = true;
    _scheduleSave();
  }

  void selectDuration(String value) {
    duration.value = value;
    _scheduleSave();
  }

  void selectAudience(String value) {
    audience.value = value;
    unawaited(flush().catchError(_reportError));
  }

  Future<void> flush() {
    _saveTimer?.cancel();
    return _enqueueSave();
  }

  Future<bool> finish() async {
    try {
      await flush();
      return draftId.isNotEmpty;
    } catch (error) {
      _reportError(error);
      return false;
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_typingDebounce, () {
      unawaited(_enqueueSave().catchError(_reportError));
    });
  }

  Future<void> _enqueueSave() {
    final next = _saveChain.then((_) => _saveNow());
    _saveChain = next.catchError((Object _) {});
    return next;
  }

  Future<void> _saveNow() async {
    isSaving.value = true;
    try {
      final user = session.loggedUser;
      if (user == null) {
        throw StateError('Debes iniciar sesión para guardar.');
      }
      final base =
          _stored ??
          Project(id: '', name: '', description: '', categories: const []);
      final updated = base.copyWith(
        name: name.value,
        description: description.value,
        canApply: true,
        teamRoles: _resolvedTeamRoles,
        duration: duration.value,
        audience: audience.value,
        isDraft: audience.value != 'Toda la comunidad',
        teamDeadline: teamDeadline.value,
        createdByName: base.createdByName ?? user?.name,
      );

      if (draftId.isEmpty) {
        _stored = await projectRepository.create(updated.copyWith(createdBy: user.userId));
        draftId = _stored!.id;
        _tasksDirty = tasks.isNotEmpty;
      } else {
        _stored = await projectRepository.save(updated);
      }

      if (_tasksDirty) {
        _tasksDirty = false;
        final stored = await taskRepository.sync(draftId, tasks.toList());
        if (!_tasksDirty) tasks.assignAll(stored);
      }
    } finally {
      isSaving.value = false;
    }
  }

  void _reportError(Object error) {
    loggy.error('CreateProjectController: save failed: $error');
    Get.snackbar(
      'No se pudo guardar',
      errorMessage(error, fallback: 'Revisa tu conexión e inténtalo de nuevo.'),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Map<String, int> get _resolvedTeamRoles {
    final resolved = <String, int>{};
    teamRoles.forEach((role, count) {
      if (count <= 0) return;
      if (role == 'Otro') {
        final customName = otherRoleName.value.trim();
        resolved[customName.isEmpty ? 'Otro' : customName] = count;
      } else {
        resolved[role] = count;
      }
    });
    return resolved;
  }
}
