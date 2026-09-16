import '../../../home/domain/models/project.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import '../datasources/i_shared_projects_source.dart';

/// Adapter from the domain contract to the active shared-projects data
/// source. Pass-through, same shape as every other `...Repository` in
/// the app.
class SharedProjectsRepository implements ISharedProjectsRepository {
  SharedProjectsRepository(this.source);

  final ISharedProjectsSource source;

  @override
  Project startDraft() => source.startDraft();

  @override
  Project? getById(String id) => source.getById(id);

  @override
  List<Project> getAll() => source.getAll();

  @override
  void updateDraft(Project project) => source.updateDraft(project);

  @override
  void publish(String id) => source.publish(id);

  @override
  void toggleFollow(String projectId) => source.toggleFollow(projectId);

  @override
  bool isFollowing(String projectId) => source.isFollowing(projectId);

  @override
  Set<String> followedProjectIds() => source.followedProjectIds();

  @override
  void submitRequest(ParticipationRequest request) =>
      source.submitRequest(request);

  @override
  List<ParticipationRequest> requestsFor(String projectId) =>
      source.requestsFor(projectId);

  @override
  List<ParticipationRequest> allRequests() => source.allRequests();

  @override
  void acceptRequest(String requestId) => source.acceptRequest(requestId);

  @override
  void rejectRequest(String requestId) => source.rejectRequest(requestId);

  @override
  List<AppNotification> getNotifications() => source.getNotifications();
}
