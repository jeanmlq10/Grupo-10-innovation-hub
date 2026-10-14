import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/widgets/dashed_border.dart';
import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/core/utils/date_format.dart';
import 'package:f_clean_template/features/members/domain/models/project_member.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/project_detail_controller.dart';
import 'package:f_clean_template/features/comments/ui/widgets/project_comments_sheet.dart';
import 'package:f_clean_template/features/requests/ui/views/choose_participation_page.dart';
import 'package:f_clean_template/features/requests/ui/views/join_team_page.dart';
import 'package:f_clean_template/features/auth/ui/widgets/login_required_dialog.dart';

/// "Ver proyecto" — opened by tapping a project in "Explorar proyectos".
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ProjectDetailController _controller = Get.find();

  late Project _project;
  bool _isFollowing = false;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final results = await Future.wait([
        _controller.projectById(_project.id),
        _controller.isFollowing(_project.id),
      ]);
      if (!mounted) return;
      setState(() {
        final fresh = results[0] as Project?;
        if (fresh != null) _project = fresh;
        _isFollowing = results[1] as bool;
      });
    } catch (_) {
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFollow() async {
    if (!requireSession()) return;
    if (_followBusy) return;
    _followBusy = true;
    try {
      final following = await _controller.toggleFollow(_project.id);
      if (!mounted) return;
      setState(() => _isFollowing = following);
      Get.snackbar(
        following ? 'Ahora sigues este proyecto' : 'Dejaste de seguir',
        following
            ? 'Recibirás novedades de "${_project.name}".'
            : 'Ya no verás este proyecto en "Seguidos".',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        borderColor: HomeColors.borderGrey,
        borderWidth: 1,
        icon: Icon(
          following ? Icons.check_circle : Icons.notifications_off_outlined,
          color: HomeColors.primaryPurple,
        ),
      );
    } catch (error) {
      Get.snackbar(
        'Seguir proyecto',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _followBusy = false;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    final isDescription = _tabController.index == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              isFollowing: _isFollowing,
              showMore:
                  project.canApply &&
                  project.isPublic &&
                  !_controller.isOwner(project),
              onBack: Get.back,
              onFollow: _toggleFollow,
              onMore: () {
                if (!requireSession()) return;
                Get.to(() => ChooseParticipationPage(project: project));
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isDescription
                  ? _LargeProjectHeader(
                      key: const ValueKey('large-project-header'),
                      project: project,
                    )
                  : _CompactProjectHeader(
                      key: const ValueKey('compact-project-header'),
                      project: project,
                    ),
            ),
            const SizedBox(height: 10),
            _ProjectTabs(controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DescriptionTab(project: project),
                  _TasksTab(project: project),
                  _MembersTab(project: project),
                  _ActivityTab(project: project),
                ],
              ),
            ),
            if (project.audience == 'Solo yo')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.to(
                      () => CreateProjectPage(editProjectId: project.id),
                    ),
                    style: _bottomButtonStyle(),
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
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!requireSession()) return;
                      showProjectComments(context, project.id);
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 19,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Comentar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: _bottomButtonStyle(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _bottomButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: HomeColors.primaryPurple,
    foregroundColor: Colors.white,
    elevation: 1,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFollowing,
    required this.showMore,
    required this.onBack,
    required this.onFollow,
    required this.onMore,
  });

  final bool isFollowing;
  final bool showMore;
  final VoidCallback onBack;
  final VoidCallback onFollow;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(Icons.arrow_back, color: HomeColors.textPrimary),
          ),
          const Spacer(),
          Material(
            color: HomeColors.navSelectedBackground,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onFollow,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  isFollowing
                      ? Icons.notifications
                      : Icons.notifications_none,
                  color: HomeColors.primaryPurple,
                  size: 22,
                ),
              ),
            ),
          ),
          if (showMore)
            IconButton(
              tooltip: 'Más opciones',
              onPressed: onMore,
              padding: const EdgeInsets.only(left: 8),
              icon: const Icon(
                Icons.more_vert,
                color: HomeColors.textPrimary,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}

class _LargeProjectHeader extends StatelessWidget {
  const _LargeProjectHeader({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final category = project.categories.isNotEmpty
        ? project.categories.first
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 108,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEFE1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.eco_outlined,
                color: Color(0xFF3E8E5C),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            project.name.isEmpty ? '(Sin nombre)' : project.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: HomeColors.textPrimary,
            ),
          ),
          if (category != null || _membersLabel(project) != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category != null) _TagChip(label: category),
                if (_membersLabel(project) != null)
                  _TagChip(
                    icon: Icons.groups_outlined,
                    label: _membersLabel(project)!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactProjectHeader extends StatelessWidget {
  const _CompactProjectHeader({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final category = project.categories.isNotEmpty
        ? project.categories.first
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name.isEmpty ? '(Sin nombre)' : project.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (category != null) _MiniTag(label: category),
                    if (_membersLabel(project) != null)
                      _MiniTag(
                        icon: Icons.groups_outlined,
                        label: _membersLabel(project)!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTabs extends StatelessWidget {
  const _ProjectTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: false,
      labelColor: HomeColors.primaryPurple,
      unselectedLabelColor: HomeColors.textSecondary,
      indicatorColor: HomeColors.primaryPurple,
      indicatorWeight: 2.5,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      tabs: const [
        Tab(text: 'Descripción'),
        Tab(text: 'Tareas'),
        Tab(text: 'Miembros'),
        Tab(text: 'Actividad'),
      ],
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description.isEmpty
                ? 'Este proyecto todavía no tiene descripción.'
                : project.description,
            style: const TextStyle(
              fontSize: 15,
              color: HomeColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Información rápida',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (_membersNeeded > 0)
                _InfoChip(
                  icon: Icons.groups_outlined,
                  label: '$_membersNeeded miembros necesarios',
                ),
              if (project.duration != null && project.duration!.isNotEmpty)
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: project.duration!,
                ),
              if (project.audience != null &&
                  project.audience!.isNotEmpty &&
                  project.audience != 'Toda la comunidad')
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

/// Loads a tab's data from Roble every time the tab is opened.
abstract class _RobleTabState<W extends StatefulWidget, T> extends State<W> {
  late Future<T> future;

  Future<T> load();

  @override
  void initState() {
    super.initState();
    future = load();
  }

  Widget buildWith(BuildContext context, T data);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _EmptyTab(message: errorMessage(snapshot.error!));
        }
        return buildWith(context, snapshot.data as T);
      },
    );
  }
}

/// "Tareas": specific tasks of the project (table `project_tasks`).
/// Tapping one opens the request for that task.
class _TasksTab extends StatefulWidget {
  const _TasksTab({required this.project});

  final Project project;

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends _RobleTabState<_TasksTab, List<ProjectTask>> {
  final ProjectDetailController _controller = Get.find();

  @override
  Future<List<ProjectTask>> load() => _controller.tasksFor(widget.project.id);

  @override
  Widget buildWith(BuildContext context, List<ProjectTask> tasks) {
    final project = widget.project;
    final isOwner = _controller.isOwner(project);
    final canApply = project.canApply && project.isPublic && !isOwner;
    final now = DateTime.now();

    if (tasks.isEmpty) {
      return const _EmptyTab(
        message: 'Este proyecto no especificó tareas todavía.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tareas del proyecto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final task in tasks)
            _TaskCard(
              task: task,
              now: now,
              canApply: canApply && task.canApplyAt(now),
              isOwner: isOwner,
              onApply: () {
                if (!requireSession()) return;
                Get.to(() => JoinTeamPage(project: project, task: task));
              },
              onProgress: (progress) => _changeProgress(task, progress),
            ),
        ],
      ),
    );
  }

  Future<void> _changeProgress(ProjectTask task, TaskProgress progress) async {
    try {
      await _controller.setTaskProgress(widget.project, task, progress);
      if (mounted) setState(() => future = load());
    } catch (error) {
      Get.snackbar(
        'Estado de la tarea',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

/// Etiqueta de estado de una tarea ("Disponible", "En progreso"...).
class _TaskStatusBadge extends StatelessWidget {
  const _TaskStatusBadge({required this.status});

  final TaskDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      TaskDisplayStatus.available => (
        'Disponible',
        const Color(0xFFE3F5E9),
        const Color(0xFF1E8A4C),
      ),
      TaskDisplayStatus.inProgress => (
        'En progreso',
        const Color(0xFFFFF1DC),
        const Color(0xFFB66A00),
      ),
      TaskDisplayStatus.completed => (
        'Completada',
        HomeColors.navSelectedBackground,
        HomeColors.primaryPurple,
      ),
      TaskDisplayStatus.closed => (
        'Cerrada',
        HomeColors.surfaceGrey,
        HomeColors.textSecondary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// Línea con calendario: "Postulaciones hasta: 25 oct 2026".
class _DeadlineLine extends StatelessWidget {
  const _DeadlineLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_month_outlined,
          size: 15,
          color: HomeColors.primaryPurple,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: HomeColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón morado pequeño de las tarjetas ("Postularme a una tarea"...).
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: HomeColors.primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Tarjeta de una tarea en "Tareas" (Cambio 2): estado, descripción,
/// "Postulaciones hasta" y el botón para postularse. El dueño ve además un
/// menú para cambiar el estado.
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.now,
    required this.canApply,
    required this.isOwner,
    required this.onApply,
    required this.onProgress,
  });

  final ProjectTask task;
  final DateTime now;
  final bool canApply;
  final bool isOwner;
  final VoidCallback onApply;
  final ValueChanged<TaskProgress> onProgress;

  @override
  Widget build(BuildContext context) {
    final missing = task.numberNeeded - task.numberAccepted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
      decoration: BoxDecoration(
        border: Border.all(color: HomeColors.borderGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HomeColors.navSelectedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: HomeColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: HomeColors.textSecondary,
                        ),
                      ),
                    ],
                    if (missing > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Se necesitan $missing',
                        style: const TextStyle(
                          fontSize: 12,
                          color: HomeColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _TaskStatusBadge(status: task.displayStatusAt(now)),
              if (isOwner)
                PopupMenuButton<TaskProgress>(
                  tooltip: 'Cambiar estado',
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: HomeColors.textSecondary,
                  ),
                  onSelected: onProgress,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: TaskProgress.available,
                      child: Text('Marcar como disponible'),
                    ),
                    PopupMenuItem(
                      value: TaskProgress.inProgress,
                      child: Text('Marcar en progreso'),
                    ),
                    PopupMenuItem(
                      value: TaskProgress.completed,
                      child: Text('Marcar como completada'),
                    ),
                  ],
                ),
            ],
          ),
          if (task.deadline != null) ...[
            const SizedBox(height: 10),
            _DeadlineLine(
              text: 'Postulaciones hasta: ${formatShortDate(task.deadline!)}',
            ),
          ],
          if (canApply) ...[
            const SizedBox(height: 10),
            _CardActionButton(
              label: 'Postularme a una tarea',
              onPressed: onApply,
            ),
          ],
        ],
      ),
    );
  }
}

/// Un rol que el proyecto busca, con su convocatoria (Cambio 2).
class _RoleCallCard extends StatelessWidget {
  const _RoleCallCard({
    required this.role,
    required this.missing,
    required this.deadline,
    required this.callOpen,
    required this.canJoin,
    required this.onJoin,
  });

  final String role;
  final int missing;
  final DateTime? deadline;
  final bool callOpen;
  final bool canJoin;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final String deadlineText;
    if (!callOpen) {
      deadlineText = 'Convocatoria cerrada';
    } else if (deadline != null) {
      deadlineText = 'Convocatoria abierta hasta: ${formatShortDate(deadline!)}';
    } else {
      deadlineText = 'Convocatoria abierta';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        border: Border.all(color: HomeColors.borderGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HomeColors.navSelectedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: HomeColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                    Text(
                      missing == 1 ? '1 miembro' : '$missing miembros',
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
          const SizedBox(height: 10),
          _DeadlineLine(text: deadlineText),
          if (canJoin) ...[
            const SizedBox(height: 10),
            _CardActionButton(label: 'Unirme al equipo', onPressed: onJoin),
          ],
        ],
      ),
    );
  }
}

/// "Miembros": real members (table `project_members`).
class _MembersTab extends StatefulWidget {
  const _MembersTab({required this.project});

  final Project project;

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState
    extends _RobleTabState<_MembersTab, List<ProjectMember>> {
  final ProjectDetailController _controller = Get.find();

  @override
  Future<List<ProjectMember>> load() =>
      _controller.membersFor(widget.project.id);

  @override
  Widget buildWith(BuildContext context, List<ProjectMember> members) {
    final project = widget.project;
    final canJoin =
        project.canApply &&
        project.isPublic &&
        !_controller.isOwner(project) &&
        project.isTeamCallOpenAt();
    final openRoles = <MapEntry<String, int>>[
      for (final entry in project.teamRoles.entries)
        if (entry.value - (project.acceptedRoleCounts[entry.key] ?? 0) > 0)
          MapEntry(
            entry.key,
            entry.value - (project.acceptedRoleCounts[entry.key] ?? 0),
          ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        children: [
          if (openRoles.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Buscamos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HomeColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (final entry in openRoles)
              _RoleCallCard(
                role: entry.key,
                missing: entry.value,
                deadline: project.teamDeadline,
                callOpen: project.isTeamCallOpenAt(),
                canJoin: canJoin,
                onJoin: () {
                  if (!requireSession()) return;
                  Get.to(
                    () => JoinTeamPage(
                      project: project,
                      initialRoleName: entry.key,
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Equipo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: HomeColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  _controller.isGuest
                      ? 'Inicia sesión para ver quiénes forman el equipo.'
                      : 'Todavía no hay miembros.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: HomeColors.textSecondary),
                ),
              ),
            ),
          for (final member in members)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        Text(
                          member.role,
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
          if (canJoin)
            DashedBorder(
              color: HomeColors.primaryPurple,
              radius: 14,
              child: Material(
                color: HomeColors.navSelectedBackground,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (!requireSession()) return;
                    Get.to(() => JoinTeamPage(project: project));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: HomeColors.primaryPurple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Unirse al equipo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: HomeColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Actividad": comments and members who joined, from Roble.
class _ActivityTab extends StatefulWidget {
  const _ActivityTab({required this.project});

  final Project project;

  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState
    extends _RobleTabState<_ActivityTab, List<ProjectActivity>> {
  final ProjectDetailController _controller = Get.find();

  @override
  Future<List<ProjectActivity>> load() =>
      _controller.activityFor(widget.project.id);

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    final days = diff.inDays;
    return days == 1 ? 'Hace 1 día' : 'Hace $days días';
  }

  @override
  Widget buildWith(BuildContext context, List<ProjectActivity> activity) {
    if (activity.isEmpty) {
      return const _EmptyTab(message: 'Todavía no hay actividad.');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      itemCount: activity.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = activity[index];
        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: HomeColors.navSelectedBackground,
              child: Icon(
                item.isComment
                    ? Icons.chat_bubble_outline
                    : Icons.group_add_outlined,
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
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  Text(
                    _timeAgo(item.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HomeColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: HomeColors.textSecondary),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: HomeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomeColors.surfaceGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: HomeColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: HomeColors.textSecondary,
            ),
          ),
        ],
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

String? _membersLabel(Project project) {
  final needed = project.teamRoles.values.fold(0, (sum, count) => sum + count);
  if (needed > 0) return '$needed miembros';
  if (project.acceptedMembersCount > 0) {
    return '${project.acceptedMembersCount} miembros';
  }
  return null;
}
