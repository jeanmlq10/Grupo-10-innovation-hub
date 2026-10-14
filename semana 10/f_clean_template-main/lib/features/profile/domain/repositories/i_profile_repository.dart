import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';

/// Perfiles de usuario (tabla `user_profiles`).
abstract class IProfileRepository {
  Future<UserProfile?> byUserId(String userId);

  Future<UserProfile> save(UserProfile profile);

  Future<void> delete(UserProfile profile);
}
