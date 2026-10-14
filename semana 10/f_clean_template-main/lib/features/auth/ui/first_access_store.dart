import 'package:get/get.dart';

import 'package:f_clean_template/core/storage/i_local_preferences.dart';

/// Remembers, on this device, that an account completed sign-up and email
/// verification here but has not yet seen "¿Qué quieres hacer?".
abstract final class FirstAccessStore {
  static const String _prefix = 'first_access_pending:';

  static String _key(String email) => '$_prefix${email.trim().toLowerCase()}';

  static ILocalPreferences? get _preferences =>
      Get.isRegistered<ILocalPreferences>()
      ? Get.find<ILocalPreferences>()
      : null;

  static Future<void> markPending(String email) async {
    if (email.trim().isEmpty) return;
    try {
      await _preferences?.setBool(_key(email), true);
    } catch (_) {
    }
  }

  static Future<bool> consume(String email) async {
    final preferences = _preferences;
    if (preferences == null || email.trim().isEmpty) return false;
    try {
      final pending = await preferences.getBool(_key(email)) ?? false;
      if (pending) await preferences.remove(_key(email));
      return pending;
    } catch (_) {
      return false;
    }
  }
}
