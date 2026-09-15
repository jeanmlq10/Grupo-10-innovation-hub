import '../../domain/models/new_project_draft.dart';
import '../../domain/repositories/i_create_project_repository.dart';
import '../datasources/i_create_project_source.dart';

/// Adapter from the domain repository contract to the active
/// "Crear proyecto" data source. Pass-through, same shape as
/// `MyProjectsRepository` / `ProjectRepository`.
class CreateProjectRepository implements ICreateProjectRepository {
  CreateProjectRepository(this.source);

  final ICreateProjectSource source;

  @override
  NewProjectDraft getDraft() => source.getDraft();

  @override
  void saveDraft(NewProjectDraft draft) => source.saveDraft(draft);

  @override
  void resetDraft() => source.resetDraft();
}
