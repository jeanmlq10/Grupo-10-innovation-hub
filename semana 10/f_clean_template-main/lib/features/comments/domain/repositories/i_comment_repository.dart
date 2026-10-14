import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';

/// Comentarios de un proyecto (tabla `project_comments`).
abstract class ICommentRepository {
  /// Del mas antiguo al mas nuevo.
  Future<List<ProjectComment>> forProject(String projectId);

  Future<ProjectComment> add(ProjectComment comment);

  /// Comentarios que escribió [userId] (solo los que de verdad son suyos).
  Future<List<ProjectComment>> byAuthor(String userId);
}
