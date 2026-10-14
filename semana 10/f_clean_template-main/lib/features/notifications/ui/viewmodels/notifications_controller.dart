import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_preference.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';

/// ViewModel de "Notificaciones" (Página 4).
///
/// - 4.1: lista cronológica con búsqueda, "Todas / No leídas" y filtros por
///   tipo ([filters]). Lo que el usuario apagó en "Perfil → Notificaciones"
///   no se muestra.
/// - 4.2 / 4.3: abrir una notificación la marca como leída; la vista decide
///   a qué pantalla de detalle ir según su tipo.
class NotificationsController extends GetxController with UiLoggy {
  NotificationsController({
    required this.notifications,
    required this.projects,
    required this.profiles,
    required this.session,
  });

  final INotificationRepository notifications;
  final IProjectRepository projects;
  final IProfileRepository profiles;
  final AuthenticationController session;

  final RxList<AppNotification> _all = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxString loadError = ''.obs;
  final RxString search = ''.obs;

  /// `true` = pestaña "No leídas".
  final RxBool unreadOnly = false.obs;

  /// Tipos elegidos en "Filtrar notificaciones". Vacío = todos.
  final RxSet<NotificationCategory> filters = <NotificationCategory>{}.obs;

  /// Categorías apagadas en las preferencias del perfil.
  final RxSet<NotificationCategory> _muted = <NotificationCategory>{}.obs;

  /// Lo que se muestra: preferencias + pestaña + filtros + búsqueda.
  List<AppNotification> get visible {
    final query = search.value.trim().toLowerCase();
    return _all.where((n) {
      if (_muted.contains(n.category)) return false;
      if (unreadOnly.value && n.read) return false;
      if (filters.isNotEmpty && !filters.contains(n.category)) return false;
      if (query.isEmpty) return true;
      return n.title.toLowerCase().contains(query) ||
          n.message.toLowerCase().contains(query) ||
          (n.actorName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  int get unreadCount =>
      _all.where((n) => !n.read && !_muted.contains(n.category)).length;

  Future<void> load() async {
    final userId = session.loggedUser?.userId;
    if (userId == null) return;
    isLoading.value = true;
    loadError.value = '';
    try {
      final list = await notifications.forUser(userId);
      final profile = await profiles
          .byUserId(userId)
          .catchError((Object _) => null);
      _all.assignAll(list);
      _muted
        ..clear()
        ..addAll(
          profile == null
              ? const <NotificationCategory>{}
              : NotificationPreference.mutedCategories(
                  allEnabled: profile.notificationsEnabled,
                  mutedKeys: profile.mutedNotifications,
                ),
        );
    } catch (error) {
      loggy.error('NotificationsController: could not load: $error');
      loadError.value = errorMessage(
        error,
        fallback: 'No se pudieron cargar tus notificaciones.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showAll() => unreadOnly.value = false;

  void showUnread() => unreadOnly.value = true;

  /// "Aplicar filtros".
  void applyFilters(Set<NotificationCategory> categories) => filters
    ..clear()
    ..addAll(categories);

  void removeFilter(NotificationCategory category) => filters.remove(category);

  /// "Limpiar filtros".
  void clearFilters() => filters.clear();

  /// Se abre una notificación: queda leída (aquí y en Roble).
  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    final index = _all.indexWhere((n) => n.id == notification.id);
    if (index >= 0) _all[index] = notification.copyWith(read: true);
    try {
      await notifications.markRead(notification.id);
    } catch (_) {
      // No poder marcarla como leída no impide abrirla.
    }
  }

  Future<Project?> projectById(String id) => id.isEmpty
      ? Future.value(null)
      : projects.getById(id, viewerId: session.loggedUser?.userId);
}
