import '../models/my_project.dart';

/// Operations the UI layer can perform over "Mis proyectos".
///
/// The controller only ever talks to this contract, never to a concrete
/// data source directly — same Clean Architecture rule as
/// `features/home/domain/repositories/i_project_repository.dart`.
///
/// This only covers the example entries (EcoCampus, Huerta comunitaria,
/// the placeholders) — projects created through "Crear proyecto" now
/// live in `ISharedProjectsRepository` and are merged in by
/// `MyProjectsController`, never stored here.
abstract class IMyProjectsRepository {
  Future<List<MyProject>> getMyProjects();
}
