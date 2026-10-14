import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_preference.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';

/// "Perfil → Notificaciones": qué avisos quiere ver el usuario. Se guarda
/// en Roble (`user_profiles`) y la bandeja de Notificaciones lo respeta.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final ProfileController _controller = Get.find();
  late bool _all;
  late Set<String> _muted;

  static const _rows = <(NotificationPreference, IconData, String)>[
    (NotificationPreference.messages, Icons.chat_bubble_outline, 'Nuevos mensajes'),
    (NotificationPreference.projectActivity, Icons.history, 'Actividad en proyectos'),
    (
      NotificationPreference.participationRequests,
      Icons.group_add_outlined,
      'Solicitudes de participación',
    ),
    (NotificationPreference.comments, Icons.mode_comment_outlined, 'Comentarios'),
    (NotificationPreference.reminders, Icons.alarm, 'Recordatorios'),
    (NotificationPreference.platformNews, Icons.campaign_outlined, 'Novedades de la plataforma'),
  ];

  @override
  void initState() {
    super.initState();
    final p = _controller.profile.value;
    _all = p?.notificationsEnabled ?? true;
    _muted = {...?p?.mutedNotifications};
  }

  Future<void> _save() async {
    await _controller.saveNotificationPrefs(enabled: _all, muted: _muted);
  }

  Widget _row(IconData icon, String title, bool value, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: HomeColors.primaryPurple),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5))),
            Switch(
              value: value,
              activeTrackColor: HomeColors.primaryPurple,
              onChanged: onChanged,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _row(Icons.notifications_none, 'Todas las notificaciones', _all, (on) {
            setState(() => _all = on);
            _save();
          }),
          for (final row in _rows)
            _row(
              row.$2,
              row.$3,
              _all && !_muted.contains(row.$1.key),
              (on) {
                setState(() {
                  if (on) {
                    _all = true;
                    _muted.remove(row.$1.key);
                  } else {
                    _muted.add(row.$1.key);
                  }
                });
                _save();
              },
            ),
        ],
      ),
    );
  }
}
