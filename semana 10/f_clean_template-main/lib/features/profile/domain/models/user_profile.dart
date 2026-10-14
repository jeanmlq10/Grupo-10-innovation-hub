/// Visibilidad del perfil ("Privacidad → Visibilidad del perfil").
enum ProfileVisibility { public, private }

/// "Privacidad → Quién puede contactarte".
enum ContactPermission { everyone, nobody }

/// "Privacidad → Datos de actividad": quién ve el historial y la trayectoria.
enum ActivityVisibility { onlyMe, everyone }

/// El perfil de un usuario (tabla `user_profiles`, una fila por usuario).
///
/// Si el usuario nunca editó su perfil no hay fila: se arma con los datos de
/// la sesión de Roble ([UserProfile.fromSession]) y [id] queda vacío.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    this.id = '',
    this.email = '',
    this.username = '',
    this.bio = '',
    this.career = '',
    this.visibility = ProfileVisibility.public,
    this.contact = ContactPermission.everyone,
    this.activityVisibility = ActivityVisibility.everyone,
    this.notificationsEnabled = true,
    this.mutedNotifications = const {},
    this.avatarIcon = '',
  });

  factory UserProfile.fromSession({
    required String userId,
    required String name,
    String email = '',
    String career = '',
  }) => UserProfile(
    userId: userId,
    name: name,
    email: email,
    career: career,
    username: email.contains('@') ? email.split('@').first : '',
  );

  /// `_id` de la fila en Roble ('' si todavía no existe).
  final String id;
  final String userId;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String career;
  final ProfileVisibility visibility;
  final ContactPermission contact;
  final ActivityVisibility activityVisibility;

  /// "Todas las notificaciones".
  final bool notificationsEnabled;

  /// Claves de las preferencias de notificación apagadas
  /// (ver `NotificationPreference`).
  final Set<String> mutedNotifications;

  /// Icono elegido como foto de perfil (clave del catálogo de iconos; ''
  /// = la inicial del nombre). Roble no guarda imágenes, por eso se guarda
  /// solo la clave del icono.
  final String avatarIcon;

  bool get isPublic => visibility == ProfileVisibility.public;
  bool get acceptsMessages => contact == ContactPermission.everyone;
  bool get showsActivity => activityVisibility == ActivityVisibility.everyone;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? bio,
    String? career,
    ProfileVisibility? visibility,
    ContactPermission? contact,
    ActivityVisibility? activityVisibility,
    bool? notificationsEnabled,
    Set<String>? mutedNotifications,
    String? avatarIcon,
  }) => UserProfile(
    id: id ?? this.id,
    userId: userId,
    name: name ?? this.name,
    email: email ?? this.email,
    username: username ?? this.username,
    bio: bio ?? this.bio,
    career: career ?? this.career,
    visibility: visibility ?? this.visibility,
    contact: contact ?? this.contact,
    activityVisibility: activityVisibility ?? this.activityVisibility,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    mutedNotifications: mutedNotifications ?? this.mutedNotifications,
    avatarIcon: avatarIcon ?? this.avatarIcon,
  );
}
