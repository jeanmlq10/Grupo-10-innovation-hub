import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';

/// Solicitudes para participar (tablas `project_requests` y
/// `request_decisions`).
///
/// La fila de la solicitud es de quien la envia, asi que el dueno del
/// proyecto no puede editarla ("actualizar solo lo propio"): su decision se
/// guarda aparte y el estado se calcula a partir de ahi.
abstract class IRequestRepository {
  Future<ParticipationRequest> submit(ParticipationRequest request);

  /// Solicitudes de [projectId], con el estado que decidio [ownerId].
  Future<List<ParticipationRequest>> forProject(
    String projectId, {
    required String ownerId,
  });

  /// Solicitudes recibidas en varios proyectos de [ownerId]
  /// ([projectNames]: id → nombre).
  Future<List<ParticipationRequest>> forProjects(
    Map<String, String> projectNames, {
    required String ownerId,
  });

  Future<void> decide(String requestId, RequestStatus status);

  /// Solicitudes que envió [userId] (sin calcular su estado). Para el
  /// resumen de trayectoria del perfil.
  Future<List<ParticipationRequest>> sentBy(String userId);
}
