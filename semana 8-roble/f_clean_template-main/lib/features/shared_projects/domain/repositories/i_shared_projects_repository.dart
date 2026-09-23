import '../../../home/domain/models/project.dart';
import '../models/app_notification.dart';
import '../models/participation_request.dart';
import '../models/project_comment.dart';
import '../models/project_member.dart';
import '../models/project_task.dart';
import '../models/project_team_role.dart';

/// The single source of truth for projects created through "Crear
/// proyecto", persisted in Roble. Reused by `create_project` (to write),
/// `my_projects` and `home` (to read), and by this feature's "Ver
/// proyecto" / apply / notifications / requests screens.
///
/// Visibility rules applied here, so no screen can leak them:
/// - "Explorar": published (`isDraft == false`) with audience
///   "Toda la comunidad".
/// - "Mis proyectos"/"Mis borradores": `createdBy` == current user.
/// Another user's drafts or private projects are never returned.
abstract class ISharedProjectsRepository {
  /// Roble userId of the logged-in user.
  String? get currentUserId;

  // --- Projects ---

  /// Creates the project row in Roble and returns it with its real id.
  Future<Project> createProject(Project project);

  /// Overwrites the project row (same id: never creates a copy).
  Future<Project> saveProject(Project project);

  /// The project if the current user may see it, otherwise `null`.
  Future<Project?> getById(String id);

  /// Projects shown in "Explorar proyectos".
  Future<List<Project>> getExplorable();

  /// Projects created by the current user (drafts and published).
  Future<List<Project>> getMine();

  // --- Team roles (long-term team) ---

  /// Team roles of the project, from its `teamRoles` (needed) and
  /// `acceptedRoleCounts` (accepted) columns. Saved with [saveProject].
  Future<List<ProjectTeamRole>> rolesFor(String projectId);

  // --- Specific tasks ---

  Future<List<ProjectTask>> tasksFor(String projectId);

  /// Makes the project's tasks match [tasks]; tasks with an empty id are
  /// created. Returns the tasks as stored.
  Future<List<ProjectTask>> setTasks(String projectId, List<ProjectTask> tasks);

  // --- Follow ---

  /// Follows or unfollows; returns whether the user follows it afterwards.
  Future<bool> toggleFollow(String projectId);

  Future<bool> isFollowing(String projectId);

  Future<Set<String>> followedProjectIds();

  // --- Participation requests ---

  Future<void> submitRequest(ParticipationRequest request);

  /// Requests of one project, each with its current status.
  Future<List<ParticipationRequest>> requestsFor(String projectId);

  /// Requests received on every project of the current user.
  Future<List<ParticipationRequest>> requestsForMyProjects();

  /// Only the project creator can decide. Accepting also updates the
  /// task/role counter, registers the member, updates the project's
  /// member count and notifies the applicant.
  Future<void> acceptRequest(ParticipationRequest request);

  Future<void> rejectRequest(ParticipationRequest request);

  // --- Members ---

  Future<List<ProjectMember>> membersFor(String projectId);

  // --- Comments ---

  Future<List<ProjectComment>> commentsFor(String projectId);

  Future<void> addComment(ProjectComment comment);

  // --- Notifications ---

  Future<List<AppNotification>> getNotifications();

  Future<void> markNotificationRead(String id);
}
