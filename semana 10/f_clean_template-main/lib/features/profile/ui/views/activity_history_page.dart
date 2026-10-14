import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/domain/models/activity_entry.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/widgets/activity_entry_tile.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';

/// "Historial de actividad" (Página 5.2), organizado por categorías.
class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final ProfileController _controller = Get.find();

  /// null = "Todos".
  Set<ActivityKind>? _kinds;

  static const _tabs = <(String, Set<ActivityKind>?)>[
    ('Todos', null),
    ('Publicaciones', {ActivityKind.publication}),
    ('Participaciones', {ActivityKind.participation, ActivityKind.taskAssignment}),
    ('Comentarios', {ActivityKind.comment}),
    ('Favoritos', <ActivityKind>{}),
    ('Seguidos', {ActivityKind.follow}),
  ];

  String _selectedLabel = 'Todos';

  Future<void> _openProject(ActivityEntry entry) async {
    final project = await _controller.projects.getById(
      entry.projectId,
      viewerId: _controller.session.loggedUser?.userId,
    );
    if (project == null) {
      Get.snackbar('Historial', 'Ese proyecto ya no está disponible.');
      return;
    }
    Get.to(() => ProjectDetailPage(project: project));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Historial de actividad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tab in _tabs)
                  ChoiceChip(
                    label: Text(tab.$1),
                    selected: _selectedLabel == tab.$1,
                    selectedColor: HomeColors.flowLavender,
                    labelStyle: TextStyle(
                      color: _selectedLabel == tab.$1
                          ? HomeColors.primaryPurple
                          : HomeColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _selectedLabel = tab.$1;
                      _kinds = tab.$2;
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final kinds = _kinds;
              final entries = kinds == null
                  ? _controller.activity.toList()
                  : _controller.activity
                        .where((e) => kinds.contains(e.kind))
                        .toList();
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    _selectedLabel == 'Favoritos'
                        ? 'Todavía no tienes favoritos.'
                        : 'Todavía no hay actividad aquí.',
                    style: const TextStyle(color: HomeColors.textSecondary),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => ActivityEntryTile(
                  entry: entries[index],
                  self: true,
                  onTap: () => _openProject(entries[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
