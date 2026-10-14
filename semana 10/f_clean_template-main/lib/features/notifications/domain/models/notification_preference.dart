import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';

/// Los interruptores de "Perfil → Notificaciones". Cada uno agrupa una o
/// varias categorías de aviso. Dart puro.
enum NotificationPreference {
  messages,
  projectActivity,
  participationRequests,
  comments,
  reminders,
  platformNews;

  Set<NotificationCategory> get categories => switch (this) {
    NotificationPreference.messages => {NotificationCategory.messages},
    NotificationPreference.projectActivity => {
      NotificationCategory.completedTasks,
      NotificationCategory.mentions,
    },
    NotificationPreference.participationRequests => {
      NotificationCategory.participationRequests,
      NotificationCategory.taskApplications,
    },
    NotificationPreference.comments => {NotificationCategory.comments},
    NotificationPreference.reminders => {NotificationCategory.reminders},
    NotificationPreference.platformNews => {NotificationCategory.platformNews},
  };

  String get key => name;

  static NotificationPreference? fromKey(String key) {
    for (final value in NotificationPreference.values) {
      if (value.key == key) return value;
    }
    return null;
  }

  static Set<NotificationCategory> mutedCategories({
    required bool allEnabled,
    required Set<String> mutedKeys,
  }) {
    if (!allEnabled) return NotificationCategory.values.toSet();
    return {
      for (final key in mutedKeys)
        ...?NotificationPreference.fromKey(key)?.categories,
    };
  }
}
