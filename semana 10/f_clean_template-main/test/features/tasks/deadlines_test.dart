import 'package:flutter_test/flutter_test.dart';

import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/core/utils/date_format.dart';
import 'package:f_clean_template/core/utils/deadline.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';

void main() {
  final deadline = DateTime(2026, 10, 25);

  test('la fecha límite incluye todo ese día', () {
    expect(isBeforeDeadline(deadline, DateTime(2026, 10, 25, 23, 59)), isTrue);
    expect(isBeforeDeadline(deadline, DateTime(2026, 10, 26)), isFalse);
    expect(isBeforeDeadline(null, DateTime(2030)), isTrue);
  });

  test('estado y postulación de una tarea', () {
    final task = ProjectTask(
      id: 't1',
      projectId: 'p1',
      title: 'Diseñar interfaz',
      deadline: deadline,
    );
    final before = DateTime(2026, 10, 20);
    final after = DateTime(2026, 10, 27);

    expect(task.canApplyAt(before), isTrue);
    expect(task.displayStatusAt(before), TaskDisplayStatus.available);
    expect(task.canApplyAt(after), isFalse);
    expect(task.displayStatusAt(after), TaskDisplayStatus.closed);

    final full = task.copyWith(numberAccepted: 1);
    expect(full.displayStatusAt(before), TaskDisplayStatus.inProgress);
    expect(full.canApplyAt(before), isFalse);

    final done = task.copyWith(progress: TaskProgress.completed);
    expect(done.displayStatusAt(before), TaskDisplayStatus.completed);
    expect(done.canApplyAt(before), isFalse);
  });

  test('convocatoria del equipo', () {
    final project = Project(
      id: 'p1',
      name: 'Plataforma de tutorías',
      description: '',
      categories: const [],
      teamDeadline: deadline,
    );
    expect(project.isTeamCallOpenAt(DateTime(2026, 10, 25, 12)), isTrue);
    expect(project.isTeamCallOpenAt(DateTime(2026, 10, 26, 0, 1)), isFalse);
  });

  test('fechas sin hora en Roble y formato corto', () {
    expect(RobleRows.dayIso(DateTime(2026, 10, 5)), '2026-10-05');
    expect(RobleRows.day('2026-10-05'), DateTime(2026, 10, 5));
    expect(RobleRows.day('2026-10-05T00:00:00.000Z'), DateTime(2026, 10, 5));
    expect(RobleRows.day(null), isNull);
    expect(formatShortDate(DateTime(2026, 10, 25)), '25 oct 2026');
  });
}
