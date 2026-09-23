import 'dart:convert';

import 'package:roble/roble.dart';

import '../../../../home/domain/models/project.dart';
import '../../../domain/models/app_notification.dart';
import '../../../domain/models/participation_request.dart';
import '../../../domain/models/project_comment.dart';
import '../../../domain/models/project_member.dart';
import '../../../domain/models/project_task.dart';
import '../i_shared_projects_source.dart';

/// Names of the Roble tables used by the projects module (already created
/// in the Roble project `movil_flutter_dcaabc5f4e`; see
/// `ROBLE_PROJECTS_SETUP.md` for their exact columns).
abstract final class RobleProjectTables {
  static const String projects = 'projects';
  static const String tasks = 'project_tasks';
  static const String requests = 'project_requests';
  static const String decisions = 'request_decisions';
  static const String members = 'project_members';
  static const String comments = 'project_comments';
  static const String follows = 'project_follows';
  static const String notifications = 'app_notifications';
}

/// [ISharedProjectsSource] backed by Roble, through the official `roble`
/// SDK and the SAME [RobleApiDataBase] instance used for login (so every
/// request carries the logged-in user's session and `_owner` is set by the
/// server from that token).
///
/// Only SDK calls are used: `create`, `read` (equality filters), `getById`,
/// `update`, `delete` and `currentUserId`. Column names match the tables
/// exactly as they exist in Roble (camelCase); no other column is written.
class RobleSharedProjectsSource implements ISharedProjectsSource {
  RobleSharedProjectsSource(this._clientProvider);

  /// Returns the app's single Roble client. A provider (not the client
  /// itself) because the client is created lazily by the auth layer.
  final RobleApiDataBase Function() _clientProvider;

  RobleApiDataBase get _db => _clientProvider();

  @override
  String? get currentUserId => _db.currentUserId;

  // ------------------------------------------------------------------
  // Parsing helpers
  // ------------------------------------------------------------------

  static String _str(Object? value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  static String? _strOrNull(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static bool _bool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value == null) return fallback;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == 't' || text == '1') return true;
    if (text == 'false' || text == 'f' || text == '0') return false;
    return fallback;
  }

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  /// jsonb may arrive already decoded or as a JSON string.
  static Object? _json(Object? value) {
    if (value is String && value.isNotEmpty) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return null;
      }
    }
    return value;
  }

  static List<String> _stringList(Object? value) {
    final decoded = _json(value);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
    return const [];
  }

  static Map<String, int> _intMap(Object? value) {
    final decoded = _json(value);
    if (decoded is Map) {
      return decoded.map((key, val) => MapEntry(key.toString(), _int(val)));
    }
    return const {};
  }

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();

  /// Author of a row: `_owner` (set by Roble from the token, trustworthy)
  /// or, if the table does not expose it, the explicit [fallbackColumn].
  static String? _author(Map<String, dynamic> row, String fallbackColumn) =>
      robleOwnerOf(row) ?? _strOrNull(row[fallbackColumn]);

  // ------------------------------------------------------------------
  // Projects
  // ------------------------------------------------------------------

  Project _projectFromRow(Map<String, dynamic> row) => Project(
    id: _str(row['_id']),
    name: _str(row['name']),
    description: _str(row['description']),
    categories: _stringList(row['categories']),
    canApply: _bool(row['canApply'], fallback: true),
    teamRoles: _intMap(row['teamRoles']),
    acceptedRoleCounts: _intMap(row['acceptedRoleCounts']),
    duration: _strOrNull(row['duration']),
    audience: _strOrNull(row['audience']),
    isDraft: _bool(row['isDraft'], fallback: true),
    acceptedMembersCount: _int(row['acceptedMembersCount']),
    createdBy: _author(row, 'createdBy'),
    createdByName: _strOrNull(row['createdByName']),
  );

  Map<String, dynamic> _projectFields(Project project) => {
    'name': project.name,
    'description': project.description,
    'categories': project.categories,
    'canApply': project.canApply,
    'teamRoles': project.teamRoles,
    'acceptedRoleCounts': project.acceptedRoleCounts,
    'duration': project.duration,
    'audience': project.audience,
    'isDraft': project.isDraft,
    'acceptedMembersCount': project.acceptedMembersCount,
    'createdByName': project.createdByName,
  };

  @override
  Future<Project> createProject(Project project) async {
    final row = await _db.create(RobleProjectTables.projects, {
      ..._projectFields(project),
      'createdBy': project.createdBy ?? currentUserId,
    });
    return _projectFromRow(row);
  }

  @override
  Future<Project> updateProject(Project project) async {
    final row = await _db.update(
      RobleProjectTables.projects,
      project.id,
      _projectFields(project),
    );
    if (row.isEmpty) return project;
    return _projectFromRow(row);
  }

  @override
  Future<Project?> getProject(String id) async {
    final row = await _db.getById(RobleProjectTables.projects, id);
    return row == null ? null : _projectFromRow(row);
  }

  @override
  Future<List<Project>> getProjects() async {
    final rows = await _db.read(RobleProjectTables.projects);
    return rows.map(_projectFromRow).toList();
  }

  // ------------------------------------------------------------------
  // Tasks
  // ------------------------------------------------------------------

  ProjectTask _taskFromRow(Map<String, dynamic> row) {
    final needed = _int(row['requiredCount']);
    final accepted = _int(row['acceptedCount']);
    return ProjectTask(
      id: _str(row['_id']),
      projectId: _str(row['projectId']),
      title: _str(row['title']),
      description: _str(row['description']),
      numberNeeded: needed,
      numberAccepted: accepted,
      status: accepted >= needed ? 'closed' : 'open',
    );
  }

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async {
    final rows = await _db.read(
      RobleProjectTables.tasks,
      filters: {'projectId': projectId},
    );
    return rows.map(_taskFromRow).toList();
  }

  @override
  Future<ProjectTask> createTask(ProjectTask task) async {
    final row = await _db.create(RobleProjectTables.tasks, {
      'projectId': task.projectId,
      'title': task.title,
      'description': task.description,
      'requiredCount': task.numberNeeded,
      'acceptedCount': task.numberAccepted,
    });
    return _taskFromRow(row);
  }

  @override
  Future<void> updateTask(ProjectTask task) async {
    await _db.update(RobleProjectTables.tasks, task.id, {
      'title': task.title,
      'description': task.description,
      'requiredCount': task.numberNeeded,
      'acceptedCount': task.numberAccepted,
    });
  }

  @override
  Future<void> deleteTask(String id) =>
      _deleteIgnoringMissing(RobleProjectTables.tasks, id);

  // ------------------------------------------------------------------
  // Follows
  // ------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _followRows(String userId) async {
    final rows = await _db.read(
      RobleProjectTables.follows,
      filters: {'userId': userId},
    );
    // Only follows written by that same user count.
    return rows.where((row) => _author(row, 'userId') == userId).toList();
  }

  @override
  Future<List<String>> followedProjectIds(String userId) async {
    final rows = await _followRows(userId);
    return rows.map((row) => _str(row['projectId'])).toSet().toList();
  }

  @override
  Future<String?> followRowId(String projectId, String userId) async {
    final rows = await _followRows(userId);
    for (final row in rows) {
      if (_str(row['projectId']) == projectId) return _str(row['_id']);
    }
    return null;
  }

  @override
  Future<void> createFollow(String projectId, String userId) async {
    await _db.create(RobleProjectTables.follows, {
      'projectId': projectId,
      'userId': userId,
      'createdAt': _nowIso(),
    });
  }

  @override
  Future<void> deleteFollow(String followId) =>
      _deleteIgnoringMissing(RobleProjectTables.follows, followId);

  // ------------------------------------------------------------------
  // Requests + decisions
  // ------------------------------------------------------------------

  ParticipationRequest _requestFromRow(Map<String, dynamic> row) =>
      ParticipationRequest(
        id: _str(row['_id']),
        projectId: _str(row['projectId']),
        role: _str(row['role']),
        message: _str(row['message']),
        type: _str(row['type']) == 'task' ? RequestType.task : RequestType.team,
        taskId: _strOrNull(row['taskId']),
        teamRoleId: _strOrNull(row['teamRoleId']),
        applicantName: _str(row['applicantName'], 'Usuario interesado'),
        applicantUserId: _author(row, 'applicantUserId'),
        applicantEmail: _strOrNull(row['applicantEmail']),
        createdAt: _date(row['createdAt']),
        updatedAt: _date(row['updatedAt']),
      );

  @override
  Future<ParticipationRequest> createRequest(
    ParticipationRequest request,
  ) async {
    final now = _nowIso();
    final row = await _db.create(RobleProjectTables.requests, {
      'projectId': request.projectId,
      'type': request.type == RequestType.task ? 'task' : 'team',
      'taskId': request.taskId,
      'teamRoleId': request.teamRoleId,
      'role': request.role,
      'message': request.message,
      'applicantUserId': request.applicantUserId ?? currentUserId,
      'applicantName': request.applicantName,
      'applicantEmail': request.applicantEmail,
      // The row belongs to the applicant, so its status column stays
      // "pending"; the owner's decision lives in `request_decisions`.
      'status': 'pending',
      'createdAt': now,
      'updatedAt': now,
    });
    return _requestFromRow(row);
  }

  @override
  Future<List<ParticipationRequest>> getRequests({
    String? projectId,
    String? projectOwnerId,
  }) async {
    final rows = await _db.read(
      RobleProjectTables.requests,
      filters: projectId == null ? null : {'projectId': projectId},
    );
    final requests = rows.map(_requestFromRow).toList();
    requests.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return requests;
  }

  @override
  Future<List<RequestDecision>> getDecisions({
    required Set<String> requestIds,
    required String validOwnerId,
  }) async {
    if (requestIds.isEmpty) return const [];
    final rows = await _db.read(RobleProjectTables.decisions);
    return rows
        .map(
          (row) => RequestDecision(
            id: _str(row['_id']),
            requestId: _str(row['requestId']),
            status: _str(row['status']) == 'accepted'
                ? RequestStatus.accepted
                : RequestStatus.rejected,
            decidedBy: robleOwnerOf(row),
            decidedAt: _date(row['decidedAt']),
          ),
        )
        .where(
          (decision) =>
              requestIds.contains(decision.requestId) &&
              // `_owner` hidden/absent on the table → cannot verify the
              // author; accept it (enable ownership on request_decisions so
              // this is always verified).
              (decision.decidedBy == null ||
                  decision.decidedBy == validOwnerId),
        )
        .toList();
  }

  @override
  Future<void> createDecision({
    required String requestId,
    required RequestStatus status,
  }) async {
    await _db.create(RobleProjectTables.decisions, {
      'requestId': requestId,
      'status': status == RequestStatus.accepted ? 'accepted' : 'rejected',
      'decidedAt': _nowIso(),
    });
  }

  // ------------------------------------------------------------------
  // Members
  // ------------------------------------------------------------------

  ProjectMember _memberFromRow(Map<String, dynamic> row) => ProjectMember(
    id: _str(row['_id']),
    projectId: _str(row['projectId']),
    userId: _str(row['userId']),
    name: _str(row['name'], 'Miembro'),
    email: _strOrNull(row['email']),
    role: _str(row['role']),
    sourceType: _str(row['sourceType']) == 'task'
        ? MemberSourceType.task
        : MemberSourceType.team,
    sourceId: _strOrNull(row['sourceId']),
    joinedAt: _date(row['joinedAt']),
  );

  @override
  Future<List<ProjectMember>> getMembers(
    String projectId, {
    required String projectOwnerId,
  }) async {
    final rows = await _db.read(
      RobleProjectTables.members,
      filters: {'projectId': projectId},
    );
    // Only members registered by the project creator are real members.
    final members = rows
        .where((row) {
          final owner = robleOwnerOf(row);
          return owner == null || owner == projectOwnerId;
        })
        .map(_memberFromRow)
        .toList();
    members.sort(
      (a, b) => (a.joinedAt ?? DateTime(2000)).compareTo(
        b.joinedAt ?? DateTime(2000),
      ),
    );
    // The same person in the same role counts once, even if a double tap
    // (before this fix) stored the row twice.
    final seen = <String>{};
    return members
        .where((member) => seen.add('${member.userId}|${member.role}'))
        .toList();
  }

  @override
  Future<ProjectMember> createMember(ProjectMember member) async {
    final row = await _db.create(RobleProjectTables.members, {
      'projectId': member.projectId,
      'userId': member.userId,
      'name': member.name,
      'email': member.email,
      'role': member.role,
      'joinedAt': _nowIso(),
      'sourceType': member.sourceType == MemberSourceType.task
          ? 'task'
          : 'team',
      'sourceId': member.sourceId,
    });
    return _memberFromRow(row);
  }

  // ------------------------------------------------------------------
  // Comments
  // ------------------------------------------------------------------

  ProjectComment _commentFromRow(Map<String, dynamic> row) => ProjectComment(
    id: _str(row['_id']),
    projectId: _str(row['projectId']),
    authorName: _str(row['authorName'], 'Usuario'),
    authorUserId: _author(row, 'authorUserId'),
    text: _str(row['text']),
    createdAt: _date(row['createdAt']) ?? DateTime.now(),
  );

  @override
  Future<List<ProjectComment>> getComments(String projectId) async {
    final rows = await _db.read(
      RobleProjectTables.comments,
      filters: {'projectId': projectId},
    );
    final comments = rows.map(_commentFromRow).toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  @override
  Future<ProjectComment> createComment(ProjectComment comment) async {
    final row = await _db.create(RobleProjectTables.comments, {
      'projectId': comment.projectId,
      'authorUserId': comment.authorUserId ?? currentUserId,
      'authorName': comment.authorName,
      'text': comment.text,
      'createdAt': _nowIso(),
    });
    return _commentFromRow(row);
  }

  // ------------------------------------------------------------------
  // Notifications (table app_notifications)
  // ------------------------------------------------------------------

  @override
  Future<List<AppNotification>> getNotifications() async {
    final me = currentUserId;
    if (me == null) return const [];
    final rows = await _db.read(
      RobleProjectTables.notifications,
      filters: {'recipientUserId': me},
    );
    final list = rows
        .map(
          (row) => AppNotification(
            id: _str(row['_id']),
            recipientUserId: _strOrNull(row['recipientUserId']),
            projectId: _str(row['projectId']),
            requestId: _strOrNull(row['requestId']),
            type: _str(row['type'], AppNotificationType.newRequest),
            title: _str(row['title']),
            message: _str(row['message']),
            read: _bool(row['read']),
            createdAt: _date(row['createdAt']) ?? DateTime.now(),
          ),
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> sendNotification({
    required String recipientUserId,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
  }) async {
    await _db.create(RobleProjectTables.notifications, {
      'recipientUserId': recipientUserId,
      'projectId': projectId,
      'requestId': requestId,
      'type': type,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': _nowIso(),
    });
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _db.update(RobleProjectTables.notifications, id, {'read': true});
  }

  // ------------------------------------------------------------------

  /// Roble answers `404` when deleting a row that is already gone (or not
  /// ours); for a delete that means the goal is reached.
  Future<void> _deleteIgnoringMissing(String table, String id) async {
    try {
      await _db.delete(table, id);
    } on RobleApiNotFoundException {
      return;
    }
  }
}
