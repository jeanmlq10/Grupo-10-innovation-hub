import 'dart:convert';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';
import 'package:f_clean_template/features/comments/domain/repositories/i_comment_repository.dart';
import 'package:f_clean_template/features/follows/domain/models/project_follow.dart';
import 'package:f_clean_template/features/follows/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/members/domain/models/project_member.dart';
import 'package:f_clean_template/features/members/domain/repositories/i_member_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/activity_entry.dart';
import 'package:f_clean_template/features/profile/domain/models/public_profile.dart';
import 'package:f_clean_template/features/profile/domain/models/trajectory_summary.dart';
import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/requests/domain/repositories/i_request_repository.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// Lo que se junta de Roble para calcular la trayectoria y el historial de
/// una persona. Solo lo usa este controller.
class _UserData {
  _UserData({
    required this.owned,
    required this.memberships,
    required this.projectsById,
    required this.tasksByProject,
  });

  final List<Project> owned;

  final List<ProjectMember> memberships;
  final Map<String, Project> projectsById;
  final Map<String, List<ProjectTask>> tasksByProject;
}

/// ViewModel de "Mi perfil" (Página 5) y del perfil público de otra persona.
class ProfileController extends GetxController with UiLoggy {
  ProfileController({
    required this.profiles,
    required this.projects,
    required this.tasks,
    required this.members,
    required this.comments,
    required this.follows,
    required this.requests,
    required this.session,
  });

  final IProfileRepository profiles;
  final IProjectRepository projects;
  final ITaskRepository tasks;
  final IMemberRepository members;
  final ICommentRepository comments;
  final IFollowRepository follows;
  final IRequestRepository requests;
  final AuthenticationController session;

  final Rxn<UserProfile> profile = Rxn<UserProfile>();
  final Rx<TrajectorySummary> summary = TrajectorySummary.empty.obs;
  final RxList<ActivityEntry> activity = <ActivityEntry>[].obs;
  final RxList<Project> myProjects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString loadError = ''.obs;

  String? get _me => session.loggedUser?.userId;

  String get roleLabel {
    final s = summary.value;
    if (s.projectsCreated > 0) return 'Creador/a de proyectos';
    if (s.participations > 0) return 'Colaborador/a';
    final career = profile.value?.career ?? '';
    return career.isNotEmpty ? career : 'Nuevo en Movil';
  }

  Future<void> loadMine() async {
    final user = session.loggedUser;
    if (user == null) return;
    isLoading.value = true;
    loadError.value = '';
    UserProfile? stored;
    try {
      stored = await profiles.byUserId(user.userId);
    } catch (error) {
      loggy.warning('ProfileController: user_profiles no disponible: $error');
    }
    profile.value =
        (stored ??
                UserProfile.fromSession(
                  userId: user.userId,
                  name: user.name,
                  email: user.email,
                  career: user.career ?? '',
                ))
            .copyWith(
              email: user.email,
              name: (stored?.name ?? '').isEmpty ? user.name : stored!.name,
            );

    try {
      final data = await _collect(user.userId, viewerId: user.userId);
      myProjects.assignAll(data.owned);
      summary.value = await _summarize(user.userId, data);
      activity.assignAll(await _activity(user.userId, data));
    } catch (error) {
      loggy.error('ProfileController: could not load: $error');
      loadError.value = errorMessage(
        error,
        fallback: 'No se pudo cargar tu perfil.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveBasics({
    required String name,
    required String username,
    required String bio,
    required String career,
    String? avatarIcon,
  }) {
    final current = profile.value;
    if (current == null) return Future.value(false);
    if (name.trim().isEmpty) {
      Get.snackbar('Editar perfil', 'El nombre no puede quedar vacío.');
      return Future.value(false);
    }
    return _save(
      current.copyWith(
        name: name.trim(),
        username: username.trim(),
        bio: bio.trim(),
        career: career.trim(),
        avatarIcon: avatarIcon,
      ),
    );
  }

  Future<bool> savePrivacy({
    ProfileVisibility? visibility,
    ContactPermission? contact,
    ActivityVisibility? activityVisibility,
  }) {
    final current = profile.value;
    if (current == null) return Future.value(false);
    return _save(
      current.copyWith(
        visibility: visibility,
        contact: contact,
        activityVisibility: activityVisibility,
      ),
    );
  }

  Future<bool> saveNotificationPrefs({
    required bool enabled,
    required Set<String> muted,
  }) {
    final current = profile.value;
    if (current == null) return Future.value(false);
    return _save(
      current.copyWith(notificationsEnabled: enabled, mutedNotifications: muted),
    );
  }

  Future<bool> _save(UserProfile next) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      profile.value = (await profiles.save(next)).copyWith(email: next.email);
      return true;
    } catch (error) {
      Get.snackbar(
        'Perfil',
        errorMessage(error, fallback: 'No se pudo guardar.'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> requestPasswordChange() async {
    final email = session.loggedUser?.email ?? '';
    if (email.isEmpty) return false;
    return session.forgotPassword(email);
  }

  String exportMyData() {
    final p = profile.value;
    final s = summary.value;
    return const JsonEncoder.withIndent('  ').convert({
      'perfil': {
        'nombre': p?.name,
        'correo': p?.email,
        'usuario': p?.username,
        'biografia': p?.bio,
        'carrera': p?.career,
        'visibilidad': p?.visibility.name,
        'contacto': p?.contact.name,
        'actividad': p?.activityVisibility.name,
      },
      'trayectoria': {
        'proyectosCreados': s.projectsCreated,
        'proyectosCompletados': s.projectsCompleted,
        'tareasAsignadas': s.tasksAssigned,
        'tareasCompletadas': s.tasksCompleted,
        'participaciones': s.participations,
        'comentarios': s.comments,
        'solicitudesEnviadas': s.requestsSent,
      },
      'historial': [
        for (final entry in activity)
          {
            'tipo': entry.kind.name,
            'proyecto': entry.projectName,
            'fecha': entry.date?.toIso8601String(),
          },
      ],
    });
  }

  Future<bool> deleteProfileData() async {
    final current = profile.value;
    try {
      if (current != null) await profiles.delete(current);
      await session.logOut();
      profile.value = null;
      return true;
    } catch (error) {
      Get.snackbar(
        'Eliminar cuenta',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> logOut() => session.logOut();

  Future<PublicProfile> publicProfile(String userId, {String? fallbackName}) async {
    final stored = await profiles
        .byUserId(userId)
        .catchError((Object _) => null);
    final base =
        stored ??
        UserProfile(userId: userId, name: fallbackName ?? 'Usuario');
    final isMe = userId == _me;
    final canSee = isMe || (base.isPublic && base.showsActivity);
    if (!canSee) {
      return PublicProfile(
        profile: base,
        summary: null,
        activity: const [],
        canSeeDetails: false,
      );
    }
    final data = await _collect(userId, viewerId: _me);
    return PublicProfile(
      profile: base,
      summary: await _summarize(userId, data),
      activity: await _activity(userId, data),
      canSeeDetails: true,
    );
  }

  Future<List<Project>> participationsOf(String userId) async {
    final data = await _collect(userId, viewerId: _me);
    final ids = data.memberships.map((m) => m.projectId).toSet();
    return [
      for (final id in ids)
        if (data.projectsById[id] != null) data.projectsById[id]!,
    ];
  }

  Future<_UserData> _collect(String userId, {String? viewerId}) async {
    final isMe = userId == viewerId;
    final results = await Future.wait([
      projects.ownedBy(userId).catchError((Object _) => <Project>[]),
      members.forUser(userId).catchError((Object _) => <ProjectMember>[]),
    ]);
    final owned = (results[0] as List<Project>)
        .where((p) => isMe || p.isPublic)
        .toList();
    final rawMemberships = results[1] as List<ProjectMember>;

    final projectsById = {for (final p in owned) p.id: p};
    final otherIds = rawMemberships
        .map((m) => m.projectId)
        .where((id) => !projectsById.containsKey(id))
        .toSet();
    final others = await Future.wait(
      otherIds.map(
        (id) => projects
            .getById(id, viewerId: viewerId)
            .catchError((Object _) => null),
      ),
    );
    for (final project in others) {
      if (project != null) projectsById[project.id] = project;
    }

    final memberships = rawMemberships.where((m) {
      final project = projectsById[m.projectId];
      if (project == null || project.createdBy == userId) return false;
      return m.recordedBy == null || m.recordedBy == project.createdBy;
    }).toList();

    final involved = {
      ...owned.map((p) => p.id),
      ...memberships.map((m) => m.projectId),
    };
    final taskLists = await Future.wait(
      involved.map(
        (id) => tasks
            .forProject(id)
            .catchError((Object _) => <ProjectTask>[]),
      ),
    );
    final tasksByProject = <String, List<ProjectTask>>{};
    var i = 0;
    for (final id in involved) {
      tasksByProject[id] = taskLists[i++];
    }

    return _UserData(
      owned: owned,
      memberships: memberships,
      projectsById: projectsById,
      tasksByProject: tasksByProject,
    );
  }

  Future<TrajectorySummary> _summarize(String userId, _UserData data) async {
    final extra = await Future.wait([
      comments.byAuthor(userId).then((list) => list.length).catchError(
        (Object _) => 0,
      ),
      requests.sentBy(userId).then((list) => list.length).catchError(
        (Object _) => 0,
      ),
    ]);

    final assignedIds = data.memberships
        .where((m) => m.sourceType == MemberSourceType.task)
        .map((m) => m.sourceId)
        .whereType<String>()
        .toSet();
    final allTasks = data.tasksByProject.values.expand((list) => list);
    final completedAssigned = allTasks
        .where(
          (t) =>
              assignedIds.contains(t.id) &&
              t.progress == TaskProgress.completed,
        )
        .length;

    final involved = {
      ...data.owned.map((p) => p.id),
      ...data.memberships.map((m) => m.projectId),
    };
    final projectsCompleted = involved.where((id) {
      final list = data.tasksByProject[id] ?? const <ProjectTask>[];
      return list.isNotEmpty &&
          list.every((t) => t.progress == TaskProgress.completed);
    }).length;

    final participations = data.memberships.map((m) => m.projectId).toSet();

    return TrajectorySummary(
      projectsCreated: data.owned.where((p) => !p.isDraft).length,
      projectsCompleted: projectsCompleted,
      tasksAssigned: assignedIds.length,
      tasksCompleted: completedAssigned,
      participations: participations.length,
      comments: extra[0],
      requestsSent: extra[1],
      requestsAccepted: data.memberships.length,
    );
  }

  Future<List<ActivityEntry>> _activity(String userId, _UserData data) async {
    final myComments = await comments
        .byAuthor(userId)
        .catchError((Object _) => <ProjectComment>[]);
    final myFollows = await follows
        .followsOf(userId)
        .catchError((Object _) => <ProjectFollow>[]);

    final missing = {
      ...myComments.map((c) => c.projectId),
      ...myFollows.map((f) => f.projectId),
    }.where((id) => !data.projectsById.containsKey(id)).toSet();
    final fetched = await Future.wait(
      missing.map(
        (id) => projects
            .getById(id, viewerId: _me)
            .catchError((Object _) => null),
      ),
    );
    final names = {
      for (final p in data.projectsById.values) p.id: p.name,
      for (final p in fetched)
        if (p != null) p.id: p.name,
    };
    String nameOf(String id) {
      final name = names[id] ?? '';
      return name.isEmpty ? 'Proyecto' : name;
    }

    final entries = <ActivityEntry>[
      for (final project in data.owned.where((p) => !p.isDraft))
        ActivityEntry(
          kind: ActivityKind.publication,
          projectId: project.id,
          projectName: nameOf(project.id),
          date: project.createdAt,
        ),
      for (final m in data.memberships)
        ActivityEntry(
          kind: m.sourceType == MemberSourceType.task
              ? ActivityKind.taskAssignment
              : ActivityKind.participation,
          projectId: m.projectId,
          projectName: nameOf(m.projectId),
          date: m.joinedAt,
          detail: m.role,
        ),
      for (final c in myComments)
        if (names.containsKey(c.projectId))
          ActivityEntry(
            kind: ActivityKind.comment,
            projectId: c.projectId,
            projectName: nameOf(c.projectId),
            date: c.createdAt,
            detail: c.text,
          ),
      for (final f in myFollows)
        if (names.containsKey(f.projectId))
          ActivityEntry(
            kind: ActivityKind.follow,
            projectId: f.projectId,
            projectName: nameOf(f.projectId),
            date: f.createdAt,
          ),
    ];
    entries.sort(
      (a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)),
    );
    return entries;
  }
}
