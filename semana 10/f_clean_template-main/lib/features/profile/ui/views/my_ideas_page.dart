import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/date_format.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';

/// "Mis ideas": las ideas del usuario, en borrador o publicadas.
class MyIdeasPage extends StatefulWidget {
  const MyIdeasPage({super.key});

  @override
  State<MyIdeasPage> createState() => _MyIdeasPageState();
}

class _MyIdeasPageState extends State<MyIdeasPage> {
  final ProfileController _controller = Get.find();
  bool _showDrafts = true;

  Future<void> _open(Project project) async {
    if (project.isDraft) {
      await Get.to(() => CreateProjectPage(editProjectId: project.id));
    } else {
      await Get.to(() => ProjectDetailPage(project: project));
    }
    _controller.loadMine();
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? HomeColors.flowLavender : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? HomeColors.primaryPurple : HomeColors.textSecondary,
          ),
        ),
      ),
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
          'Mis ideas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Nueva idea',
            onPressed: () async {
              await Get.to(() => const CreateProjectPage());
              _controller.loadMine();
            },
            icon: const Icon(
              Icons.add_circle,
              color: HomeColors.primaryPurple,
              size: 30,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final all = _controller.myProjects;
        final drafts = all.where((p) => p.isDraft).toList();
        final published = all.where((p) => !p.isDraft).toList();
        final list = _showDrafts ? drafts : published;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  _tab(
                    'Borradores (${drafts.length})',
                    _showDrafts,
                    () => setState(() => _showDrafts = true),
                  ),
                  const SizedBox(width: 8),
                  _tab(
                    'Publicadas (${published.length})',
                    !_showDrafts,
                    () => setState(() => _showDrafts = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _showDrafts
                            ? 'No tienes borradores.'
                            : 'Todavía no has publicado ideas.',
                        style: const TextStyle(color: HomeColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _IdeaCard(project: list[index], onTap: () => _open(list[index])),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = project.createdAt;
    final draft = project.isDraft;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: HomeColors.borderGrey),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: HomeColors.surfaceGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb_outline, color: HomeColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name.isEmpty ? 'Borrador sin nombre' : project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: draft ? const Color(0xFFFFF1DC) : const Color(0xFFE3F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      draft ? 'Borrador' : 'Publicada',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: draft ? const Color(0xFFB66A00) : const Color(0xFF1E8A4C),
                      ),
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      draft
                          ? 'Creado: ${formatShortDate(date)}'
                          : 'Publicada: ${formatShortDate(date)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HomeColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: HomeColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
