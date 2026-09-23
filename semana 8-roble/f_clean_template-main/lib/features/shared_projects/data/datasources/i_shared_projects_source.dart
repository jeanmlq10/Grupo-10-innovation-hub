import '../../../home/domain/models/project.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/models/project_comment.dart';
import '../../domain/models/project_member.dart';
import '../../domain/models/project_task.dart';

/// An owner's decision on a participation request (table
/// `request_decisions`). Internal to the data layer: the domain only sees
/// the resulting [RequestStatus] on each [ParticipationRequest].
class RequestDecision {
  const RequestDecision({
    required this.id,
    required this.requestId,
    required this.status,
    required this.decidedBy,
    this.decidedAt,
  });

  final String id;
  final String requestId;
  final RequestStatus status;

  /// Who wrote the decision: the row `_owner`, set by Roble from the token.
  final String? decidedBy;
  final DateTime? decidedAt;
}

/// Data-source contract for the projects module. The production
/// implementation is `RobleSharedProjectsSource` (Roble is the source of
/// truth); every method is asynchronous because every call goes to Roble.
abstract class ISharedProjectsSource {
  /// Roble userId of the current session, `null` if nobody is logged in.
  String? get currentUserId;

  // --- Projects ---
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);

  /// The project row (team roles live in its `teamRoles` /
  /// `acceptedRoleCounts` columns).
  Future<Project?> getProject(String id);

  /// Every project row readable by the session.
  Future<List<Project>> getProjects();

  // --- Tasks ---
  Future<List<ProjectTask>> getTasks(String projectId);
  Future<ProjectTask> createTask(ProjectTask task);
  Future<void> updateTask(ProjectTask task);
  Future<void> deleteTask(String id);

  // --- Follows ---
  Future<List<String>> followedProjectIds(String userId);

  /// `_id` of the follow row of [userId] on [projectId], or `null`.
  Future<String?> followRowId(String projectId, String userId);
  Future<void> createFollow(String projectId, String userId);
  Future<void> deleteFollow(String followId);

  // --- Participation requests ---
  Future<ParticipationRequest> createRequest(ParticipationRequest request);
  Future<List<ParticipationRequest>> getRequests({
    String? projectId,
    String? projectOwnerId,
  });

  /// Decisions on [requestIds] written by [validOwnerId] (the project
  /// creator); decisions written by anyone else are discarded.
  Future<List<RequestDecision>> getDecisions({
    required Set<String> requestIds,
    required String validOwnerId,
  });
  Future<void> createDecision({
    required String requestId,
    required RequestStatus status,
  });

  // --- Members ---
  /// Members of [projectId] created by [projectOwnerId] (the only person
  /// allowed to accept people); rows written by anyone else are discarded.
  Future<List<ProjectMember>> getMembers(
    String projectId, {
    required String projectOwnerId,
  });
  Future<ProjectMember> createMember(ProjectMember member);

  // --- Comments ---
  Future<List<ProjectComment>> getComments(String projectId);
  Future<ProjectComment> createComment(ProjectComment comment);

  // --- Notifications ---
  Future<List<AppNotification>> getNotifications();
  Future<void> sendNotification({
    required String recipientUserId,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
  });
  Future<void> markNotificationRead(String id);
}
