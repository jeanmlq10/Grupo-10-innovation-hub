import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../shared_projects/domain/repositories/i_shared_projects_repository.dart';

/// ViewModel shared by every step of the "Crear proyecto" wizard.
///
/// Unlike the earlier stage, this controller no longer keeps its own
/// private draft storage — it reads and writes directly to
/// [ISharedProjectsRepository], the single store that "Mis proyectos",
/// "Explorar proyectos" and "Ver proyecto" all read from too. That's
/// what makes the project the wizard is building the SAME object that
/// later shows up everywhere else, instead of a separate copy that gets
/// translated into a `MyProject`/`Project` at the very end.
class CreateProjectController extends GetxController {
  CreateProjectController(this.repository);

  final ISharedProjectsRepository repository;

  /// The id of the [Project] this wizard session is building. Assigned
  /// in [onInit], when the draft is first created.
  late final String draftId;

  /// The fixed set of roles offered in "Equipo necesario", in display
  /// order. A role not present in [teamRoles] simply hasn't been touched
  /// (equivalent to a count of 0).
  static const List<String> teamRoleOrder = [
    'Desarrollador/a',
    'Diseñador/a',
    'Investigador/a',
    'Comunicador/a',
    'Líder de proyecto',
    'Otro',
  ];

  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final RxMap<String, int> teamRoles = <String, int>{}.obs;
  final RxnString duration = RxnString();
  final RxnString audience = RxnString();

  /// Whether "Nueva idea" can advance to "Información básica".
  bool get canContinue => name.value.trim().isNotEmpty;

  /// Total people requested across every role — used as the new
  /// project's "Miembros" count once published.
  int get totalTeamMembers =>
      teamRoles.values.fold(0, (sum, count) => sum + count);

  @override
  void onInit() {
    // Every fresh attempt at "Crear proyecto" is a brand-new draft,
    // stored in the shared repository from this very first instant —
    // that's what lets it show up under "Mis borradores" even before
    // the user finishes the wizard.
    final draft = repository.startDraft();
    draftId = draft.id;
    super.onInit();
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

  void selectDuration(String value) {
    duration.value = value;
    _persist();
  }

  void selectAudience(String value) {
    audience.value = value;
    _persist();
  }

  /// Flips the draft to published. Same object, same id — nothing new
  /// is created here.
  void publish() => repository.publish(draftId);

  void _persist() {
    repository.updateDraft(
      Project(
        id: draftId,
        name: name.value,
        description: description.value,
        categories: const [],
        canApply: true,
        teamRoles: Map<String, int>.from(teamRoles),
        duration: duration.value,
        audience: audience.value,
        isDraft: true,
      ),
    );
  }
}
