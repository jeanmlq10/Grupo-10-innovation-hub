import 'dart:convert';

import 'package:roble/roble.dart';

/// Utilidades para leer filas de Roble (lo que devuelve la API).
/// Las usan los repositorios al convertir filas en entidades.
abstract final class RobleRows {
  static String str(Object? value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  static String? strOrNull(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int integer(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static bool boolean(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value == null) return fallback;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == 't' || text == '1') return true;
    if (text == 'false' || text == 'f' || text == '0') return false;
    return fallback;
  }

  static DateTime? date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  /// jsonb puede llegar ya decodificado o como texto JSON.
  static Object? json(Object? value) {
    if (value is String && value.isNotEmpty) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return null;
      }
    }
    return value;
  }

  static List<String> stringList(Object? value) {
    final decoded = json(value);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
    return const [];
  }

  static Map<String, int> intMap(Object? value) {
    final decoded = json(value);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), integer(v)));
    }
    return const {};
  }

  /// Autor de la fila: `_owner` (lo pone Roble con el token; no se puede
  /// falsificar) o, si la tabla no lo expone, la columna [fallbackColumn].
  static String? author(Map<String, dynamic> row, String fallbackColumn) =>
      robleOwnerOf(row) ?? strOrNull(row[fallbackColumn]);

  static String nowIso() => DateTime.now().toUtc().toIso8601String();

  /// Fecha SIN hora (fechas límite): se guarda como texto `AAAA-MM-DD` para
  /// que la zona horaria no la mueva de día.
  static String? dayIso(DateTime? day) {
    if (day == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${day.year.toString().padLeft(4, '0')}-${two(day.month)}-${two(day.day)}';
  }

  /// Lee una fecha límite `AAAA-MM-DD` (o un ISO completo: se toma solo el
  /// día). Devuelve la fecha local a medianoche, o null.
  static DateTime? day(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.length < 10) return null;
    final parsed = DateTime.tryParse(text.substring(0, 10));
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
