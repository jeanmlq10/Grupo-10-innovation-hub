import 'package:roble/roble.dart' show robleOwnerOf;

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/requests/data/datasources/i_request_data_source.dart';
import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';
import 'package:f_clean_template/features/requests/domain/repositories/i_request_repository.dart';
import 'package:f_clean_template/features/requests/domain/request_failure.dart';

/// Solicitudes: convierte filas, calcula el estado a partir de las
/// decisiones del dueno y traduce errores.
class RequestRepository implements IRequestRepository {
  RequestRepository(this._source);

  final IRequestDataSource _source;

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, RequestFailure.new);

  @override
  Future<ParticipationRequest> submit(ParticipationRequest r) async {
    final now = RobleRows.nowIso();
    final row = await _guard(
      () => _source.createRequest({
        'projectId': r.projectId,
        'type': r.type == RequestType.task ? 'task' : 'team',
        'taskId': r.taskId,
        'teamRoleId': r.teamRoleId,
        'role': r.role,
        'message': r.message,
        'applicantUserId': r.applicantUserId,
        'applicantName': r.applicantName,
        'applicantEmail': r.applicantEmail,
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
      }),
    );
    return _toRequest(row);
  }

  @override
  Future<List<ParticipationRequest>> forProject(
    String projectId, {
    required String ownerId,
  }) async {
    final rows = await _guard(() => _source.readRequests(projectId: projectId));
    return _withStatus(rows.map(_toRequest).toList(), ownerId);
  }

  @override
  Future<List<ParticipationRequest>> forProjects(
    Map<String, String> projectNames, {
    required String ownerId,
  }) async {
    if (projectNames.isEmpty) return const [];
    final rows = await _guard(() => _source.readRequests());
    final requests = rows
        .map(_toRequest)
        .where((r) => projectNames.containsKey(r.projectId))
        .map((r) => r.copyWith(projectName: projectNames[r.projectId]))
        .toList();
    return _withStatus(requests, ownerId);
  }

  @override
  Future<List<ParticipationRequest>> sentBy(String userId) async {
    final rows = await _guard(() => _source.readByApplicant(userId));
    return rows
        .map(_toRequest)
        .where((r) => r.applicantUserId == userId)
        .toList();
  }

  @override
  Future<void> decide(String requestId, RequestStatus status) async {
    await _guard(
      () => _source.createDecision({
        'requestId': requestId,
        'status': status == RequestStatus.accepted ? 'accepted' : 'rejected',
        'decidedAt': RobleRows.nowIso(),
      }),
    );
  }

  Future<List<ParticipationRequest>> _withStatus(
    List<ParticipationRequest> requests,
    String ownerId,
  ) async {
    if (requests.isEmpty) return requests;
    final ids = requests.map((r) => r.id).toSet();
    final rows = await _guard(_source.readDecisions);
    final latest = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final requestId = RobleRows.str(row['requestId']);
      final author = robleOwnerOf(row);
      if (!ids.contains(requestId)) continue;
      if (author != null && author != ownerId) continue;
      final previous = latest[requestId];
      final when = RobleRows.date(row['decidedAt']) ?? DateTime(2000);
      final previousWhen =
          RobleRows.date(previous?['decidedAt']) ?? DateTime(2000);
      if (previous == null || when.isAfter(previousWhen)) {
        latest[requestId] = row;
      }
    }
    final result = requests.map((r) {
      final decision = latest[r.id];
      if (decision == null) return r;
      return r.copyWith(
        status: RobleRows.str(decision['status']) == 'accepted'
            ? RequestStatus.accepted
            : RequestStatus.rejected,
        updatedAt: RobleRows.date(decision['decidedAt']),
      );
    }).toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
    return result;
  }

  ParticipationRequest _toRequest(Map<String, dynamic> row) =>
      ParticipationRequest(
        id: RobleRows.str(row['_id']),
        projectId: RobleRows.str(row['projectId']),
        role: RobleRows.str(row['role']),
        message: RobleRows.str(row['message']),
        type: RobleRows.str(row['type']) == 'task'
            ? RequestType.task
            : RequestType.team,
        taskId: RobleRows.strOrNull(row['taskId']),
        teamRoleId: RobleRows.strOrNull(row['teamRoleId']),
        applicantName: RobleRows.str(row['applicantName'], 'Usuario interesado'),
        applicantUserId: RobleRows.author(row, 'applicantUserId'),
        applicantEmail: RobleRows.strOrNull(row['applicantEmail']),
        createdAt: RobleRows.date(row['createdAt']),
        updatedAt: RobleRows.date(row['updatedAt']),
      );
}
