import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_optional_columns.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/notifications/data/datasources/i_notification_data_source.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/notification_failure.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';

/// Notificaciones: convierte filas y traduce errores.
class NotificationRepository implements INotificationRepository {
  NotificationRepository(this._source);

  final INotificationDataSource _source;

  static const _optionalColumns = {'actorUserId', 'actorName', 'detail'};

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, NotificationFailure.new);

  @override
  Future<List<AppNotification>> forUser(String userId) async {
    final rows = await _guard(() => _source.readForRecipient(userId));
    return rows.map(_toNotification).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> send({
    required String recipientUserId,
    required String type,
    required String title,
    required String message,
    required String projectId,
    String? requestId,
    String? actorUserId,
    String? actorName,
    String? detail,
  }) async {
    await _guard(
      () => RobleOptionalColumns.write(
        {
          'recipientUserId': recipientUserId,
          'projectId': projectId,
          'requestId': requestId,
          'type': type,
          'title': title,
          'message': message,
          'read': false,
          'createdAt': RobleRows.nowIso(),
          'actorUserId': actorUserId,
          'actorName': actorName,
          'detail': detail,
        },
        _source.create,
        optional: _optionalColumns,
      ),
    );
  }

  @override
  Future<void> markRead(String id) async {
    await _guard(() => _source.update(id, {'read': true}));
  }

  AppNotification _toNotification(Map<String, dynamic> row) => AppNotification(
    id: RobleRows.str(row['_id']),
    recipientUserId: RobleRows.strOrNull(row['recipientUserId']),
    projectId: RobleRows.str(row['projectId']),
    requestId: RobleRows.strOrNull(row['requestId']),
    type: RobleRows.str(row['type'], AppNotificationType.newRequest),
    title: RobleRows.str(row['title']),
    message: RobleRows.str(row['message']),
    read: RobleRows.boolean(row['read']),
    createdAt: RobleRows.date(row['createdAt']) ?? DateTime.now(),
    actorUserId: RobleRows.strOrNull(row['actorUserId']),
    actorName: RobleRows.strOrNull(row['actorName']),
    detail: RobleRows.strOrNull(row['detail']),
  );
}
