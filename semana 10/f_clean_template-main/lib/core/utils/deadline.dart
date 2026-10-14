/// Regla de las fechas límite (tareas y convocatorias): la fecha se incluye
/// completa, o sea, se puede postular hasta las 23:59 de ese día.
/// Sin fecha (`null`) = sin límite. Dart puro.
bool isBeforeDeadline(DateTime? deadline, [DateTime? now]) {
  if (deadline == null) return true;
  final endOfDay = DateTime(deadline.year, deadline.month, deadline.day + 1);
  return (now ?? DateTime.now()).isBefore(endOfDay);
}
