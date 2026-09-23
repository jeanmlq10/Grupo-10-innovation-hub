import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';
import '../../../auth/ui/viewmodels/authentication_controller.dart';
import '../../../home/domain/models/project.dart';
import '../../../shared_projects/domain/models/project_task.dart';
import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';

/// ViewModel shared by every step of the "Crear proyecto" wizard.
///
/// The project lives in Roble (via [ISharedProjectsRepository]); this
/// controller only keeps the reactive copy the screens render. Changes are
/// saved automatically (debounced while typing, immediately for choices
/// like the audience) to the SAME Roble row: the row is created on the
/// first save and then always updated, never duplicated.
///
/// Audience rule: "Solo yo" → `isDraft = true` (only in "Mis borradores");
/// "Toda la comunidad" → `isDraft = false` (visible in "Explorar"). While
/// no audience is chosen yet the project stays a draft.
class CreateProjectController extends GetxController with UiLoggy {
  CreateProjectController(this.repository);

  final ISharedProjectsRepository repository;

  static const Duration _typingDebounce = Duration(milliseconds: 700);

  /// Roble id of the project being built. Empty until the first save.
  String draftId = '';
  bool isEditing = false;

  /// The fixed roles offered in "Equipo necesario" as buttons, in
  /// display order. "Otro" is always last and is special: its actual
  /// team-role name comes from [otherRoleName], not the literal word
  /// "Otro" — see [_resolvedTeamRoles].
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

  /// Long-term team roles: role → people needed.
  final RxMap<String, int> teamRoles = <String, int>{}.obs;

  /// The custom role name typed for "Otro" (e.g. "Editor de video").
  final RxString otherRoleName = ''.obs;

  /// Specific tasks ("Diseñar la interfaz"...), separate from team roles.
  final RxList<ProjectTask> tasks = <ProjectTask>[].obs;

  final RxnString duration = RxnString();
  final RxnString audience = RxnString();

  /// `true` while a save to Roble is running.
  final RxBool isSaving = false.obs;

  Project? _stored;
  Timer? _saveTimer;
  Future<void> _saveChain = Future.value();
  bool _tasksDirty = false;

  /// Whether "Nueva idea" can advance to "Información básica".
  bool get canContinue => name.value.trim().isNotEmpty;

  /// Total people requested across every role.
  int get totalTeamMembers =>
      teamRoles.values.fold(0, (sum, count) => sum + count);

  @override
  void onClose() {
    // Leaving the wizard with a pending autosave: still send it.
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
  }

  /// Loads one of the user's own projects from Roble for editing.
  Future<bool> loadForEdit(String id) async {
    _saveTimer?.cancel();
    try {
      final project = await repository.getById(id);
      if (project == null || project.createdBy != repository.currentUserId) {
        return false;
      }
      final projectTasks = await repository.tasksFor(id);

      _stored = project;
      draftId = project.id;
      isEditing = true;
        _tasksDirty = false;
      name.value = project.name;
      description.value = project.description;

      // Any role name that isn't one of the five fixed roles is the
      // custom "Otro" entry — fold it back onto the "Otro" counter/field.
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
      return true;
    } catch (error) {
      _reportError(error);
      return false;
    }
  }

  // --- Field updates (autosaved) ---

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

  void selectDuration(String value) {
    duration.value = value;
    _scheduleSave();
  }

  /// Saved to Roble right away: "Solo yo" keeps it in "Mis borradores",
  /// "Toda la comunidad" makes it visible in "Explorar" — same row.
  void selectAudience(String value) {
    audience.value = value;
    unawaited(flush().catchError(_reportError));
  }

  /// Sends any pending change now. Throws if Roble rejects the save.
  Future<void> flush() {
    _saveTimer?.cancel();
    return _enqueueSave();
  }

  /// Last step ("Publicar proyecto" / "Guardar cambios"): makes sure
  /// everything is stored in Roble. Returns `false` (and shows why) if not.
  Future<bool> finish() async {
    try {
      await flush();
      return draftId.isNotEmpty;
    } catch (error) {
      _reportError(error);
      return false;
    }
  }

  // --- Persistence ---

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_typingDebounce, () {
      unawaited(_enqueueSave().catchError(_reportError));
    });
  }

  /// Saves run one after another, so the first one (which creates the
  /// row) finishes before the next one updates it.
  Future<void> _enqueueSave() {
    final next = _saveChain.then((_) => _saveNow());
    _saveChain = next.catchError((Object _) {});
    return next;
  }

  Future<void> _saveNow() async {
    isSaving.value = true;
    try {
      final user = Get.find<AuthenticationController>().loggedUser;
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
        createdByName: base.createdByName ?? user?.name,
      );

      if (draftId.isEmpty) {
        _stored = await repository.createProject(updated);
        draftId = _stored!.id;
        _tasksDirty = tasks.isNotEmpty;
      } else {
        _stored = await repository.saveProject(updated);
      }

      if (_tasksDirty) {
        _tasksDirty = false;
        final stored = await repository.setTasks(draftId, tasks.toList());
        // Keep Roble's ids unless the user edited the list meanwhile (a new
        // save is already scheduled in that case).
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

  /// Turns the working `teamRoles` map (keyed by the fixed role names,
  /// plus the literal "Otro" bucket) into what actually gets saved: the
  /// "Otro" count moves under whatever name the user typed in
  /// [otherRoleName], falling back to the literal word "Otro" if left
  /// blank. Roles with a count of 0 are dropped entirely.
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
