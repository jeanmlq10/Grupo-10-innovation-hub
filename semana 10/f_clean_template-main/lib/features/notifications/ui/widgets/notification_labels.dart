import 'package:flutter/material.dart';

import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';

/// Textos e iconos de las notificaciones (la vista; el dominio no sabe de
/// textos ni de iconos).
abstract final class NotificationLabels {
  static String category(NotificationCategory category) => switch (category) {
    NotificationCategory.participationRequests => 'Solicitudes de participación',
    NotificationCategory.taskApplications => 'Postulaciones a tareas',
    NotificationCategory.completedTasks => 'Tareas completadas',
    NotificationCategory.comments => 'Comentarios en tareas',
    NotificationCategory.messages => 'Nuevos mensajes',
    NotificationCategory.mentions => 'Menciones',
    NotificationCategory.platformNews => 'Novedades de la plataforma',
    NotificationCategory.reminders => 'Recordatorios',
  };

  static String shortCategory(NotificationCategory category) =>
      switch (category) {
        NotificationCategory.participationRequests => 'Solicitudes',
        NotificationCategory.taskApplications => 'Postulaciones',
        NotificationCategory.completedTasks => 'Completadas',
        NotificationCategory.comments => 'Comentarios',
        NotificationCategory.messages => 'Mensajes',
        NotificationCategory.mentions => 'Menciones',
        NotificationCategory.platformNews => 'Novedades',
        NotificationCategory.reminders => 'Recordatorios',
      };

  static IconData categoryIcon(NotificationCategory category) =>
      switch (category) {
        NotificationCategory.participationRequests => Icons.person_outline,
        NotificationCategory.taskApplications => Icons.check_box_outlined,
        NotificationCategory.completedTasks => Icons.task_alt,
        NotificationCategory.comments => Icons.chat_bubble_outline,
        NotificationCategory.messages => Icons.mail_outline,
        NotificationCategory.mentions => Icons.alternate_email,
        NotificationCategory.platformNews => Icons.info_outline,
        NotificationCategory.reminders => Icons.alarm,
      };

  static IconData typeIcon(String type) => switch (type) {
    AppNotificationType.requestAccepted ||
    AppNotificationType.taskApplicationAccepted => Icons.check_box_outlined,
    AppNotificationType.requestRejected ||
    AppNotificationType.taskApplicationRejected => Icons.highlight_off,
    AppNotificationType.newComment => Icons.chat_bubble_outline,
    AppNotificationType.taskCompleted => Icons.task_alt,
    AppNotificationType.newMessage => Icons.mail_outline,
    AppNotificationType.taskApplication => Icons.assignment_ind_outlined,
    _ => Icons.person_add_alt_1_outlined,
  };

  static bool isNegative(String type) =>
      type == AppNotificationType.requestRejected ||
      type == AppNotificationType.taskApplicationRejected;
}
