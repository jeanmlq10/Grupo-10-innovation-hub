import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/notifications/domain/models/notification_category.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/notification_labels.dart';

/// "Filtrar notificaciones" (Página 4.1, pantalla 2). Se edita una copia y
/// solo cambia la lista al tocar "Aplicar filtros".
class NotificationFiltersPage extends StatefulWidget {
  const NotificationFiltersPage({super.key});

  @override
  State<NotificationFiltersPage> createState() =>
      _NotificationFiltersPageState();
}

class _NotificationFiltersPageState extends State<NotificationFiltersPage> {
  final NotificationsController _controller = Get.find();
  late Set<NotificationCategory> _draft;

  @override
  void initState() {
    super.initState();
    _draft = _controller.filters.toSet();
  }

  bool get _all => _draft.isEmpty;

  void _toggle(NotificationCategory category, bool on) => setState(() {
    if (on) {
      _draft.add(category);
    } else {
      _draft.remove(category);
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtrar notificaciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  _ToggleRow(
                    icon: Icons.radio_button_unchecked,
                    title: 'Todas',
                    value: _all,
                    onChanged: (on) {
                      if (on) setState(() => _draft.clear());
                    },
                  ),
                  for (final category in NotificationCategory.values)
                    _ToggleRow(
                      icon: NotificationLabels.categoryIcon(category),
                      title: NotificationLabels.category(category),
                      value: _draft.contains(category),
                      onChanged: (on) => _toggle(category, on),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        _controller.applyFilters(_draft);
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Aplicar filtros',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _draft.clear()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeColors.primaryPurple,
                        backgroundColor: HomeColors.flowLavenderFaint,
                        side: const BorderSide(color: HomeColors.flowBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Limpiar filtros'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: HomeColors.primaryPurple, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                color: HomeColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: HomeColors.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
