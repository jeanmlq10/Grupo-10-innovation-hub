import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';

/// Solicitudes para participar (tablas `project_requests` y
/// `request_decisions`).
abstract class IRequestRepository {
  Future<ParticipationRequest> submit(ParticipationRequest request);

  Future<List<ParticipationRequest>> forProject(
    String projectId, {
    required String ownerId,
  });

  Future<List<ParticipationRequest>> forProjects(
    Map<String, String> projectNames, {
    required String ownerId,
  });

  Future<void> decide(String requestId, RequestStatus status);

  Future<List<ParticipationRequest>> sentBy(String userId);
}
