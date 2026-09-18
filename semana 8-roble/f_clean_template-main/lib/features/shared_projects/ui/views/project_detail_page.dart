import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';
import 'choose_participation_page.dart';
import '../../../create_project/ui/views/create_project_page.dart';

/// "Ver proyecto" — opened by tapping any card in "Explorar proyectos"
/// (example or user-created) or via "Ver mi proyecto" right after
/// publishing. Renders whatever [Project] it's given; the only branch
/// tied to *which kind* of project it is is `project.canApply`, which
/// decides whether "Opciones del proyecto" shows at the bottom.
///
/// No Figma reference was provided for this screen, so its layout
/// (header card + tabs) follows the same visual language already
/// established elsewhere (colors, spacing, chip/button styles) rather
/// than a specific mock.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: IconButton(
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: HomeColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEFE1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: Color(0xFF3E8E5C),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name.isEmpty ? '(Sin nombre)' : project.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description.isEmpty
                              ? 'Sin descripción todavía.'
                              : project.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: HomeColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: HomeColors.primaryPurple,
              unselectedLabelColor: HomeColors.textSecondary,
              indicatorColor: HomeColors.primaryPurple,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              tabs: const [
                Tab(text: 'Descripción'),
                Tab(text: 'Tareas'),
                Tab(text: 'Miembros'),
                Tab(text: 'Actividad'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DescriptionTab(project: project),
                  _TasksTab(project: project),
                  _MembersTab(project: project),
                  const _EmptyTab(message: 'Todavía no hay actividad.'),
                ],
              ),
            ),
            if (project.audience == 'Solo yo')
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.to(
                      () => CreateProjectPage(editProjectId: project.id),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Editar proyecto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else if (project.canApply)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.to(() => ChooseParticipationPage(project: project)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Opciones del proyecto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({required this.project});

  final Project project;

  int get _membersNeeded =>
      project.teamRoles.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description.isEmpty
                ? 'Este proyecto todavía no tiene descripción.'
                : project.description,
            style: const TextStyle(
              fontSize: 14,
              color: HomeColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.groups_outlined,
                label: '$_membersNeeded miembros necesarios',
              ),
              if (project.duration != null)
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: project.duration!,
                ),
              if (project.audience != null)
                _InfoChip(
                  icon: Icons.visibility_outlined,
                  label: project.audience!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final roles = project.teamRoles.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (roles.isEmpty) {
      return const _EmptyTab(
        message: 'Este proyecto no especificó tareas todavía.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (final entry in roles)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: HomeColors.borderGrey),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.task_alt_outlined,
                    color: HomeColors.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Se necesitan ${entry.value}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final accepted = Get.find<ISharedProjectsRepository>()
        .requestsFor(project.id)
        .where((request) => request.status == RequestStatus.accepted)
        .toList();

    if (accepted.isEmpty) {
      return const _EmptyTab(message: 'Todavía no hay miembros.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (final request in accepted)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: HomeColors.borderGrey),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: HomeColors.navSelectedBackground,
                    child: Icon(
                      Icons.person,
                      color: HomeColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.applicantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        Text(
                          request.role,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: HomeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: HomeColors.textSecondary),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HomeColors.surfaceGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: HomeColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: HomeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
