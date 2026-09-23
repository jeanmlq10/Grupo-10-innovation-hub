import 'package:get/get.dart';

import '../../../core/i_local_preferences.dart';

/// Remembers, on this device, that an account completed sign-up and email
/// verification here but has not yet seen "¿Qué quieres hacer?".
///
/// The normal case does not need it: when the automatic sign-in right after
/// verification works, [SignUpPage] opens "¿Qué quieres hacer?" directly,
/// because the app itself just created the account. This store only covers
/// the case where that automatic sign-in failed (network, 429) and the new
/// user has to log in by hand: the flag is written with [ILocalPreferences]
/// (the app's existing local storage) and consumed on that first login.
///
/// UI state only: nothing here talks to Roble.
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
      // Losing this flag only skips the welcome choice; never block login.
    }
  }

  /// True (once) if [email] finished sign-up here and has not seen the
  /// first-access choice yet.
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
