/// Un error pensado para mostrarse al usuario tal cual.
abstract class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
