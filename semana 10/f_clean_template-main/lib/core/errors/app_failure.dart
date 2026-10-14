/// Un error pensado para mostrarse al usuario tal cual.
///
/// Cada feature tiene el suyo (`ProjectFailure`, `TaskFailure`,
/// `RequestFailure`...) que extiende de aqui. Los repositorios traducen las
/// excepciones de Roble a ese Failure, asi `domain/` y `ui/` nunca dependen
/// del paquete `roble` ni de HTTP.
abstract class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
