import 'package:f_clean_template/features/members/domain/models/project_member.dart';

/// Miembros reales de un proyecto (tabla `project_members`).
abstract class IMemberRepository {
  Future<List<ProjectMember>> forProject(String projectId, {required String ownerId});

  Future<ProjectMember> add(ProjectMember member);

  Future<List<ProjectMember>> forUser(String userId);
}
