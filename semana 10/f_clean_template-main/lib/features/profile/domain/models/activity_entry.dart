/// Tipos de registro del "Historial de actividad" (Página 5.2).
enum ActivityKind { publication, participation, taskAssignment, comment, follow }

/// Una acción del usuario y el proyecto relacionado. Los textos ("Publicaste
/// un nuevo proyecto"...) los pone la vista según [kind].
class ActivityEntry {
  const ActivityEntry({
    required this.kind,
    required this.projectId,
    required this.projectName,
    this.date,
    this.detail,
  });

  final ActivityKind kind;
  final String projectId;
  final String projectName;
  final DateTime? date;

  /// Rol o tarea (participaciones) o el texto del comentario.
  final String? detail;
}
