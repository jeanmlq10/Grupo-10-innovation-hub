import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../auth/ui/viewmodels/authentication_controller.dart';
import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';

/// ViewModel shared by every step of the "Crear proyecto" wizard.
///
/// This controller reads and writes directly to
/// [ISharedProjectsRepository], the single store that "Mis proyectos",
/// "Explorar proyectos" and "Ver proyecto" all read from too. That's
/// what makes the project the wizard is building the SAME object that
/// later shows up everywhere else, instead of a separate copy that gets
/// translated into a `MyProject`/`Project` at the very end.
class CreateProjectController extends GetxController {
  CreateProjectController(this.repository);

  final ISharedProjectsRepository repository;

  /// The id of the [Project] this wizard session is building. Assigned
  /// when the user starts a new project or opens one for editing.
  String draftId = '';
  bool isEditing = false;
  bool editingProjectWasDraft = false;

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
  final RxMap<String, int> teamRoles = <String, int>{}.obs;

  /// The custom role name typed for "Otro" (e.g. "Editor de video").
  final RxString otherRoleName = ''.obs;

  final RxnString duration = RxnString();
  final RxnString audience = RxnString();

  /// Whether "Nueva idea" can advance to "Información básica". Name is
  /// NOT required elsewhere in the wizard — this is the one place a
  /// value is expected, since it's what "Comencemos" asks for.
  bool get canContinue => name.value.trim().isNotEmpty;

  /// Total people requested across every role — used as the new
  /// project's "Miembros" count once published.
  int get totalTeamMembers =>
      teamRoles.values.fold(0, (sum, count) => sum + count);

  @override
  void onInit() {
    super.onInit();
  }

  void startNewDraft() {
    final user = Get.find<AuthenticationController>().loggedUser;
    final draft = repository.startDraft().copyWith(
      createdBy: user?.userId,
      createdByName: user?.name,
    );
    repository.updateDraft(draft);
    draftId = draft.id;
    isEditing = false;
    editingProjectWasDraft = true;
    name.value = '';
    description.value = '';
    teamRoles.clear();
    otherRoleName.value = '';
    duration.value = null;
    audience.value = null;
  }

  bool loadForEdit(String id) {
    final project = repository.getById(id);
    if (project == null) return false;
    draftId = project.id;
    isEditing = true;
    editingProjectWasDraft = project.isDraft;
    name.value = project.name;
    description.value = project.description;

    // Any role name that isn't one of the five fixed roles is the
    // custom "Otro" entry (or the literal fallback "Otro" if the user
    // never typed a name) — fold it back onto the "Otro" counter/field
    // so the fixed-role UI can display it.
    teamRoles.clear();
    otherRoleName.value = '';
    project.teamRoles.forEach((role, count) {
      if (_fixedRoles.contains(role)) {
        teamRoles[role] = count;
      } else {
        teamRoles['Otro'] = (teamRoles['Otro'] ?? 0) + count;
        if (role != 'Otro') {
          otherRoleName.value = role;
        }
      }
    });

    duration.value = project.duration;
    audience.value = project.audience;
    return true;
  }

  void updateName(String value) {
    name.value = value;
    _persist();
  }

  void updateDescription(String value) {
    description.value = value;
    _persist();
  }

  int roleCount(String role) => teamRoles[role] ?? 0;

  void incrementRole(String role) {
    teamRoles[role] = roleCount(role) + 1;
    _persist();
  }

  void decrementRole(String role) {
    final current = roleCount(role);
    if (current <= 0) return;
    teamRoles[role] = current - 1;
    _persist();
  }

  void setOtherRoleName(String value) {
    otherRoleName.value = value;
    _persist();
  }

  void selectDuration(String value) {
    duration.value = value;
    _persist();
  }

  void selectAudience(String value) {
    audience.value = value;
    _persist();
  }

  /// Publishes the current project while keeping the same local entity.
  void publish() => repository.publish(draftId);

  void saveDraft() {
    final current = repository.getById(draftId);
    if (current == null) return;
    repository.updateDraft(
      current.copyWith(
        name: name.value,
        description: description.value,
        teamRoles: _resolvedTeamRoles,
        duration: duration.value,
        audience: audience.value,
        isDraft: true,
        createdBy: current.createdBy,
        createdByName: current.createdByName,
      ),
    );
  }

  void saveChanges() {
    final current = repository.getById(draftId);
    if (current == null) return;
    repository.updateDraft(
      current.copyWith(
        name: name.value,
        description: description.value,
        teamRoles: _resolvedTeamRoles,
        duration: duration.value,
        audience: audience.value,
        isDraft: editingProjectWasDraft,
        createdBy: current.createdBy,
        createdByName: current.createdByName,
      ),
    );
  }

  void _persist() {
    // Read-modify-write off the CURRENT stored project (via copyWith)
    // instead of building a fresh `Project` from scratch — otherwise
    // every keystroke would silently reset fields this controller
    // doesn't track itself, like `acceptedMembersCount` (members who
    // already joined through an accepted request).
    final current = repository.getById(draftId);
    final base =
        current ??
        Project(id: draftId, name: '', description: '', categories: const []);
    final user = Get.find<AuthenticationController>().loggedUser;
    repository.updateDraft(
      base.copyWith(
        name: name.value,
        description: description.value,
        canApply: true,
        teamRoles: _resolvedTeamRoles,
        duration: duration.value,
        audience: audience.value,
        // While actively editing an existing project, autosaving on
        // every keystroke must NOT change its draft/published status —
        // only publish()/saveChanges() (an explicit action) should do
        // that. Otherwise, opening a private draft to fix a typo would
        // silently "publish" it the instant you typed a letter.
        isDraft: isEditing ? editingProjectWasDraft : true,
        createdBy: base.createdBy ?? user?.userId,
        createdByName: base.createdByName ?? user?.name,
      ),
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
