/// The data collected so far while a user is going through the
/// "Crear proyecto" wizard (Nueva idea → Información básica → Equipo
/// necesario → Tiempo estimado → Audiencia → Revisar y publicar).
class NewProjectDraft {
  const NewProjectDraft({
    this.name = '',
    this.description = '',
    this.teamRoles = const {},
    this.duration,
    this.audience,
  });

  final String name;
  final String description;

  /// Role name → how many of that role are needed (e.g. `{'Diseñador/a': 2}`).
  /// Roles never selected simply don't appear as keys.
  final Map<String, int> teamRoles;

  /// One of "Días", "Semanas", "Meses" or "Años", or `null` if the user
  /// hasn't picked one yet.
  final String? duration;

  /// One of "Solo yo" or "Toda la comunidad", or `null` if not picked yet.
  final String? audience;

  NewProjectDraft copyWith({
    String? name,
    String? description,
    Map<String, int>? teamRoles,
    String? duration,
    String? audience,
  }) => NewProjectDraft(
    name: name ?? this.name,
    description: description ?? this.description,
    teamRoles: teamRoles ?? this.teamRoles,
    duration: duration ?? this.duration,
    audience: audience ?? this.audience,
  );
}
