import '../models/new_project_draft.dart';

/// Operations the UI layer can perform over the "Crear proyecto" draft.
///
/// The controller only ever talks to this contract, never to a concrete
/// data source directly — same Clean Architecture rule as the other
/// features (`IProjectRepository`, `IMyProjectsRepository`).
abstract class ICreateProjectRepository {
  /// The draft as it stands right now (empty fields if nothing was
  /// entered yet, or after [resetDraft]).
  NewProjectDraft getDraft();

  /// Persists the latest values typed in "Nueva idea" / "Información
  /// básica" so a later step (or a future "Revisar y publicar" screen)
  /// can read them back.
  void saveDraft(NewProjectDraft draft);

  /// Clears the draft. Called every time a fresh "Crear proyecto" flow
  /// starts, so an abandoned attempt never leaks into the next one.
  void resetDraft();
}
