import 'package:get/get.dart';

import '../../domain/models/new_project_draft.dart';
import '../../domain/repositories/i_create_project_repository.dart';

/// ViewModel shared by every step of the "Crear proyecto" wizard — it
/// holds the draft's reactive fields so all of them read/write the same
/// state, and it's the only thing any step talks to (never the
/// repository or data source directly).
class CreateProjectController extends GetxController {
  CreateProjectController(this.repository);

  final ICreateProjectRepository repository;

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
    // Every fresh attempt at "Crear proyecto" starts blank — an
    // abandoned previous attempt should never leak into a new one.
    repository.resetDraft();
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

  void _persist() {
    repository.saveDraft(
      NewProjectDraft(
        name: name.value,
        description: description.value,
        teamRoles: Map<String, int>.from(teamRoles),
        duration: duration.value,
        audience: audience.value,
      ),
    );
  }
}
