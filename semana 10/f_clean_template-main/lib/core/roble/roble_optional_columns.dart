import 'package:roble/roble.dart' show RobleApiException;

/// Escritura tolerante a columnas que todavía no existen en Roble.
///
/// Las columnas nuevas (`createdAt`, `teamDeadline`, `deadline`, `status`)
/// hay que crearlas en la consola de Roble. Si alguna falta, Roble responde
/// `400 "Columnas inválidas: a, b"` y NADA se guarda. Para que crear un
/// proyecto no se rompa por eso, se reintenta UNA vez sin esas columnas (y se
/// recuerda para no volver a mandarlas en esta sesión). El resto de la fila
/// se guarda normal; solo esos datos nuevos se pierden hasta crear la columna.
///
/// Solo quita columnas de [optional]: si Roble se queja de una columna
/// "de siempre", el error sale tal cual.
abstract final class RobleOptionalColumns {
  static final Set<String> _missing = {};

  /// Columnas que Roble rechazó en esta sesión (para depurar).
  static Set<String> get missing => Set.unmodifiable(_missing);

  static Future<T> write<T>(
    Map<String, dynamic> row,
    Future<T> Function(Map<String, dynamic> row) send, {
    required Set<String> optional,
  }) async {
    // Roble puede quejarse de una columna a la vez: se reintenta hasta
    // quitar todas las opcionales que falten (como máximo una vez cada una).
    for (var attempt = 0; ; attempt++) {
      try {
        return await send(_withoutMissing(row));
      } on RobleApiException catch (e) {
        final invalid = invalidColumns(e.message);
        final removable = invalid.intersection(optional).difference(_missing);
        if (attempt >= optional.length ||
            removable.isEmpty ||
            removable.length != invalid.length) {
          rethrow;
        }
        _missing.addAll(removable);
      }
    }
  }

  static Map<String, dynamic> _withoutMissing(Map<String, dynamic> row) =>
      Map<String, dynamic>.from(row)
        ..removeWhere((key, _) => _missing.contains(key));

  /// Las columnas de las que se queja Roble. Entiende los dos mensajes que
  /// usa:
  /// - al crear:      `Columnas inválidas: teamDeadline, createdAt`
  /// - al actualizar: `La columna "teamDeadline" no existe en la tabla.`
  static Set<String> invalidColumns(String message) {
    final text = message.replaceAll(RegExp(r'[\[\]]'), '');
    final lower = text.toLowerCase();

    final quoted = RegExp('["\u201C\u201D\'`]([A-Za-z_][A-Za-z0-9_]*)["\u201C\u201D\'`]');
    if (lower.contains('columna') && lower.contains('no existe')) {
      return quoted.allMatches(text).map((m) => m.group(1)!).toSet();
    }

    final index = lower.indexOf('columnas inv');
    if (index < 0) return const {};
    final colon = text.indexOf(':', index);
    if (colon < 0) return const {};
    return text
        .substring(colon + 1)
        .split(',')
        .map((c) => c.trim().replaceAll(RegExp('["\'`.]'), ''))
        .where((c) => c.isNotEmpty)
        .toSet();
  }
}
