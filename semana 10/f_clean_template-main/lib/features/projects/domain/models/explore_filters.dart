import 'package:f_clean_template/features/projects/domain/models/project.dart';

/// "Fecha de creación" del panel de filtros de Explorar.
enum CreationDateFilter { all, last7Days, last30Days, older }

/// "Disponibilidad de tareas": si el proyecto tiene tareas con cupo.
enum TaskAvailabilityFilter { all, withOpenTasks, withoutOpenTasks }

/// "Disponibilidad de miembros": si alguna convocatoria de rol sigue abierta.
enum MemberAvailabilityFilter { all, withOpenSpots, withoutOpenSpots }

/// "Rol del proyecto". "Otros" agrupa los roles que no son los cuatro fijos
/// (Investigador/a o el rol personalizado que se escribe en "Otro").
enum ProjectRoleFilter { designer, developer, leader, communicator, other }

/// Los filtros de "Explorar proyectos" (requerimiento 1.2).
///
/// Dart puro: no sabe de Roble ni de Flutter. Solo responde si un
/// [Project] cumple los criterios. Los criterios de distintas secciones se
/// combinan (Y); dentro de "Rol del proyecto" se pueden marcar varios (O).
class ExploreFilters {
  const ExploreFilters({
    this.creationDate = CreationDateFilter.all,
    this.taskAvailability = TaskAvailabilityFilter.all,
    this.memberAvailability = MemberAvailabilityFilter.all,
    this.roles = const {},
  });

  /// Sin ningún filtro ("Todos" en cada sección).
  static const none = ExploreFilters();

  final CreationDateFilter creationDate;
  final TaskAvailabilityFilter taskAvailability;
  final MemberAvailabilityFilter memberAvailability;

  /// Vacío = "Todos".
  final Set<ProjectRoleFilter> roles;

  /// Nombre exacto de cada rol fijo en `teamRoles` (lo que guarda
  /// "Equipo necesario" en la fila del proyecto).
  static const Map<ProjectRoleFilter, String> roleNames = {
    ProjectRoleFilter.designer: 'Diseñador/a',
    ProjectRoleFilter.developer: 'Desarrollador/a',
    ProjectRoleFilter.leader: 'Líder de proyecto',
    ProjectRoleFilter.communicator: 'Comunicador/a',
  };

  bool get isEmpty =>
      creationDate == CreationDateFilter.all &&
      taskAvailability == TaskAvailabilityFilter.all &&
      memberAvailability == MemberAvailabilityFilter.all &&
      roles.isEmpty;

  /// Cuántas secciones tienen algo distinto de "Todos" (para el contador).
  int get activeCount =>
      (creationDate != CreationDateFilter.all ? 1 : 0) +
      (taskAvailability != TaskAvailabilityFilter.all ? 1 : 0) +
      (memberAvailability != MemberAvailabilityFilter.all ? 1 : 0) +
      (roles.isNotEmpty ? 1 : 0);

  ExploreFilters copyWith({
    CreationDateFilter? creationDate,
    TaskAvailabilityFilter? taskAvailability,
    MemberAvailabilityFilter? memberAvailability,
    Set<ProjectRoleFilter>? roles,
  }) => ExploreFilters(
    creationDate: creationDate ?? this.creationDate,
    taskAvailability: taskAvailability ?? this.taskAvailability,
    memberAvailability: memberAvailability ?? this.memberAvailability,
    roles: roles ?? this.roles,
  );

  /// Marca o desmarca un rol (varios a la vez se combinan con O).
  ExploreFilters toggleRole(ProjectRoleFilter role) {
    final next = Set<ProjectRoleFilter>.from(roles);
    if (!next.remove(role)) next.add(role);
    return copyWith(roles: next);
  }

  /// ¿[project] cumple todos los filtros?
  ///
  /// [hasOpenTasks]: si el proyecto tiene alguna tarea con cupo (sale de la
  /// tabla `project_tasks`, lo calcula el repositorio de tareas).
  bool matches(
    Project project, {
    required bool hasOpenTasks,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return _matchesDate(project.createdAt, at) &&
        _matchesTasks(hasOpenTasks) &&
        _matchesMembersAndRoles(project, at);
  }

  bool _matchesDate(DateTime? createdAt, DateTime now) {
    switch (creationDate) {
      case CreationDateFilter.all:
        return true;
      case CreationDateFilter.last7Days:
        return createdAt != null &&
            !createdAt.isBefore(now.subtract(const Duration(days: 7)));
      case CreationDateFilter.last30Days:
        return createdAt != null &&
            !createdAt.isBefore(now.subtract(const Duration(days: 30)));
      case CreationDateFilter.older:
        // Más de 30 días, o proyectos creados antes de guardar la fecha.
        return createdAt == null ||
            createdAt.isBefore(now.subtract(const Duration(days: 30)));
    }
  }

  bool _matchesTasks(bool hasOpenTasks) {
    switch (taskAvailability) {
      case TaskAvailabilityFilter.all:
        return true;
      case TaskAvailabilityFilter.withOpenTasks:
        return hasOpenTasks;
      case TaskAvailabilityFilter.withoutOpenTasks:
        return !hasOpenTasks;
    }
  }

  /// Rol y disponibilidad de miembros se combinan: con "Con miembros
  /// disponibles" + "Diseñador", el proyecto debe tener cupo libre
  /// justamente en Diseñador/a.
  bool _matchesMembersAndRoles(Project project, DateTime now) {
    // Con la convocatoria vencida ningún rol tiene cupo disponible.
    final callOpen = project.isTeamCallOpenAt(now);
    // Roles que el proyecto pidió (con al menos 1 persona).
    final requested = {
      for (final entry in project.teamRoles.entries)
        if (entry.value > 0) entry.key,
    };
    // Roles que todavía tienen cupo (necesarias > aceptadas).
    final open = {
      for (final entry in project.teamRoles.entries)
        if (callOpen && entry.value - (project.acceptedRoleCounts[entry.key] ?? 0) > 0)
          entry.key,
    };

    final relevantRequested = roles.isEmpty
        ? requested
        : requested.where(_isSelectedRole).toSet();
    final relevantOpen = roles.isEmpty
        ? open
        : open.where(_isSelectedRole).toSet();

    if (roles.isNotEmpty && relevantRequested.isEmpty) return false;

    switch (memberAvailability) {
      case MemberAvailabilityFilter.all:
        return true;
      case MemberAvailabilityFilter.withOpenSpots:
        return relevantOpen.isNotEmpty;
      case MemberAvailabilityFilter.withoutOpenSpots:
        return relevantOpen.isEmpty;
    }
  }

  bool _isSelectedRole(String roleName) {
    for (final role in roles) {
      if (role == ProjectRoleFilter.other) {
        if (!roleNames.containsValue(roleName)) return true;
      } else if (roleNames[role] == roleName) {
        return true;
      }
    }
    return false;
  }
}
