import '../../../home/domain/models/project.dart';
import '../../domain/models/participation_request.dart';

/// Data-source contract for shared/user-created projects. Shared by
/// local and (future) remote implementations, same pattern as every
/// other `I...Source` in the app.
abstract class ISharedProjectsSource {
  Project startDraft();
  Project? getById(String id);
  List<Project> getAll();
  void updateDraft(Project project);
  void publish(String id);
  void submitRequest(ParticipationRequest request);
  List<ParticipationRequest> requestsFor(String projectId);
}
