import 'package:f_clean_template/features/members/domain/models/project_member.dart';

/// Miembros reales de un proyecto (tabla `project_members`).
abstract class IMemberRepository {
  /// Miembros de [projectId] registrados por su creador [ownerId].
  Future<List<ProjectMember>> forProject(String projectId, {required String ownerId});

  Future<ProjectMember> add(ProjectMember member);

  /// Participaciones de [userId] en cualquier proyecto (para su perfil).
  /// Cada una trae [ProjectMember.recordedBy]: solo cuenta si quien la
  /// registró es el creador de ese proyecto.
  Future<List<ProjectMember>> forUser(String userId);
}
