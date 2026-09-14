import '../../domain/models/my_project.dart';

/// Data-source contract for "Mis proyectos". Shared by local and (future)
/// remote implementations — mirrors
/// `features/home/data/datasources/i_project_source.dart`.
abstract class IMyProjectsSource {
  Future<List<MyProject>> getMyProjects();
}
