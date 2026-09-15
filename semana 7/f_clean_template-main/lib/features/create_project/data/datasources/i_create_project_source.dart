import '../../domain/models/new_project_draft.dart';

/// Data-source contract for the "Crear proyecto" draft. Shared by local
/// and (future) remote/persisted implementations — mirrors
/// `features/my_projects/data/datasources/i_my_projects_source.dart`.
abstract class ICreateProjectSource {
  NewProjectDraft getDraft();
  void saveDraft(NewProjectDraft draft);
  void resetDraft();
}
