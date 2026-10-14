/// Nivel de "Compromiso en la plataforma".
enum CommitmentLevel { newcomer, low, medium, high }

/// "Resumen de trayectoria" (Página 5.1): evidencia de la participación del
/// usuario para que otros valoren su confiabilidad. Dart puro: recibe los
/// conteos ya leídos de Roble y calcula los indicadores.
class TrajectorySummary {
  const TrajectorySummary({
    required this.projectsCreated,
    required this.projectsCompleted,
    required this.tasksAssigned,
    required this.tasksCompleted,
    required this.participations,
    required this.comments,
    required this.requestsSent,
    required this.requestsAccepted,
  });

  static const empty = TrajectorySummary(
    projectsCreated: 0,
    projectsCompleted: 0,
    tasksAssigned: 0,
    tasksCompleted: 0,
    participations: 0,
    comments: 0,
    requestsSent: 0,
    requestsAccepted: 0,
  );

  /// Proyectos que creó (y que cuentan para quien mira).
  final int projectsCreated;

  /// Proyectos (creados o en los que participa) con todas sus tareas
  /// completadas.
  final int projectsCompleted;

  /// Tareas en las que fue aceptado.
  final int tasksAssigned;

  /// De esas, las que el creador marcó como completadas.
  final int tasksCompleted;

  /// Proyectos ajenos en los que es miembro.
  final int participations;

  final int comments;

  /// Solicitudes para participar que envió.
  final int requestsSent;

  /// Solicitudes que le aceptaron (participaciones registradas).
  final int requestsAccepted;

  static double _clamp(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);

  /// "Colaboración": participa, crea y comenta (10 puntos = 100 %).
  double get collaboration =>
      _clamp((participations * 2 + projectsCreated * 2 + comments) / 10);

  /// "Cumplimiento": tareas completadas de las que le asignaron.
  double get fulfillment =>
      tasksAssigned == 0 ? 0 : _clamp(tasksCompleted / tasksAssigned);

  /// "Calidad de aportes": cuántas de sus solicitudes fueron aceptadas.
  double get quality =>
      requestsSent == 0 ? 0 : _clamp(requestsAccepted / requestsSent);

  bool get hasActivity =>
      projectsCreated + participations + comments + tasksAssigned +
          requestsSent >
      0;

  CommitmentLevel get commitment {
    if (!hasActivity) return CommitmentLevel.newcomer;
    final average = (collaboration + fulfillment + quality) / 3;
    if (average >= 0.6) return CommitmentLevel.high;
    if (average >= 0.3) return CommitmentLevel.medium;
    return CommitmentLevel.low;
  }
}
