import 'package:get/get.dart';

import '../../../auth/ui/viewmodels/authentication_controller.dart';
import '../../../home/domain/models/project.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/models/project_comment.dart';
import '../../domain/models/project_member.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/project_team_role.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';

/// One entry of the "Actividad" tab, built from data stored in Roble
/// (comments and accepted members).
class ProjectActivity {
  const ProjectActivity({
    required this.title,
    required this.date,
    required this.isComment,
  });

  final String title;
  final DateTime date;
  final bool isComment;
}

/// ViewModel behind "Ver proyecto" and everything reached from it (follow,
/// comments, tasks, members, activity, requests, notifications). Screens
/// never talk to the repository or to Roble directly: they call this.
class ProjectApplicationController extends GetxController {
  ProjectApplicationController(this.repository);

  final ISharedProjectsRepository repository;

  String? get currentUserId => repository.currentUserId;

  String get _userName {
    final user = Get.find<AuthenticationController>().loggedUser;
    return user?.name ?? user?.email ?? 'Usuario';
  }

  String? get _userEmail =>
      Get.find<AuthenticationController>().loggedUser?.email;

  bool isOwner(Project project) =>
      currentUserId != null && project.createdBy == currentUserId;

  // --- Project data ---

  Future<Project?> projectById(String id) => repository.getById(id);

  Future<List<ProjectTask>> tasksFor(String projectId) =>
      repository.tasksFor(projectId);

  Future<List<ProjectTeamRole>> rolesFor(String projectId) =>
      repository.rolesFor(projectId);

  Future<List<ProjectMember>> membersFor(String projectId) =>
      repository.membersFor(projectId);

  Future<List<ProjectActivity>> activityFor(String projectId) async {
    final results = await Future.wait([
      repository.commentsFor(projectId),
      repository.membersFor(projectId),
    ]);
    final comments = results[0] as List<ProjectComment>;
    final members = results[1] as List<ProjectMember>;
    final activity = <ProjectActivity>[
      for (final comment in comments)
        ProjectActivity(
          title: '${comment.authorName} comentó',
          date: comment.createdAt,
          isComment: true,
        ),
      for (final member in members)
        ProjectActivity(
          title: '${member.name} se unió al proyecto',
          date: member.joinedAt ?? DateTime.now(),
          isComment: false,
        ),
    ];
    activity.sort((a, b) => b.date.compareTo(a.date));
    return activity;
  }

  // --- Follow ---

  Future<bool> isFollowing(String projectId) =>
      repository.isFollowing(projectId);

  Future<bool> toggleFollow(String projectId) =>
      repository.toggleFollow(projectId);

  // --- Requests ---

  Future<void> submitTaskRequest({
    required Project project,
    required ProjectTask task,
    required String message,
  }) => repository.submitRequest(
    ParticipationRequest(
      id: '',
      projectId: project.id,
      role: task.title,
      message: message,
      type: RequestType.task,
      taskId: task.id,
      applicantName: _userName,
      applicantUserId: currentUserId,
      applicantEmail: _userEmail,
    ),
  );

  Future<void> submitTeamRequest({
    required Project project,
    required ProjectTeamRole role,
    required String message,
  }) => repository.submitRequest(
    ParticipationRequest(
      id: '',
      projectId: project.id,
      role: role.role,
      message: message,
      type: RequestType.team,
      teamRoleId: role.id,
      applicantName: _userName,
      applicantUserId: currentUserId,
      applicantEmail: _userEmail,
    ),
  );

  Future<List<ParticipationRequest>> requestsForMyProjects() =>
      repository.requestsForMyProjects();

  Future<void> acceptRequest(ParticipationRequest request) =>
      repository.acceptRequest(request);

  Future<void> rejectRequest(ParticipationRequest request) =>
      repository.rejectRequest(request);

  // --- Comments ---

  Future<List<ProjectComment>> commentsFor(String projectId) =>
      repository.commentsFor(projectId);

  /// Adds a comment signed with the logged-in user's name.
  Future<void> addComment({required String projectId, required String text}) =>
      repository.addComment(
        ProjectComment(
          id: '',
          projectId: projectId,
          authorName: _userName,
          authorUserId: currentUserId,
          text: text,
          createdAt: DateTime.now(),
        ),
      );

  // --- Notifications ---

  Future<List<AppNotification>> notifications() =>
      repository.getNotifications();

  Future<void> markNotificationRead(String id) =>
      repository.markNotificationRead(id);
}
