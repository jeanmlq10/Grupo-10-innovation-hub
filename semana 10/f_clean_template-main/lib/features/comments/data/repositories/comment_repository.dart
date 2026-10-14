import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/comments/data/datasources/i_comment_data_source.dart';
import 'package:f_clean_template/features/comments/domain/comment_failure.dart';
import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';
import 'package:f_clean_template/features/comments/domain/repositories/i_comment_repository.dart';

/// Comentarios: convierte filas y traduce errores.
class CommentRepository implements ICommentRepository {
  CommentRepository(this._source);

  final ICommentDataSource _source;

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, CommentFailure.new);

  @override
  Future<List<ProjectComment>> forProject(String projectId) async {
    final rows = await _guard(() => _source.readForProject(projectId));
    return rows.map(_toComment).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<ProjectComment>> byAuthor(String userId) async {
    final rows = await _guard(() => _source.readByAuthor(userId));
    return rows
        .map(_toComment)
        .where((comment) => comment.authorUserId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<ProjectComment> add(ProjectComment comment) async {
    final row = await _guard(
      () => _source.create({
        'projectId': comment.projectId,
        'authorUserId': comment.authorUserId,
        'authorName': comment.authorName,
        'text': comment.text,
        'createdAt': RobleRows.nowIso(),
      }),
    );
    return _toComment(row);
  }

  ProjectComment _toComment(Map<String, dynamic> row) => ProjectComment(
    id: RobleRows.str(row['_id']),
    projectId: RobleRows.str(row['projectId']),
    authorName: RobleRows.str(row['authorName'], 'Usuario'),
    authorUserId: RobleRows.author(row, 'authorUserId'),
    text: RobleRows.str(row['text']),
    createdAt: RobleRows.date(row['createdAt']) ?? DateTime.now(),
  );
}
