import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';

/// ViewModel behind "Ver proyecto" and the whole apply sub-flow (Elige
/// cómo participar → Tareas disponibles / Envía tu solicitud → Solicitud
/// enviada). It's a single small, permanently-registered controller
/// (not one per screen) since none of those screens need to persist
/// reactive state between each other beyond what's already passed along
/// as constructor parameters (the [Project] itself, an optional
/// preselected role).
class ProjectApplicationController extends GetxController {
  ProjectApplicationController(this.repository);

  final ISharedProjectsRepository repository;

  Project? projectById(String id) => repository.getById(id);

  void submitRequest({
    required String projectId,
    required String role,
    required String message,
  }) {
    repository.submitRequest(
      ParticipationRequest(
        // The repository/data source assigns the real id — this one is
        // only a placeholder so the constructor's required parameter is
        // satisfied.
        id: '',
        projectId: projectId,
        role: role,
        message: message,
      ),
    );
  }
}
