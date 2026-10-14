import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';

/// Comentarios de un proyecto (tabla `project_comments`).
abstract class ICommentRepository {
  Future<List<ProjectComment>> forProject(String projectId);

  Future<ProjectComment> add(ProjectComment comment);

  Future<List<ProjectComment>> byAuthor(String userId);
}
