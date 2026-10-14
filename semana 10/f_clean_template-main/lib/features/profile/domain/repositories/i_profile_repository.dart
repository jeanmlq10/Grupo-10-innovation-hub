import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';

/// Perfiles de usuario (tabla `user_profiles`).
abstract class IProfileRepository {
  /// El perfil guardado de [userId], o null si nunca lo editó.
  Future<UserProfile?> byUserId(String userId);

  /// Crea la fila la primera vez y luego la actualiza (siempre la misma).
  Future<UserProfile> save(UserProfile profile);

  /// Borra la fila del perfil ("Eliminar cuenta").
  Future<void> delete(UserProfile profile);
}
