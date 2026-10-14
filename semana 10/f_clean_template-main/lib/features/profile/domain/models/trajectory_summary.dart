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

  final int projectsCreated;

  final int projectsCompleted;

  final int tasksAssigned;

  final int tasksCompleted;

  final int participations;

  final int comments;

  final int requestsSent;

  final int requestsAccepted;

  static double _clamp(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);

  double get collaboration =>
      _clamp((participations * 2 + projectsCreated * 2 + comments) / 10);

  double get fulfillment =>
      tasksAssigned == 0 ? 0 : _clamp(tasksCompleted / tasksAssigned);

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
