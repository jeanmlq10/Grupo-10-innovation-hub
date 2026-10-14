import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/models/project_team_role.dart';

/// Proyectos (tabla `projects`).
abstract class IProjectRepository {
  Future<Project> create(Project project);

  Future<Project> save(Project project);

  Future<Project?> getById(
    String id, {
    String? viewerId,
    bool publicAccess = false,
  });

  Future<List<Project>> explorable({bool publicAccess = false});

  Future<List<Project>> ownedBy(String userId);

  Future<void> delete(String id);

  List<ProjectTeamRole> rolesOf(Project project);
}
