import '../../../home/domain/models/project.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/models/project_comment.dart';
import '../../domain/models/project_member.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/project_team_role.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import '../datasources/i_shared_projects_source.dart';

/// Implements the projects rules on top of [ISharedProjectsSource]
/// (Roble). Multi-step operations — accepting a request, syncing roles and
/// tasks — live here, the same place the rest of the app keeps its logic
/// (there is no use-case layer in this template).
class SharedProjectsRepository implements ISharedProjectsRepository {
  SharedProjectsRepository(this.source);

  final ISharedProjectsSource source;

  @override
  String? get currentUserId => source.currentUserId;

  String _requireUser() {
    final id = currentUserId;
    if (id == null || id.isEmpty) {
      throw StateError('Debes iniciar sesión para hacer esto.');
    }
    return id;
  }

  bool _canSee(Project project, String? me) =>
      project.isPublic || (me != null && project.createdBy == me);

  // ------------------------------------------------------------------
  // Projects
  // ------------------------------------------------------------------

  @override
  Future<Project> createProject(Project project) async {
    final me = _requireUser();
    return source.createProject(project.copyWith(createdBy: me));
  }

  @override
  Future<Project> saveProject(Project project) async {
    final me = _requireUser();
    if (project.createdBy != null && project.createdBy != me) {
      throw StateError('Solo el creador puede modificar este proyecto.');
    }
    return source.updateProject(project);
  }

  @override
  Future<Project?> getById(String id) async {
    if (id.isEmpty) return null;
    final project = await source.getProject(id);
    if (project == null || !_canSee(project, currentUserId)) return null;
    return project;
  }

  @override
  Future<List<Project>> getExplorable() async {
    final all = await source.getProjects();
    return all.where((project) => project.isPublic).toList();
  }

  @override
  Future<List<Project>> getMine() async {
    final me = currentUserId;
    if (me == null) return const [];
    final all = await source.getProjects();
    return all.where((project) => project.createdBy == me).toList();
  }

  // ------------------------------------------------------------------
  // Team roles (stored inside the project row)
  // ------------------------------------------------------------------

  List<ProjectTeamRole> _rolesOf(Project project) => [
    for (final entry in project.teamRoles.entries)
      if (entry.value > 0)
        ProjectTeamRole(
          // The role name is its identifier inside the project.
          id: entry.key,
          projectId: project.id,
          role: entry.key,
          numberNeeded: entry.value,
          numberAccepted: project.acceptedRoleCounts[entry.key] ?? 0,
          status: (project.acceptedRoleCounts[entry.key] ?? 0) >= entry.value
              ? 'closed'
              : 'open',
        ),
  ];

  @override
  Future<List<ProjectTeamRole>> rolesFor(String projectId) async {
    final project = await getById(projectId);
    return project == null ? const [] : _rolesOf(project);
  }

  // ------------------------------------------------------------------
  // Tasks
  // ------------------------------------------------------------------

  @override
  Future<List<ProjectTask>> tasksFor(String projectId) =>
      source.getTasks(projectId);

  @override
  Future<List<ProjectTask>> setTasks(
    String projectId,
    List<ProjectTask> tasks,
  ) async {
    final existing = await source.getTasks(projectId);
    final byId = {for (final task in existing) task.id: task};

    for (final task in tasks) {
      final title = task.title.trim();
      if (title.isEmpty) continue;
      final current = task.id.isEmpty ? null : byId.remove(task.id);
      if (current == null) {
        await source.createTask(
          task.copyWith(projectId: projectId, title: title, numberAccepted: 0),
        );
      } else if (current.title != title ||
          current.description != task.description ||
          current.numberNeeded != task.numberNeeded) {
        await source.updateTask(
          current.copyWith(
            title: title,
            description: task.description,
            numberNeeded: task.numberNeeded,
            status: current.numberAccepted >= task.numberNeeded
                ? 'closed'
                : 'open',
          ),
        );
      }
    }

    for (final leftover in byId.values) {
      if (leftover.numberAccepted == 0) {
        await source.deleteTask(leftover.id);
      } else {
        await source.updateTask(
          leftover.copyWith(
            numberNeeded: leftover.numberAccepted,
            status: 'closed',
          ),
        );
      }
    }
    return source.getTasks(projectId);
  }

  // ------------------------------------------------------------------
  // Follows
  // ------------------------------------------------------------------

  @override
  Future<bool> toggleFollow(String projectId) async {
    final me = _requireUser();
    final rowId = await source.followRowId(projectId, me);
    if (rowId != null) {
      await source.deleteFollow(rowId);
      return false;
    }
    await source.createFollow(projectId, me);
    return true;
  }

  @override
  Future<bool> isFollowing(String projectId) async {
    final me = currentUserId;
    if (me == null) return false;
    return (await source.followRowId(projectId, me)) != null;
  }

  @override
  Future<Set<String>> followedProjectIds() async {
    final me = currentUserId;
    if (me == null) return <String>{};
    return (await source.followedProjectIds(me)).toSet();
  }

  // ------------------------------------------------------------------
  // Requests
  // ------------------------------------------------------------------

  List<ParticipationRequest> _applyDecisions(
    List<ParticipationRequest> requests,
    List<RequestDecision> decisions,
  ) {
    // Latest valid decision per request wins.
    final latest = <String, RequestDecision>{};
    for (final decision in decisions) {
      final previous = latest[decision.requestId];
      if (previous == null ||
          (decision.decidedAt ?? DateTime(2000)).isAfter(
            previous.decidedAt ?? DateTime(2000),
          )) {
        latest[decision.requestId] = decision;
      }
    }
    return requests
        .map(
          (request) => latest.containsKey(request.id)
              ? request.copyWith(
                  status: latest[request.id]!.status,
                  updatedAt: latest[request.id]!.decidedAt,
                )
              : request,
        )
        .toList();
  }

  @override
  Future<void> submitRequest(ParticipationRequest request) async {
    final me = _requireUser();
    final project = await source.getProject(request.projectId);
    if (project == null || !project.isPublic) {
      throw StateError('Este proyecto no recibe solicitudes.');
    }
    if (project.createdBy == me) {
      throw StateError('No puedes postularte a tu propio proyecto.');
    }
    final created = await source.createRequest(
      ParticipationRequest(
        id: '',
        projectId: request.projectId,
        role: request.role,
        message: request.message,
        type: request.type,
        taskId: request.taskId,
        teamRoleId: request.teamRoleId,
        applicantName: request.applicantName,
        applicantUserId: me,
        applicantEmail: request.applicantEmail,
      ),
    );
    final owner = project.createdBy;
    if (owner != null && owner != me) {
      await _notifySafely(
        recipient: owner,
        type: AppNotificationType.newRequest,
        title: 'Nueva solicitud',
        message:
            '${request.applicantName} quiere unirse a tu proyecto '
            '${project.name.isEmpty ? "sin nombre" : project.name} '
            '(${request.role}).',
        projectId: project.id,
        requestId: created.id,
      );
    }
  }

  Future<List<ParticipationRequest>> _withStatus(
    List<ParticipationRequest> requests,
    String ownerId,
  ) async {
    final decisions = await source.getDecisions(
      requestIds: requests.map((request) => request.id).toSet(),
      validOwnerId: ownerId,
    );
    return _applyDecisions(requests, decisions);
  }

  @override
  Future<List<ParticipationRequest>> requestsFor(String projectId) async {
    final project = await source.getProject(projectId);
    if (project == null || project.createdBy == null) return const [];
    final requests = await source.getRequests(projectId: projectId);
    return _withStatus(requests, project.createdBy!);
  }

  @override
  Future<List<ParticipationRequest>> requestsForMyProjects() async {
    final me = currentUserId;
    if (me == null) return const [];
    final mine = await getMine();
    if (mine.isEmpty) return const [];
    final names = {for (final project in mine) project.id: project.name};
    final requests = (await source.getRequests())
        .where((request) => names.containsKey(request.projectId))
        .map(
          (request) => request.copyWith(projectName: names[request.projectId]),
        )
        .toList();
    return _withStatus(requests, me);
  }

  Future<Project> _ownedProject(String projectId) async {
    final me = _requireUser();
    final project = await source.getProject(projectId);
    if (project == null || project.createdBy != me) {
      throw StateError(
        'Solo el creador del proyecto puede gestionar solicitudes.',
      );
    }
    return project;
  }

  @override
  Future<void> acceptRequest(ParticipationRequest request) async {
    final me = _requireUser();
    var project = await _ownedProject(request.projectId);
    final current = (await requestsFor(project.id)).where(
      (r) => r.id == request.id,
    );
    if (current.isEmpty || current.first.status != RequestStatus.pending) {
      // Already decided: accepting again must not write anything.
      return;
    }
    // Already a member in that role (e.g. a previous attempt was cut off
    // halfway): don't register them twice.
    final members = await source.getMembers(
      project.id,
      projectOwnerId: me,
    );
    final alreadyMember = members.any(
      (member) =>
          member.userId == request.applicantUserId &&
          member.role == request.role,
    );

    await source.createDecision(
      requestId: request.id,
      status: RequestStatus.accepted,
    );
    if (alreadyMember) return;

    String? sourceId;
    if (request.type == RequestType.task && request.taskId != null) {
      final tasks = await source.getTasks(project.id);
      for (final task in tasks) {
        if (task.id != request.taskId) continue;
        await source.updateTask(
          task.copyWith(numberAccepted: task.numberAccepted + 1),
        );
        sourceId = task.id;
        break;
      }
    } else {
      final roleName = request.teamRoleId ?? request.role;
      final counts = Map<String, int>.from(project.acceptedRoleCounts);
      counts[roleName] = (counts[roleName] ?? 0) + 1;
      project = project.copyWith(acceptedRoleCounts: counts);
      sourceId = roleName;
    }

    await source.createMember(
      ProjectMember(
        id: '',
        projectId: project.id,
        userId: request.applicantUserId ?? '',
        name: request.applicantName,
        email: request.applicantEmail,
        role: request.role,
        sourceType: request.type == RequestType.task
            ? MemberSourceType.task
            : MemberSourceType.team,
        sourceId: sourceId,
        requestId: request.id,
      ),
    );

    await source.updateProject(
      project.copyWith(acceptedMembersCount: project.acceptedMembersCount + 1),
    );

    final applicant = request.applicantUserId;
    if (applicant != null && applicant != me) {
      await _notifySafely(
        recipient: applicant,
        type: AppNotificationType.requestAccepted,
        title: 'Solicitud aceptada',
        message:
            'Ya eres parte de '
            '${project.name.isEmpty ? "el proyecto" : project.name} '
            'como ${request.role}.',
        projectId: project.id,
        requestId: request.id,
      );
    }
  }

  @override
  Future<void> rejectRequest(ParticipationRequest request) async {
    final me = _requireUser();
    final project = await _ownedProject(request.projectId);
    final current = (await requestsFor(project.id)).where(
      (r) => r.id == request.id,
    );
    if (current.isEmpty || current.first.status != RequestStatus.pending) {
      return;
    }
    await source.createDecision(
      requestId: request.id,
      status: RequestStatus.rejected,
    );
    final applicant = request.applicantUserId;
    if (applicant != null && applicant != me) {
      await _notifySafely(
        recipient: applicant,
        type: AppNotificationType.requestRejected,
        title: 'Solicitud rechazada',
        message:
            'Tu solicitud para '
            '${project.name.isEmpty ? "el proyecto" : project.name} '
            'no fue aceptada esta vez.',
        projectId: project.id,
        requestId: request.id,
      );
    }
  }

  // ------------------------------------------------------------------
  // Members / comments
  // ------------------------------------------------------------------

  @override
  Future<List<ProjectMember>> membersFor(String projectId) async {
    final project = await source.getProject(projectId);
    if (project == null || project.createdBy == null) return const [];
    return source.getMembers(projectId, projectOwnerId: project.createdBy!);
  }

  @override
  Future<List<ProjectComment>> commentsFor(String projectId) =>
      source.getComments(projectId);

  @override
  Future<void> addComment(ProjectComment comment) async {
    final me = _requireUser();
    final project = await getById(comment.projectId);
    if (project == null) {
      throw StateError('No puedes comentar en este proyecto.');
    }
    await source.createComment(
      ProjectComment(
        id: '',
        projectId: comment.projectId,
        authorName: comment.authorName,
        authorUserId: me,
        text: comment.text,
        createdAt: DateTime.now(),
      ),
    );
    final owner = project.createdBy;
    if (owner != null && owner != me) {
      await _notifySafely(
        recipient: owner,
        type: AppNotificationType.newComment,
        title: 'Nuevo comentario',
        message:
            '${comment.authorName} comentó en '
            '${project.name.isEmpty ? "tu proyecto" : project.name}.',
        projectId: project.id,
      );
    }
  }

  // ------------------------------------------------------------------
  // Notifications
  // ------------------------------------------------------------------

  @override
  Future<List<AppNotification>> getNotifications() =>
      source.getNotifications();

  @override
  Future<void> markNotificationRead(String id) =>
      source.markNotificationRead(id);

  /// A failed notification must not undo the action that triggered it
  /// (the request/decision/comment is already stored in Roble).
  Future<void> _notifySafely({
    required String recipient,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
  }) async {
    try {
      await source.sendNotification(
        recipientUserId: recipient,
        type: type,
        title: title,
        message: message,
        projectId: projectId,
        requestId: requestId,
      );
    } catch (_) {
      // Intentionally ignored: see doc comment.
    }
  }
}
