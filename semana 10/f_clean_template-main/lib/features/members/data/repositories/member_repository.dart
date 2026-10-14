import 'package:roble/roble.dart' show robleOwnerOf;

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/members/data/datasources/i_member_data_source.dart';
import 'package:f_clean_template/features/members/domain/member_failure.dart';
import 'package:f_clean_template/features/members/domain/models/project_member.dart';
import 'package:f_clean_template/features/members/domain/repositories/i_member_repository.dart';

/// Miembros: solo cuentan los que registro el creador del proyecto, y la
/// misma persona en el mismo rol cuenta una vez.
class MemberRepository implements IMemberRepository {
  MemberRepository(this._source);

  final IMemberDataSource _source;

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, MemberFailure.new);

  @override
  Future<List<ProjectMember>> forProject(
    String projectId, {
    required String ownerId,
  }) async {
    final rows = await _guard(() => _source.readForProject(projectId));
    final members = rows
        .where((row) {
          final owner = robleOwnerOf(row);
          return owner == null || owner == ownerId;
        })
        .map(_toMember)
        .toList()
      ..sort(
        (a, b) => (a.joinedAt ?? DateTime(2000)).compareTo(
          b.joinedAt ?? DateTime(2000),
        ),
      );
    final seen = <String>{};
    return members.where((m) => seen.add('${m.userId}|${m.role}')).toList();
  }

  @override
  Future<List<ProjectMember>> forUser(String userId) async {
    final rows = await _guard(() => _source.readForUser(userId));
    return rows.map(_toMember).where((m) => m.userId == userId).toList();
  }

  @override
  Future<ProjectMember> add(ProjectMember member) async {
    final row = await _guard(
      () => _source.create({
        'projectId': member.projectId,
        'userId': member.userId,
        'name': member.name,
        'email': member.email,
        'role': member.role,
        'joinedAt': RobleRows.nowIso(),
        'sourceType': member.sourceType == MemberSourceType.task ? 'task' : 'team',
        'sourceId': member.sourceId,
      }),
    );
    return _toMember(row);
  }

  ProjectMember _toMember(Map<String, dynamic> row) => ProjectMember(
    id: RobleRows.str(row['_id']),
    projectId: RobleRows.str(row['projectId']),
    userId: RobleRows.str(row['userId']),
    name: RobleRows.str(row['name'], 'Miembro'),
    email: RobleRows.strOrNull(row['email']),
    role: RobleRows.str(row['role']),
    sourceType: RobleRows.str(row['sourceType']) == 'task'
        ? MemberSourceType.task
        : MemberSourceType.team,
    sourceId: RobleRows.strOrNull(row['sourceId']),
    joinedAt: RobleRows.date(row['joinedAt']),
    recordedBy: robleOwnerOf(row),
  );
}
