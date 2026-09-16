import '../../../domain/models/my_project.dart';
import '../i_my_projects_source.dart';

/// Local implementation of [IMyProjectsSource].
///
/// This starts EMPTY on purpose — "Mis proyectos" and "Mis borradores"
/// must launch with zero example/dummy projects. The only entries that
/// ever appear are the ones the user actually creates through "Crear
/// proyecto" (merged in by `MyProjectsController` from
/// `ISharedProjectsRepository`).
class LocalMyProjectsSource implements IMyProjectsSource {
  final List<MyProject> _myProjects = [];

  @override
  Future<List<MyProject>> getMyProjects() async {
    // Small artificial delay so the loading state is visible, same spirit
    // as `LocalProjectSource.getProjects()` in the home feature.
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_myProjects);
  }
}
