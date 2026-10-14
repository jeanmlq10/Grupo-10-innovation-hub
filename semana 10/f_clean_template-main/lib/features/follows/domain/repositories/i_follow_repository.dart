import 'package:f_clean_template/features/follows/domain/models/project_follow.dart';

/// Seguimientos de proyectos (tabla `project_follows`).
abstract class IFollowRepository {
  Future<List<ProjectFollow>> followsOf(String userId);

  Future<Set<String>> followedProjectIds(String userId);

  Future<bool> isFollowing(String projectId, String userId);

  Future<bool> toggle(String projectId, String userId);
}
