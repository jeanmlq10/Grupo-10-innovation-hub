import 'package:flutter_test/flutter_test.dart';

import 'package:f_clean_template/features/projects/domain/models/explore_filters.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';

Project _project({
  DateTime? createdAt,
  Map<String, int> teamRoles = const {},
  Map<String, int> accepted = const {},
}) => Project(
  id: 'p1',
  name: 'Proyecto',
  description: '',
  categories: const [],
  teamRoles: teamRoles,
  acceptedRoleCounts: accepted,
  createdAt: createdAt,
);

void main() {
  final now = DateTime(2026, 10, 13);

  test('sin filtros, todo coincide', () {
    expect(ExploreFilters.none.isEmpty, isTrue);
    expect(
      ExploreFilters.none.matches(_project(), hasOpenTasks: false, now: now),
      isTrue,
    );
  });

  test('fecha de creación', () {
    final recent = _project(createdAt: now.subtract(const Duration(days: 3)));
    final month = _project(createdAt: now.subtract(const Duration(days: 20)));
    final old = _project(createdAt: now.subtract(const Duration(days: 90)));
    final noDate = _project();

    const last7 = ExploreFilters(creationDate: CreationDateFilter.last7Days);
    const last30 = ExploreFilters(creationDate: CreationDateFilter.last30Days);
    const older = ExploreFilters(creationDate: CreationDateFilter.older);

    expect(last7.matches(recent, hasOpenTasks: false, now: now), isTrue);
    expect(last7.matches(month, hasOpenTasks: false, now: now), isFalse);
    expect(last30.matches(month, hasOpenTasks: false, now: now), isTrue);
    expect(last30.matches(old, hasOpenTasks: false, now: now), isFalse);
    expect(older.matches(old, hasOpenTasks: false, now: now), isTrue);
    expect(older.matches(noDate, hasOpenTasks: false, now: now), isTrue);
    expect(older.matches(recent, hasOpenTasks: false, now: now), isFalse);
  });

  test('disponibilidad de tareas', () {
    const withTasks = ExploreFilters(
      taskAvailability: TaskAvailabilityFilter.withOpenTasks,
    );
    const withoutTasks = ExploreFilters(
      taskAvailability: TaskAvailabilityFilter.withoutOpenTasks,
    );
    expect(withTasks.matches(_project(), hasOpenTasks: true, now: now), isTrue);
    expect(withTasks.matches(_project(), hasOpenTasks: false, now: now), isFalse);
    expect(withoutTasks.matches(_project(), hasOpenTasks: false, now: now), isTrue);
  });

  test('rol y disponibilidad de miembros se combinan', () {
    final project = _project(
      teamRoles: {'Diseñador/a': 1, 'Desarrollador/a': 2},
      accepted: {'Diseñador/a': 1},
    );
    final designer = const ExploreFilters().toggleRole(
      ProjectRoleFilter.designer,
    );

    expect(designer.matches(project, hasOpenTasks: false, now: now), isTrue);
    expect(
      designer
          .copyWith(memberAvailability: MemberAvailabilityFilter.withOpenSpots)
          .matches(project, hasOpenTasks: false, now: now),
      isFalse,
    );
    expect(
      const ExploreFilters(
        memberAvailability: MemberAvailabilityFilter.withOpenSpots,
      ).toggleRole(ProjectRoleFilter.developer).matches(
        project,
        hasOpenTasks: false,
        now: now,
      ),
      isTrue,
    );
    expect(
      const ExploreFilters()
          .toggleRole(ProjectRoleFilter.leader)
          .matches(project, hasOpenTasks: false, now: now),
      isFalse,
    );
  });

  test('"Otros" agrupa roles que no son los cuatro fijos', () {
    final project = _project(teamRoles: {'Investigador/a': 1});
    final others = const ExploreFilters().toggleRole(ProjectRoleFilter.other);
    expect(others.matches(project, hasOpenTasks: false, now: now), isTrue);
    expect(others.activeCount, 1);
  });
}
