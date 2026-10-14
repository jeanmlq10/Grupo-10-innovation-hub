import 'package:f_clean_template/features/follows/domain/models/project_follow.dart';

/// Seguimientos de proyectos (tabla `project_follows`).
abstract class IFollowRepository {
  /// Seguimientos de [userId] con su fecha (historial del perfil).
  Future<List<ProjectFollow>> followsOf(String userId);

  Future<Set<String>> followedProjectIds(String userId);

  Future<bool> isFollowing(String projectId, String userId);

  /// Sigue (inserta) o deja de seguir (borra). Devuelve si queda siguiendo.
  Future<bool> toggle(String projectId, String userId);
}
