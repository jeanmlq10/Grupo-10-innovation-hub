import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../create_project/ui/views/create_project_page.dart';
import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../../../home/ui/widgets/dashed_border.dart';
import '../../../../core/error_message.dart';
import '../../domain/models/project_member.dart';
import '../../domain/models/project_task.dart';
import '../viewmodels/project_application_controller.dart';
import '../widgets/project_comments_sheet.dart';
import 'choose_participation_page.dart';
import 'join_team_page.dart';

/// "Ver proyecto" — opened by tapping a project in "Explorar proyectos".
///
/// The main exploration flow intentionally keeps the important actions close
/// to the project itself:
/// - the bell in the top-right follows/unfollows the project;
/// - the bottom "Comentar" button opens the comments sheet directly;
/// - tasks and the team can be opened directly from their tabs.
///
/// The visual hierarchy follows the updated exploration flow: a larger
/// project presentation on "Descripción" and a compact project header on
/// the remaining tabs.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ProjectApplicationController _controller = Get.find();

  /// Starts with what the list passed in and is replaced by the fresh
  /// version from Roble as soon as it arrives.
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

  /// Reloads the project and the follow state from Roble.
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
      // Keep showing what we have; actions will surface real errors.
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  /// Follow / unfollow, stored in Roble (`project_follows`).
  Future<void> _toggleFollow() async {
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
              onMore: () => Get.to(
                () => ChooseParticipationPage(project: project),
              ),
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
                    onPressed: () => showProjectComments(context, project.id),
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
          // The current project model has no cover-image field, so the
          // existing project icon remains the visual identity here instead
          // of inventing image data that does not belong to the project.
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
              // "Toda la comunidad" is implied for anyone seeing a public
              // project; only a private audience ("Solo yo") is shown.
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
  final ProjectApplicationController _controller = Get.find();

  @override
  Future<List<ProjectTask>> load() => _controller.tasksFor(widget.project.id);

  @override
  Widget buildWith(BuildContext context, List<ProjectTask> tasks) {
    final project = widget.project;
    final canApply =
        project.canApply && project.isPublic && !_controller.isOwner(project);

    if (tasks.isEmpty) {
      return const _EmptyTab(
        message: 'Este proyecto no especificó tareas todavía.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        children: [
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: HomeColors.borderGrey),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: canApply && task.hasSpots
                      ? () => Get.to(
                          () => JoinTeamPage(project: project, task: task),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
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
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: HomeColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          task.hasSpots
                              ? 'Se necesitan ${task.numberNeeded - task.numberAccepted}'
                              : 'Completa',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: HomeColors.textSecondary,
                          ),
                        ),
                        if (canApply && task.hasSpots) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.chevron_right,
                            color: HomeColors.textSecondary,
                            size: 20,
                          ),
                        ],
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

/// "Miembros": real members (table `project_members`).
class _MembersTab extends StatefulWidget {
  const _MembersTab({required this.project});

  final Project project;

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState
    extends _RobleTabState<_MembersTab, List<ProjectMember>> {
  final ProjectApplicationController _controller = Get.find();

  @override
  Future<List<ProjectMember>> load() =>
      _controller.membersFor(widget.project.id);

  @override
  Widget buildWith(BuildContext context, List<ProjectMember> members) {
    final project = widget.project;
    final canJoin =
        project.canApply && project.isPublic && !_controller.isOwner(project);
    // Team roles still looking for people (needed − already accepted).
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: HomeColors.borderGrey),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: canJoin
                        ? () => Get.to(
                            () => JoinTeamPage(
                              project: project,
                              initialRoleName: entry.key,
                            ),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_search_outlined,
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
                          if (canJoin) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.chevron_right,
                              color: HomeColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Todavía no hay miembros.',
                  style: TextStyle(color: HomeColors.textSecondary),
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
                  onTap: () => Get.to(() => JoinTeamPage(project: project)),
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
  final ProjectApplicationController _controller = Get.find();

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
