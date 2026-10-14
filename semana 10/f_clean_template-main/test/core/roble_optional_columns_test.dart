import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart' show RobleApiHttpException;

import 'package:f_clean_template/core/roble/roble_optional_columns.dart';

void main() {
  test('reintenta sin las columnas nuevas que Roble no tiene', () async {
    final sent = <Map<String, dynamic>>[];
    final result = await RobleOptionalColumns.write(
      {'name': 'Proyecto', 'teamDeadline': '2026-10-30', 'createdAt': 'x'},
      (row) async {
        sent.add(row);
        if (row.containsKey('teamDeadline')) {
          throw RobleApiHttpException(
            400,
            'Columnas inválidas: teamDeadline, createdAt',
          );
        }
        return row;
      },
      optional: {'teamDeadline', 'createdAt'},
    );
    expect(sent, hasLength(2));
    expect(result, {'name': 'Proyecto'});
  });

  test('no oculta errores de columnas de siempre', () async {
    expect(
      () => RobleOptionalColumns.write(
        {'nombre': 'x'},
        (row) async => throw RobleApiHttpException(
          400,
          'Columnas inválidas: nombre',
        ),
        optional: {'deadline'},
      ),
      throwsA(isA<RobleApiHttpException>()),
    );
  });

  test('entiende el mensaje de Roble al actualizar', () {
    expect(
      RobleOptionalColumns.invalidColumns(
        'La columna "teamDeadline" no existe en la tabla.',
      ),
      {'teamDeadline'},
    );
    expect(
      RobleOptionalColumns.invalidColumns('Columnas inválidas: deadline, status'),
      {'deadline', 'status'},
    );
  });
}
