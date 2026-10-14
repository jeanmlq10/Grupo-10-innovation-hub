/// "Hace 2 h", "Hace 1 día"... como en el diseño de notificaciones.
String timeAgo(DateTime date, [DateTime? now]) {
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return 'Justo ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  final days = diff.inDays;
  return days == 1 ? 'Hace 1 día' : 'Hace $days días';
}
