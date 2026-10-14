import 'package:f_clean_template/core/utils/deadline.dart';

/// A project shown in "Explorar proyectos".
///
/// Two very different kinds of [Project] exist:
/// - **Example/seed projects** (if any are added later) — hardcoded in
///   `LocalProjectSource`, always [canApply] = false.
/// - **User-created projects** — the SAME entity that started life in
///   the "Crear proyecto" wizard and was published from there. These are
///   the only ones with [canApply] = true, and the only ones carrying a
///   real [teamRoles]/[duration]/[audience]/[isDraft]/[acceptedMembersCount].
///
/// This one class is intentionally shared by both cases (see
/// the feature folders) instead of inventing a second "user
/// project" model — the whole point of this stage is that a project
/// created by the user is the SAME object everywhere it's shown
/// (Explorar, Mis proyectos, Ver proyecto), never a per-screen copy.
class Project {
  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    this.canApply = false,
    this.teamRoles = const {},
    this.duration,
    this.audience,
    this.isDraft = false,
    this.acceptedMembersCount = 0,
    this.acceptedRoleCounts = const {},
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
    this.teamDeadline,
  });

  final String id;
  final String name;
  final String description;
  final List<String> categories;

  /// Whether "Opciones del proyecto" should show on this project's detail
  /// screen. Always `false` for the hardcoded example projects; always
  /// `true` for anything that came out of "Crear proyecto".
  final bool canApply;

  /// Role name → how many are needed (e.g. `{'Diseñador/a': 1}`), set by
  /// the creator in "Equipo necesario". Empty for example projects —
  /// their "Tareas" tab simply has nothing to show.
  final Map<String, int> teamRoles;

  final String? duration;
  final String? audience;

  /// `true` while still being built in the wizard (shows under "Mis
  /// borradores"); `false` once "Publicar proyecto" was pressed (shows
  /// in "Mis proyectos" and "Explorar proyectos"). Always `false` for
  /// example projects.
  final bool isDraft;

  /// How many people have actually joined the team so far (a
  /// participation request that got accepted) — separate from
  /// [teamRoles], which is how many the creator is still looking for.
  /// Starts at 0 and grows only through
  /// `the feature repositories.acceptRequest`.
  final int acceptedMembersCount;

  /// Role name → people already accepted in that role (Roble column
  /// `acceptedRoleCounts`). Together with [teamRoles] (people needed) it
  /// tells which team roles still have free spots.
  final Map<String, int> acceptedRoleCounts;
  /// Roble userId of the creator (the row's `_owner` for Roble projects).
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// "Fecha límite para postularse al equipo" (columna `teamDeadline`).
  /// null = la convocatoria no tiene fecha límite.
  final DateTime? teamDeadline;

  /// La convocatoria para unirse al equipo sigue abierta (no venció).
  bool isTeamCallOpenAt([DateTime? now]) => isBeforeDeadline(teamDeadline, now);

  /// Visible in "Explorar proyectos": published to the whole community.
  bool get isPublic => !isDraft && audience == 'Toda la comunidad';

  Project copyWith({
    String? name,
    String? description,
    List<String>? categories,
    bool? canApply,
    Map<String, int>? teamRoles,
    String? duration,
    String? audience,
    bool? isDraft,
    int? acceptedMembersCount,
    Map<String, int>? acceptedRoleCounts,
    String? createdBy,
    String? createdByName,
    DateTime? updatedAt,
    DateTime? teamDeadline,
  }) => Project(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    categories: categories ?? this.categories,
    canApply: canApply ?? this.canApply,
    teamRoles: teamRoles ?? this.teamRoles,
    duration: duration ?? this.duration,
    audience: audience ?? this.audience,
    isDraft: isDraft ?? this.isDraft,
    acceptedMembersCount: acceptedMembersCount ?? this.acceptedMembersCount,
    acceptedRoleCounts: acceptedRoleCounts ?? this.acceptedRoleCounts,
    createdBy: createdBy ?? this.createdBy,
    createdByName: createdByName ?? this.createdByName,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    teamDeadline: teamDeadline ?? this.teamDeadline,
  );

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] ?? '0',
    name: json['name'] ?? '---',
    description: json['description'] ?? '',
    categories:
        (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    canApply: json['canApply'] ?? false,
    teamRoles:
        (json['teamRoles'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int),
        ) ??
        const {},
    duration: json['duration'],
    audience: json['audience'],
    isDraft: json['isDraft'] ?? false,
    acceptedMembersCount: json['acceptedMembersCount'] ?? 0,
    createdBy: json['createdBy'],
    createdByName: json['createdByName'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categories': categories,
    'canApply': canApply,
    'teamRoles': teamRoles,
    'duration': duration,
    'audience': audience,
    'isDraft': isDraft,
    'acceptedMembersCount': acceptedMembersCount,
    'createdBy': createdBy,
    'createdByName': createdByName,
  };

  @override
  String toString() => 'Project{id: $id, name: $name}';
}
