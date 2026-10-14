import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';
import 'package:f_clean_template/features/comments/domain/repositories/i_comment_repository.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';

/// ViewModel de la hoja de comentarios.
class CommentsController extends GetxController {
  CommentsController({
    required this.comments,
    required this.projects,
    required this.notifications,
    required this.session,
  });

  final ICommentRepository comments;
  final IProjectRepository projects;
  final INotificationRepository notifications;
  final AuthenticationController session;

  Future<List<ProjectComment>> commentsFor(String projectId) =>
      comments.forProject(projectId);

  /// Regla: solo en proyectos que el usuario puede ver. Se avisa al dueno.
  Future<void> addComment({
    required String projectId,
    required String text,
  }) async {
    final user = session.loggedUser;
    if (user == null) throw StateError('Debes iniciar sesión para comentar.');
    final project = await projects.getById(projectId, viewerId: user.userId);
    if (project == null) {
      throw StateError('No puedes comentar en este proyecto.');
    }
    final name = user.name.isEmpty ? user.email : user.name;
    await comments.add(
      ProjectComment(
        id: '',
        projectId: projectId,
        authorName: name,
        authorUserId: user.userId,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    final owner = project.createdBy;
    if (owner != null && owner != user.userId) {
      try {
        await notifications.send(
          recipientUserId: owner,
          type: AppNotificationType.newComment,
          title: 'Comentario en tu proyecto',
          message:
              '$name comentó en '
              '${project.name.isEmpty ? "tu proyecto" : project.name}.',
          projectId: project.id,
          // Página 4.3: el detalle muestra quién y qué comentó.
          actorUserId: user.userId,
          actorName: name,
          detail: text,
        );
      } catch (_) {
        // El comentario ya quedo guardado; el aviso es secundario.
      }
    }
  }
}
