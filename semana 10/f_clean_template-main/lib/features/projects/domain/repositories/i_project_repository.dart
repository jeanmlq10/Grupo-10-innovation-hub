import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/models/project_team_role.dart';

/// Proyectos (tabla `projects`).
abstract class IProjectRepository {
  /// Crea la fila y devuelve el proyecto con su `_id` de Roble.
  Future<Project> create(Project project);

  /// Sobrescribe la MISMA fila (nunca crea una copia).
  Future<Project> save(Project project);

  /// El proyecto si [viewerId] puede verlo (publico o suyo); si no, null.
  /// [publicAccess] = true para el visitante (sin sesion): solo publicos.
  Future<Project?> getById(
    String id, {
    String? viewerId,
    bool publicAccess = false,
  });

  /// "Explorar": publicados (isDraft false) y audiencia "Toda la comunidad".
  /// [publicAccess] = true para el visitante: se lee sin sesion.
  Future<List<Project>> explorable({bool publicAccess = false});

  /// "Mis proyectos": los creados por [userId] (borradores y publicados).
  Future<List<Project>> ownedBy(String userId);

  /// Borra la fila del proyecto (solo el dueño puede: Roble responde 404
  /// si no es suyo).
  Future<void> delete(String id);

  /// Roles del equipo, armados con `teamRoles` y `acceptedRoleCounts`.
  List<ProjectTeamRole> rolesOf(Project project);
}
