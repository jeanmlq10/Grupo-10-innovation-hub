import '../../domain/models/my_project.dart';
import '../../domain/repositories/i_my_projects_repository.dart';
import '../datasources/i_my_projects_source.dart';

/// Adapter from the domain repository contract to the active
/// "Mis proyectos" data source. Pass-through, same shape as
/// `features/home/data/repositories/project_repository.dart`.
class MyProjectsRepository implements IMyProjectsRepository {
  MyProjectsRepository(this.source);

  final IMyProjectsSource source;

  @override
  Future<List<MyProject>> getMyProjects() => source.getMyProjects();

  @override
  void addPublishedProject({
    required String name,
    required String description,
    required int membersCount,
  }) => source.addProject(
    name: name,
    description: description,
    membersCount: membersCount,
  );
}
