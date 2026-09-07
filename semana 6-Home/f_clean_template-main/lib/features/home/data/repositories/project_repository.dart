import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/i_project_source.dart';

/// Adapter from the domain repository contract to the active project
/// data source. Pass-through, same shape as `ProductRepository`.
class ProjectRepository implements IProjectRepository {
  ProjectRepository(this.source);

  final IProjectSource source;

  @override
  Future<List<Project>> getProjects() => source.getProjects();
}
