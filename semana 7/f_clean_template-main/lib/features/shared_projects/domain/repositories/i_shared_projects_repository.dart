import '../../../home/domain/models/project.dart';
import '../models/participation_request.dart';

/// The single source of truth for projects created through "Crear
/// proyecto" — reused by `create_project` (to write), `my_projects` and
/// `home` (to read and merge into their own lists), and by this
/// feature's own "Ver proyecto" / apply screens.
///
/// This is deliberately the ONLY place a user-created [Project] is
/// stored. `home`'s example projects (EcoCampus, etc.) and
/// `my_projects`'s example entries stay in their own local sources,
/// completely separate — this repository never touches those.
abstract class ISharedProjectsRepository {
  /// Creates a brand-new, blank draft project and stores it immediately
  /// — from this point on it exists (and shows under "Mis borradores")
  /// even before the user finishes the wizard.
  Project startDraft();

  /// Looks up a project by id — used by "Ver mi proyecto" (from the
  /// publish confirmation) and by the whole apply flow.
  Project? getById(String id);

  /// Every user-created project, published or still a draft. Callers
  /// filter by `isDraft` for their own purposes (Explorar only wants
  /// published ones; Mis proyectos wants both, split into its two tabs).
  List<Project> getAll();

  /// Overwrites the stored project with the same id — called after every
  /// field change while the wizard is active.
  void updateDraft(Project project);

  /// Flips `isDraft` to `false` on the given project. This is the SAME
  /// object that was being edited — publishing never creates a second
  /// copy.
  void publish(String id);

  void submitRequest(ParticipationRequest request);

  List<ParticipationRequest> requestsFor(String projectId);
}
