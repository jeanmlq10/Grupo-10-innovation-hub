import '../../../../home/domain/models/project.dart';
import '../../../domain/models/app_notification.dart';
import '../../../domain/models/participation_request.dart';
import '../i_shared_projects_source.dart';

/// Local/in-memory implementation of [ISharedProjectsSource] — the
/// single in-memory list every user-created [Project] actually lives
/// in, plus who follows what and every participation request/
/// notification that comes out of it. No Firebase, no Supabase, no API,
/// no database: everything here is plain Dart state that survives for
/// the app's session.
class LocalSharedProjectsSource implements ISharedProjectsSource {
  final List<Project> _projects = [];
  final List<ParticipationRequest> _requests = [];
  final List<AppNotification> _notifications = [];
  final Set<String> _followed = {};

  int _nextProjectId = 1;
  int _nextRequestId = 1;
  int _nextNotificationId = 1;

  @override
  Project startDraft() {
    final draft = Project(
      id: 'u${_nextProjectId++}',
      name: '',
      description: '',
      categories: const [],
      canApply: true,
      isDraft: true,
    );
    _projects.add(draft);
    return draft;
  }

  @override
  Project? getById(String id) {
    for (final project in _projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  @override
  List<Project> getAll() => List.unmodifiable(_projects);

  @override
  void updateDraft(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      _projects.add(project);
    } else {
      _projects[index] = project;
    }
  }

  @override
  void publish(String id) {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(isDraft: false);
  }

  @override
  void toggleFollow(String projectId) {
    if (_followed.contains(projectId)) {
      _followed.remove(projectId);
    } else {
      _followed.add(projectId);
    }
  }

  @override
  bool isFollowing(String projectId) => _followed.contains(projectId);

  @override
  Set<String> followedProjectIds() => Set.unmodifiable(_followed);

  @override
  void submitRequest(ParticipationRequest request) {
    final id = 'r${_nextRequestId++}';
    _requests.add(
      ParticipationRequest(
        id: id,
        projectId: request.projectId,
        role: request.role,
        message: request.message,
        applicantName: request.applicantName,
        applicantUserId: request.applicantUserId,
        applicantEmail: request.applicantEmail,
      ),
    );

    final project = getById(request.projectId);
    _notifications.insert(
      0,
      AppNotification(
        id: 'n${_nextNotificationId++}',
        requestId: id,
        projectId: request.projectId,
        title: 'Nueva solicitud',
        message:
            '${request.applicantName} quiere unirse a tu proyecto '
            '${project?.name.isNotEmpty == true ? project!.name : "sin nombre"}.',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  List<ParticipationRequest> requestsFor(String projectId) => List.unmodifiable(
    _requests.where((request) => request.projectId == projectId),
  );

  @override
  List<ParticipationRequest> allRequests() => List.unmodifiable(_requests);

  @override
  void acceptRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    final request = _requests[index];
    _requests[index] = request.copyWith(status: RequestStatus.accepted);

    final projectIndex = _projects.indexWhere((p) => p.id == request.projectId);
    if (projectIndex != -1) {
      final project = _projects[projectIndex];
      _projects[projectIndex] = project.copyWith(
        acceptedMembersCount: project.acceptedMembersCount + 1,
      );
    }
  }

  @override
  void rejectRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    _requests[index] = _requests[index].copyWith(
      status: RequestStatus.rejected,
    );
  }

  @override
  List<AppNotification> getNotifications() => List.unmodifiable(_notifications);
}
