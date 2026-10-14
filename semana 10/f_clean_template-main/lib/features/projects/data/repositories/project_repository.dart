import 'package:roble/roble.dart'
    show RobleApiForbiddenException, RobleApiHttpException;

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_optional_columns.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/projects/data/datasources/i_project_data_source.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/models/project_team_role.dart';
import 'package:f_clean_template/features/projects/domain/project_failure.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';

/// Proyectos: decide la visibilidad, convierte filas en [Project] y traduce
/// errores a [ProjectFailure]. No habla con Roble directamente.
class ProjectRepository implements IProjectRepository {
  ProjectRepository(this._source);

  final IProjectDataSource _source;

  static const _optionalColumns = {'createdAt', 'teamDeadline'};

  Future<T> _guard<T>(Future<T> Function() action, {String? notFound}) =>
      robleGuard(action, ProjectFailure.new, notFound: notFound);

  @override
  Future<Project> create(Project project) async {
    final row = await _guard(
      () => RobleOptionalColumns.write(
        {
          ..._toRow(project),
          'createdBy': project.createdBy,
          'createdAt': RobleRows.nowIso(),
        },
        _source.create,
        optional: _optionalColumns,
      ),
    );
    return _toProject(row);
  }

  @override
  Future<Project> save(Project project) async {
    final row = await _guard(
      () => RobleOptionalColumns.write(
        _toRow(project),
        (row) => _source.update(project.id, row),
        optional: _optionalColumns,
      ),
      notFound: 'Ese proyecto no existe o no es tuyo.',
    );
    return row.isEmpty ? project : _toProject(row);
  }

  @override
  Future<void> delete(String id) async {
    await _guard(() async {
      try {
        await _source.delete(id);
      } on RobleApiHttpException catch (e) {
        if (e is RobleApiForbiddenException || e.statusCode == 403) {
          throw ProjectFailure(
            'Roble no permite borrar proyectos todavía: en la consola, '
            'Configuración → Permisos, dale al rol "user" el permiso Borrar '
            'en la tabla projects.',
          );
        }
        rethrow;
      }
    }, notFound: 'Ese proyecto no existe o no es tuyo.');
  }

  @override
  Future<Project?> getById(
    String id, {
    String? viewerId,
    bool publicAccess = false,
  }) async {
    if (id.isEmpty) return null;
    final Map<String, dynamic>? row;
    if (publicAccess) {
      final rows = await _publicRows();
      row = rows.where((r) => RobleRows.str(r['_id']) == id).firstOrNull;
    } else {
      row = await _guard(() => _source.readById(id));
    }
    if (row == null) return null;
    final project = _toProject(row);
    final visible =
        project.isPublic || (viewerId != null && project.createdBy == viewerId);
    return visible ? project : null;
  }

  @override
  Future<List<Project>> explorable({bool publicAccess = false}) async {
    final rows = publicAccess
        ? await _publicRows()
        : await _guard(_source.readAll);
    return rows.map(_toProject).where((p) => p.isPublic).toList();
  }

  @override
  Future<List<Project>> ownedBy(String userId) async {
    final rows = await _guard(_source.readAll);
    return rows.map(_toProject).where((p) => p.createdBy == userId).toList();
  }

  Future<List<Map<String, dynamic>>> _publicRows() => _guard(() async {
    try {
      return await _source.readAllPublic();
    } on RobleApiForbiddenException {
      throw ProjectFailure(
        'Los proyectos no se pueden ver sin iniciar sesión todavía: '
        'la tabla projects no es pública en Roble.',
      );
    }
  });

  @override
  List<ProjectTeamRole> rolesOf(Project project) => [
    for (final entry in project.teamRoles.entries)
      if (entry.value > 0)
        ProjectTeamRole(
          id: entry.key,
          projectId: project.id,
          role: entry.key,
          numberNeeded: entry.value,
          numberAccepted: project.acceptedRoleCounts[entry.key] ?? 0,
          status: (project.acceptedRoleCounts[entry.key] ?? 0) >= entry.value
              ? 'closed'
              : 'open',
        ),
  ];

  Map<String, dynamic> _toRow(Project p) => {
    'name': p.name,
    'description': p.description,
    'categories': p.categories,
    'canApply': p.canApply,
    'teamRoles': p.teamRoles,
    'acceptedRoleCounts': p.acceptedRoleCounts,
    'duration': p.duration,
    'audience': p.audience,
    'isDraft': p.isDraft,
    'acceptedMembersCount': p.acceptedMembersCount,
    'createdByName': p.createdByName,
    'teamDeadline': RobleRows.dayIso(p.teamDeadline),
  };

  Project _toProject(Map<String, dynamic> row) => Project(
    id: RobleRows.str(row['_id']),
    name: RobleRows.str(row['name']),
    description: RobleRows.str(row['description']),
    categories: RobleRows.stringList(row['categories']),
    canApply: RobleRows.boolean(row['canApply'], fallback: true),
    teamRoles: RobleRows.intMap(row['teamRoles']),
    acceptedRoleCounts: RobleRows.intMap(row['acceptedRoleCounts']),
    duration: RobleRows.strOrNull(row['duration']),
    audience: RobleRows.strOrNull(row['audience']),
    isDraft: RobleRows.boolean(row['isDraft'], fallback: true),
    acceptedMembersCount: RobleRows.integer(row['acceptedMembersCount']),
    createdBy: RobleRows.author(row, 'createdBy'),
    createdByName: RobleRows.strOrNull(row['createdByName']),
    createdAt: RobleRows.date(row['createdAt']),
    teamDeadline: RobleRows.day(row['teamDeadline']),
  );
}
