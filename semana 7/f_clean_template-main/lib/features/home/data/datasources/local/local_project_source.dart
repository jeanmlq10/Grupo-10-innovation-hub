import '../../../domain/models/project.dart';
import '../i_project_source.dart';

/// Local implementation of [IProjectSource].
///
/// No backend, no Firebase/Supabase, no HTTP. This starts EMPTY on
/// purpose — the app must launch with zero example/dummy projects.
/// "Explorar proyectos" only ever shows what a user actually publishes
/// through "Crear proyecto" (merged in by `HomeController` from
/// `ISharedProjectsRepository`). When a real API is connected later, a
/// `RemoteProjectSource implements IProjectSource` can replace this in
/// `home_dependencies.dart` without touching the controller, the
/// repository contract, or any widget.
class LocalProjectSource implements IProjectSource {
  final List<Project> _projects = [];

  @override
  Future<List<Project>> getProjects() async {
    // Small artificial delay so the loading state is visible, same spirit
    // as a real network/local-storage read.
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_projects);
  }
}
