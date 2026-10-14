import 'package:roble/roble.dart' show RobleApiException;

/// Escritura tolerante a columnas que todavía no existen en Roble.
abstract final class RobleOptionalColumns {
  static final Set<String> _missing = {};

  static Set<String> get missing => Set.unmodifiable(_missing);

  static Future<T> write<T>(
    Map<String, dynamic> row,
    Future<T> Function(Map<String, dynamic> row) send, {
    required Set<String> optional,
  }) async {
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
