import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';
import 'package:f_clean_template/features/comments/domain/repositories/i_comment_repository.dart';
import 'package:f_clean_template/features/follows/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/members/domain/models/project_member.dart';
import 'package:f_clean_template/features/members/domain/repositories/i_member_repository.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/models/project_team_role.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// Una entrada de la pestana "Actividad" (comentarios y miembros que se
/// unieron, leidos de Roble).
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

/// ViewModel de "Ver proyecto". Junta varias features (proyectos, tareas,
/// miembros, comentarios, seguidores) igual que el detalle del repositorio de
/// referencia: habla solo con sus interfaces `I...Repository`.
class ProjectDetailController extends GetxController {
  ProjectDetailController({
    required this.projects,
    required this.tasks,
    required this.members,
    required this.comments,
    required this.follows,
    required this.session,
    required this.notifications,
  });

  final IProjectRepository projects;
  final ITaskRepository tasks;
  final IMemberRepository members;
  final ICommentRepository comments;
  final IFollowRepository follows;

  /// Para avisar "Tarea completada" a quienes trabajaban en ella.
  final INotificationRepository notifications;
  final AuthenticationController session;

  String? get currentUserId => session.loggedUser?.userId;

  /// Visitante ("Continuar como visitante"): solo consulta, sin sesion.
  /// Lee proyectos y tareas con la lectura publica de Roble; miembros,
  /// comentarios y seguidos piden iniciar sesion.
  bool get isGuest => session.isGuest;

  bool isOwner(Project project) =>
      currentUserId != null && project.createdBy == currentUserId;

  Future<Project?> projectById(String id) =>
      projects.getById(id, viewerId: currentUserId, publicAccess: isGuest);

  Future<List<ProjectTask>> tasksFor(String projectId) =>
      tasks.forProject(projectId, publicAccess: isGuest);

  /// Solo el dueño: marca la tarea como disponible, en progreso o
  /// completada (requerimiento 3.1).
  Future<void> setTaskProgress(
    Project project,
    ProjectTask task,
    TaskProgress progress,
  ) async {
    if (!isOwner(project)) {
      throw StateError('Solo el creador del proyecto puede cambiar el estado.');
    }
    await tasks.setProgress(task, progress);
    if (progress == TaskProgress.completed) {
      await _notifyTaskCompleted(project, task);
    }
  }

  /// Página 4.3 "Tarea completada": avisa a los miembros asignados a la
  /// tarea. Si el aviso falla, el cambio de estado ya quedó guardado.
  Future<void> _notifyTaskCompleted(Project project, ProjectTask task) async {
    final me = currentUserId;
    if (me == null) return;
    try {
      final assigned = (await members.forProject(project.id, ownerId: me))
          .where(
            (m) =>
                m.sourceType == MemberSourceType.task &&
                (m.sourceId == task.id || m.role == task.title) &&
                m.userId != me,
          )
          .map((m) => m.userId)
          .toSet();
      final myName = session.loggedUser?.name ?? 'El creador';
      for (final userId in assigned) {
        await notifications.send(
          recipientUserId: userId,
          type: AppNotificationType.taskCompleted,
          title: 'Tarea completada',
          message: '$myName marcó como completada la tarea ${task.title}.',
          projectId: project.id,
          actorUserId: me,
          actorName: myName,
          detail: task.title,
        );
      }
    } catch (_) {
      // Ignorado a propósito: ver arriba.
    }
  }

  Future<List<ProjectTeamRole>> rolesFor(String projectId) async {
    final project = await projectById(projectId);
    return project == null ? const [] : projects.rolesOf(project);
  }

  Future<List<ProjectMember>> membersFor(String projectId) async {
    // El visitante no ve quienes forman el equipo (la vista lo explica).
    if (isGuest) return const [];
    final project = await projects.getById(projectId, viewerId: currentUserId);
    final owner = project?.createdBy;
    if (owner == null) return const [];
    return members.forProject(projectId, ownerId: owner);
  }

  Future<List<ProjectActivity>> activityFor(String projectId) async {
    if (isGuest) {
      throw StateError('Inicia sesión para ver la actividad del proyecto.');
    }
    final results = await Future.wait([
      comments.forProject(projectId),
      membersFor(projectId),
    ]);
    final commentList = results[0] as List<ProjectComment>;
    final memberList = results[1] as List<ProjectMember>;
    final activity = <ProjectActivity>[
      for (final c in commentList)
        ProjectActivity(
          title: '${c.authorName} comentó',
          date: c.createdAt,
          isComment: true,
        ),
      for (final m in memberList)
        ProjectActivity(
          title: '${m.name} se unió al proyecto',
          date: m.joinedAt ?? DateTime.now(),
          isComment: false,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return activity;
  }

  Future<bool> isFollowing(String projectId) async {
    final userId = currentUserId;
    if (userId == null) return false;
    return follows.isFollowing(projectId, userId);
  }

  Future<bool> toggleFollow(String projectId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('Debes iniciar sesión para seguir proyectos.');
    }
    return follows.toggle(projectId, userId);
  }
}
