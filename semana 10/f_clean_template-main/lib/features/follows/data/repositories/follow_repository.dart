import 'package:roble/roble.dart' show RobleApiNotFoundException;

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/follows/data/datasources/i_follow_data_source.dart';
import 'package:f_clean_template/features/follows/domain/follow_failure.dart';
import 'package:f_clean_template/features/follows/domain/models/project_follow.dart';
import 'package:f_clean_template/features/follows/domain/repositories/i_follow_repository.dart';

/// Seguir = insertar fila; dejar de seguir = borrarla.
class FollowRepository implements IFollowRepository {
  FollowRepository(this._source);

  final IFollowDataSource _source;

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, FollowFailure.new);

  Future<List<Map<String, dynamic>>> _rowsOf(String userId) async {
    final rows = await _guard(() => _source.readForUser(userId));
    return rows.where((r) => RobleRows.author(r, 'userId') == userId).toList();
  }

  @override
  Future<List<ProjectFollow>> followsOf(String userId) async =>
      (await _rowsOf(userId))
          .map(
            (r) => ProjectFollow(
              projectId: RobleRows.str(r['projectId']),
              userId: userId,
              createdAt: RobleRows.date(r['createdAt']),
            ),
          )
          .toList();

  @override
  Future<Set<String>> followedProjectIds(String userId) async =>
      (await _rowsOf(userId)).map((r) => RobleRows.str(r['projectId'])).toSet();

  @override
  Future<bool> isFollowing(String projectId, String userId) async =>
      (await followedProjectIds(userId)).contains(projectId);

  @override
  Future<bool> toggle(String projectId, String userId) async {
    final rows = (await _rowsOf(userId))
        .where((r) => RobleRows.str(r['projectId']) == projectId)
        .toList();
    if (rows.isNotEmpty) {
      for (final row in rows) {
        await _guard(() async {
          try {
            await _source.delete(RobleRows.str(row['_id']));
          } on RobleApiNotFoundException {
            return;
          }
        });
      }
      return false;
    }
    await _guard(
      () => _source.create({
        'projectId': projectId,
        'userId': userId,
        'createdAt': RobleRows.nowIso(),
      }),
    );
    return true;
  }
}
