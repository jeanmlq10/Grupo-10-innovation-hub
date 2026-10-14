import 'package:flutter_test/flutter_test.dart';

import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_preference.dart';

void main() {
  test('cada tipo cae en su categoría de filtro', () {
    expect(
      NotificationCategory.ofType(AppNotificationType.newRequest),
      NotificationCategory.participationRequests,
    );
    expect(
      NotificationCategory.ofType(AppNotificationType.taskApplicationRejected),
      NotificationCategory.taskApplications,
    );
    expect(
      NotificationCategory.ofType(AppNotificationType.taskCompleted),
      NotificationCategory.completedTasks,
    );
    expect(
      NotificationCategory.ofType(AppNotificationType.newComment),
      NotificationCategory.comments,
    );
  });

  test('preferencias apagadas ocultan sus categorías', () {
    final muted = NotificationPreference.mutedCategories(
      allEnabled: true,
      mutedKeys: {NotificationPreference.comments.key},
    );
    expect(muted, {NotificationCategory.comments});
    expect(
      NotificationPreference.mutedCategories(allEnabled: false, mutedKeys: {}),
      NotificationCategory.values.toSet(),
    );
  });
}
