/// Los nombres de ruta. Constantes y no cadenas sueltas.
abstract class AppRoutes {
  /// Restaura la sesion: con sesion va a Home, sin sesion a Bienvenido.
  static const central = '/';

  /// Explorar proyectos.
  static const home = '/home';

  /// Mis proyectos / Mis borradores.
  static const myProjects = '/mis-proyectos';

  /// Notificaciones (pestaña de la barra inferior).
  static const notifications = '/notificaciones';

  /// Mi perfil (pestaña de la barra inferior).
  static const profile = '/perfil';
}
