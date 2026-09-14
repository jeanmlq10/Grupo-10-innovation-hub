import '../models/my_project.dart';

/// Operations the UI layer can perform over "Mis proyectos".
///
/// The controller only ever talks to this contract, never to a concrete
/// data source directly — same Clean Architecture rule as
/// `features/home/domain/repositories/i_project_repository.dart`.
abstract class IMyProjectsRepository {
  /// Returns every project owned by the current user — published ones
  /// and drafts together. The controller splits them by `isDraft` so a
  /// future paginated/remote source only needs to change here, not in
  /// the UI.
  Future<List<MyProject>> getMyProjects();
}
