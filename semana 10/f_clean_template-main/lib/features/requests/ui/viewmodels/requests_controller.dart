import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/members/domain/models/project_member.dart';
import 'package:f_clean_template/features/members/domain/repositories/i_member_repository.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/models/project_team_role.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';
import 'package:f_clean_template/features/requests/domain/repositories/i_request_repository.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// ViewModel de las solicitudes: enviar (tarea o equipo) y, para el dueno,
/// aceptar o rechazar. Aqui viven las reglas de negocio que cruzan features
/// (no hay casos de uso, igual que en el repositorio de referencia).
class RequestsController extends GetxController {
  RequestsController({
    required this.requests,
    required this.projects,
    required this.tasks,
    required this.members,
    required this.notifications,
    required this.session,
  });

  final IRequestRepository requests;
  final IProjectRepository projects;
  final ITaskRepository tasks;
  final IMemberRepository members;
  final INotificationRepository notifications;
  final AuthenticationController session;

  String get _me {
    final id = session.loggedUser?.userId;
    if (id == null || id.isEmpty) {
      throw StateError('Debes iniciar sesión para hacer esto.');
    }
    return id;
  }

  String get _myName {
    final user = session.loggedUser;
    return user?.name ?? user?.email ?? 'Usuario';
  }

  // ------------------------------------------------------------ Enviar

  Future<void> submitTaskRequest({
    required Project project,
    required ProjectTask task,
    required String message,
  }) => _submit(
    project,
    ParticipationRequest(
      id: '',
      projectId: project.id,
      role: task.title,
      message: message,
      type: RequestType.task,
      taskId: task.id,
    ),
  );

  Future<void> submitTeamRequest({
    required Project project,
    required ProjectTeamRole role,
    required String message,
  }) => _submit(
    project,
    ParticipationRequest(
      id: '',
      projectId: project.id,
      role: role.role,
      message: message,
      type: RequestType.team,
      teamRoleId: role.id,
    ),
  );

  /// Regla: solo a proyectos publicos y nunca al propio. Se avisa al dueno.
  Future<void> _submit(Project project, ParticipationRequest draft) async {
    final me = _me;
    final fresh = await projects.getById(project.id, viewerId: me);
    if (fresh == null || !fresh.isPublic) {
      throw StateError('Este proyecto no recibe solicitudes.');
    }
    if (fresh.createdBy == me) {
      throw StateError('No puedes postularte a tu propio proyecto.');
    }
    // Cambio 2: fechas límite. Se revisa con los datos frescos de Roble,
    // no con lo que la pantalla tenía cargado.
    if (draft.type == RequestType.team && !fresh.isTeamCallOpenAt()) {
      throw StateError('La convocatoria para unirse al equipo ya cerró.');
    }
    if (draft.type == RequestType.task) {
      final current = (await tasks.forProject(fresh.id))
          .where((task) => task.id == draft.taskId);
      if (current.isEmpty || !current.first.canApplyAt()) {
        throw StateError('La postulación a esta tarea ya cerró.');
      }
    }
    final created = await requests.submit(
      ParticipationRequest(
        id: '',
        projectId: draft.projectId,
        role: draft.role,
        message: draft.message,
        type: draft.type,
        taskId: draft.taskId,
        teamRoleId: draft.teamRoleId,
        applicantName: _myName,
        applicantUserId: me,
        applicantEmail: session.loggedUser?.email,
      ),
    );
    final owner = fresh.createdBy;
    if (owner != null) {
      final projectName = fresh.name.isEmpty ? 'sin nombre' : fresh.name;
      final isTask = draft.type == RequestType.task;
      // Página 4: "Nueva postulación a tarea" o "Solicitud para unirse al
      // equipo", con quién la envió y a qué rol/tarea.
      await _notify(
        recipient: owner,
        type: isTask
            ? AppNotificationType.taskApplication
            : AppNotificationType.newRequest,
        title: isTask
            ? 'Nueva postulación a tarea'
            : 'Solicitud para unirse al equipo',
        message: isTask
            ? '$_myName se postuló a la tarea ${draft.role}.'
            : '$_myName quiere unirse a tu proyecto $projectName.',
        projectId: fresh.id,
        requestId: created.id,
        actorUserId: me,
        actorName: _myName,
        detail: draft.role,
      );
    }
  }

  // ------------------------------------------------------------ Decidir

  /// Una solicitud recibida en un proyecto mío, con su estado actual (para
  /// el detalle de la notificación). null si no existe o no es mío.
  Future<ParticipationRequest?> requestFor(
    String projectId,
    String requestId,
  ) async {
    final me = _me;
    await _ownedProject(projectId, me);
    final found = (await requests.forProject(
      projectId,
      ownerId: me,
    )).where((r) => r.id == requestId);
    return found.isEmpty ? null : found.first;
  }

  Future<List<ParticipationRequest>> requestsForMyProjects() async {
    final me = session.loggedUser?.userId;
    if (me == null) return const [];
    final mine = await projects.ownedBy(me);
    return requests.forProjects(
      {for (final p in mine) p.id: p.name},
      ownerId: me,
    );
  }

  /// Solo el dueno. Idempotente: si ya se decidio, o la persona ya es
  /// miembro en ese rol, no escribe nada de nuevo.
  Future<void> acceptRequest(ParticipationRequest request) async {
    final me = _me;
    var project = await _ownedProject(request.projectId, me);
    if (!await _isPending(request, me)) return;

    final current = await members.forProject(project.id, ownerId: me);
    final alreadyMember = current.any(
      (m) => m.userId == request.applicantUserId && m.role == request.role,
    );

    await requests.decide(request.id, RequestStatus.accepted);
    if (alreadyMember) return;

    String? sourceId;
    if (request.type == RequestType.task && request.taskId != null) {
      final projectTasks = await tasks.forProject(project.id);
      for (final task in projectTasks) {
        if (task.id != request.taskId) continue;
        await tasks.addAccepted(task);
        sourceId = task.id;
        break;
      }
    } else {
      final roleName = request.teamRoleId ?? request.role;
      final counts = Map<String, int>.from(project.acceptedRoleCounts);
      counts[roleName] = (counts[roleName] ?? 0) + 1;
      project = project.copyWith(acceptedRoleCounts: counts);
      sourceId = roleName;
    }

    await members.add(
      ProjectMember(
        id: '',
        projectId: project.id,
        userId: request.applicantUserId ?? '',
        name: request.applicantName,
        email: request.applicantEmail,
        role: request.role,
        sourceType: request.type == RequestType.task
            ? MemberSourceType.task
            : MemberSourceType.team,
        sourceId: sourceId,
        requestId: request.id,
      ),
    );

    await projects.save(
      project.copyWith(acceptedMembersCount: project.acceptedMembersCount + 1),
    );

    final applicant = request.applicantUserId;
    if (applicant != null && applicant != me) {
      final projectName = project.name.isEmpty ? 'el proyecto' : project.name;
      final isTask = request.type == RequestType.task;
      await _notify(
        recipient: applicant,
        type: isTask
            ? AppNotificationType.taskApplicationAccepted
            : AppNotificationType.requestAccepted,
        title: isTask ? 'Postulación aceptada' : 'Solicitud aceptada',
        message: isTask
            ? 'Fuiste asignado a la tarea ${request.role}.'
            : 'Ya eres parte del proyecto $projectName como ${request.role}.',
        projectId: project.id,
        requestId: request.id,
        actorUserId: me,
        actorName: _myName,
        detail: request.role,
      );
    }
  }

  Future<void> rejectRequest(ParticipationRequest request) async {
    final me = _me;
    final project = await _ownedProject(request.projectId, me);
    if (!await _isPending(request, me)) return;
    await requests.decide(request.id, RequestStatus.rejected);
    final applicant = request.applicantUserId;
    if (applicant != null && applicant != me) {
      final projectName = project.name.isEmpty ? 'el proyecto' : project.name;
      final isTask = request.type == RequestType.task;
      await _notify(
        recipient: applicant,
        type: isTask
            ? AppNotificationType.taskApplicationRejected
            : AppNotificationType.requestRejected,
        title: isTask ? 'Postulación rechazada' : 'Solicitud rechazada',
        message: isTask
            ? 'Tu postulación para la tarea ${request.role} no fue aceptada.'
            : 'Tu solicitud para unirte a $projectName no fue aceptada.',
        projectId: project.id,
        requestId: request.id,
        actorUserId: me,
        actorName: _myName,
        detail: request.role,
      );
    }
  }

  Future<Project> _ownedProject(String projectId, String me) async {
    final project = await projects.getById(projectId, viewerId: me);
    if (project == null || project.createdBy != me) {
      throw StateError(
        'Solo el creador del proyecto puede gestionar solicitudes.',
      );
    }
    return project;
  }

  Future<bool> _isPending(ParticipationRequest request, String me) async {
    final current = (await requests.forProject(
      request.projectId,
      ownerId: me,
    )).where((r) => r.id == request.id);
    return current.isNotEmpty && current.first.status == RequestStatus.pending;
  }

  /// Un aviso que falla no deshace la accion que lo produjo.
  Future<void> _notify({
    required String recipient,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
    String? actorUserId,
    String? actorName,
    String? detail,
  }) async {
    try {
      await notifications.send(
        recipientUserId: recipient,
        type: type,
        title: title,
        message: message,
        projectId: projectId,
        requestId: requestId,
        actorUserId: actorUserId,
        actorName: actorName,
        detail: detail,
      );
    } catch (_) {
      // Ignorado a proposito: ver arriba.
    }
  }
}
