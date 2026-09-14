import '../models/project.dart';

/// Operations the UI layer can perform over projects.
///
/// The controller only ever talks to this contract, never to a concrete
/// data source directly (Clean Architecture dependency rule).
abstract class IProjectRepository {
  Future<List<Project>> getProjects();
}
