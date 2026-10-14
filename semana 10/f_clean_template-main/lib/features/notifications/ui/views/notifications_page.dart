import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:f_clean_template/features/messages/ui/views/chat_page.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
import 'package:f_clean_template/features/notifications/ui/views/activity_notification_page.dart';
import 'package:f_clean_template/features/notifications/ui/views/notification_filters_page.dart';
import 'package:f_clean_template/features/notifications/ui/views/request_notification_page.dart';
import 'package:f_clean_template/features/notifications/ui/views/request_result_page.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/notification_labels.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/notification_tile.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/features/requests/ui/views/requests_page.dart';
import 'package:f_clean_template/routes/app_routes.dart';

/// "Notificaciones" (Página 4.1): todas mezcladas por fecha, con búsqueda,
/// "Todas / No leídas" y filtros por tipo. Tocar una abre su detalle
/// (4.2 / 4.3) según el tipo.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  Future<void> _open(AppNotification notification) async {
    await _controller.markRead(notification);
    final type = notification.type;
    if (AppNotificationType.decidable.contains(type)) {
      await Get.to(() => RequestNotificationPage(notification: notification));
    } else if (notification.isResponse) {
      await Get.to(() => RequestResultPage(notification: notification));
    } else if (type == AppNotificationType.newComment ||
        type == AppNotificationType.taskCompleted) {
      await Get.to(() => ActivityNotificationPage(notification: notification));
    } else if (type == AppNotificationType.newMessage &&
        (notification.actorUserId ?? '').isNotEmpty) {
      await Get.to(
        () => ChatPage(
          otherUserId: notification.actorUserId!,
          otherName: notification.actorName ?? 'Usuario',
        ),
      );
    } else {
      final project = await _controller.projectById(notification.projectId);
      if (project != null) {
        await Get.to(() => ProjectDetailPage(project: project));
      }
    }
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.offNamed(AppRoutes.home),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Solicitudes recibidas',
                    onPressed: () async {
                      await Get.to(() => const RequestsPage());
                      _controller.load();
                    },
                    icon: const Icon(
                      Icons.inbox_outlined,
                      color: HomeColors.primaryPurple,
                    ),
                  ),
                  Obx(
                    () => Badge(
                      isLabelVisible: _controller.filters.isNotEmpty,
                      label: Text('${_controller.filters.length}'),
                      backgroundColor: HomeColors.primaryPurple,
                      child: IconButton(
                        tooltip: 'Filtrar notificaciones',
                        onPressed: () =>
                            Get.to(() => const NotificationFiltersPage()),
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: HomeColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: HomeColors.flowSearchFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (value) => _controller.search.value = value,
                  decoration: const InputDecoration(
                    hintText: 'Buscar notificaciones...',
                    hintStyle: TextStyle(color: HomeColors.flowSearchHint),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: HomeColors.flowSearchHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              Obx(() {
                final active = _controller.filters.toList();
                if (active.isEmpty) return const SizedBox(height: 12);
                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final category in active)
                        InputChip(
                          label: Text(
                            NotificationLabels.shortCategory(category),
                          ),
                          labelStyle: const TextStyle(
                            color: HomeColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: HomeColors.flowLavender,
                          side: BorderSide.none,
                          onDeleted: () => _controller.removeFilter(category),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              Obx(
                () => _Tabs(
                  unreadOnly: _controller.unreadOnly.value,
                  onAll: _controller.showAll,
                  onUnread: _controller.showUnread,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = _controller.visible;
                  if (items.isEmpty) {
                    final error = _controller.loadError.value;
                    return Center(
                      child: Text(
                        error.isNotEmpty
                            ? error
                            : _controller.unreadOnly.value
                            ? 'No tienes notificaciones sin leer.'
                            : 'Todavía no tienes notificaciones.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: HomeColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _controller.load,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => NotificationTile(
                        notification: items[index],
                        onTap: () => _open(items[index]),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Todas" / "No leídas".
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.unreadOnly,
    required this.onAll,
    required this.onUnread,
  });

  final bool unreadOnly;
  final VoidCallback onAll;
  final VoidCallback onUnread;

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: Material(
      color: selected ? HomeColors.flowLavender : HomeColors.flowTabGrey,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? HomeColors.primaryPurple
                    : HomeColors.flowTabText,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab('Todas', !unreadOnly, onAll),
        const SizedBox(width: 10),
        _tab('No leídas', unreadOnly, onUnread),
      ],
    );
  }
}
