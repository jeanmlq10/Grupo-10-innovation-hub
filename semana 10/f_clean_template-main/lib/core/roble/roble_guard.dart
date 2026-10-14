import 'package:roble/roble.dart';

/// Traduce las excepciones del paquete `roble` al Failure de cada feature.
Future<T> robleGuard<T>(
  Future<T> Function() action,
  Exception Function(String message) failure, {
  String? notFound,
}) async {
  try {
    return await action();
  } on RobleApiHttpException catch (e) {
    if (e.statusCode == 404 && notFound != null) throw failure(notFound);
    if (e.statusCode == 403) throw failure('Tu cuenta no tiene permiso para hacer esto.');
    throw failure(e.message.isEmpty ? 'Roble no pudo procesar la solicitud.' : e.message);
  } on RobleApiException catch (e) {
    throw failure(e.message);
  } on StateError catch (e) {
    throw failure(e.message);
  }
}
