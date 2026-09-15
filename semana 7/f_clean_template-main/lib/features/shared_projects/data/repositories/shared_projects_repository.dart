import '../../../home/domain/models/project.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import '../datasources/i_shared_projects_source.dart';

/// Adapter from the domain contract to the active shared-projects data
/// source. Pass-through, same shape as every other `...Repository` in
/// the app.
class SharedProjectsRepository implements ISharedProjectsRepository {
  SharedProjectsRepository(this.source);

  final ISharedProjectsSource source;

  @override
  Project startDraft() => source.startDraft();

  @override
  Project? getById(String id) => source.getById(id);

  @override
  List<Project> getAll() => source.getAll();

  @override
  void updateDraft(Project project) => source.updateDraft(project);

  @override
  void publish(String id) => source.publish(id);

  @override
  void submitRequest(ParticipationRequest request) =>
      source.submitRequest(request);

  @override
  List<ParticipationRequest> requestsFor(String projectId) =>
      source.requestsFor(projectId);
}
