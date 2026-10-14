/// Formato corto de fechas en español, como en el diseño: "25 oct 2026".
/// Sin el paquete `intl`, para no agregar dependencias.
String formatShortDate(DateTime date) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
