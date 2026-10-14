import 'package:f_clean_template/features/projects/domain/models/explore_filters.dart';

/// Textos de los filtros de Explorar, tal como aparecen en el diseño.
/// Viven en la UI: el dominio ([ExploreFilters]) no sabe de textos.
abstract final class ExploreFilterLabels {
  static const creationDate = {
    CreationDateFilter.all: 'Todos',
    CreationDateFilter.last7Days: 'Últimos 7 días',
    CreationDateFilter.last30Days: 'Últimos 30 días',
    CreationDateFilter.older: 'Más antiguos',
  };

  static const taskAvailability = {
    TaskAvailabilityFilter.all: 'Todas',
    TaskAvailabilityFilter.withOpenTasks: 'Con tareas disponibles',
    TaskAvailabilityFilter.withoutOpenTasks: 'Sin tareas disponibles',
  };

  static const memberAvailability = {
    MemberAvailabilityFilter.all: 'Todos',
    MemberAvailabilityFilter.withOpenSpots: 'Con miembros disponibles',
    MemberAvailabilityFilter.withoutOpenSpots: 'Sin miembros disponibles',
  };

  static const roles = {
    ProjectRoleFilter.designer: 'Diseñador',
    ProjectRoleFilter.developer: 'Desarrollador',
    ProjectRoleFilter.leader: 'Líder',
    ProjectRoleFilter.communicator: 'Comunicador',
    ProjectRoleFilter.other: 'Otros',
  };

  /// Etiquetas cortas de lo que está activo (para la barra bajo el buscador).
  static List<String> activeChips(ExploreFilters filters) => [
    for (final role in ProjectRoleFilter.values)
      if (filters.roles.contains(role)) roles[role]!,
    if (filters.creationDate != CreationDateFilter.all)
      creationDate[filters.creationDate]!,
    if (filters.taskAvailability != TaskAvailabilityFilter.all)
      taskAvailability[filters.taskAvailability]!,
    if (filters.memberAvailability != MemberAvailabilityFilter.all)
      memberAvailability[filters.memberAvailability]!,
  ];
}
