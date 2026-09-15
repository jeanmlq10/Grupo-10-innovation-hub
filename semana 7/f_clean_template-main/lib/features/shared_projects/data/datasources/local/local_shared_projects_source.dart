import '../../../../home/domain/models/project.dart';
import '../../../domain/models/participation_request.dart';
import '../i_shared_projects_source.dart';

/// Local/in-memory implementation of [ISharedProjectsSource] — the
/// single in-memory list every user-created [Project] actually lives
/// in. No Firebase, no Supabase, no API, no database: everything here is
/// plain Dart state that survives for the app's session.
class LocalSharedProjectsSource implements ISharedProjectsSource {
  final List<Project> _projects = [];
  final List<ParticipationRequest> _requests = [];

  int _nextProjectId = 1;
  int _nextRequestId = 1;

  @override
  Project startDraft() {
    final draft = Project(
      id: 'u${_nextProjectId++}',
      name: '',
      description: '',
      categories: const [],
      canApply: true,
      isDraft: true,
    );
    _projects.add(draft);
    return draft;
  }

  @override
  Project? getById(String id) {
    for (final project in _projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  @override
  List<Project> getAll() => List.unmodifiable(_projects);

  @override
  void updateDraft(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      _projects.add(project);
    } else {
      _projects[index] = project;
    }
  }

  @override
  void publish(String id) {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(isDraft: false);
  }

  @override
  void submitRequest(ParticipationRequest request) {
    _requests.add(
      ParticipationRequest(
        id: 'r${_nextRequestId++}',
        projectId: request.projectId,
        role: request.role,
        message: request.message,
      ),
    );
  }

  @override
  List<ParticipationRequest> requestsFor(String projectId) => List.unmodifiable(
    _requests.where((request) => request.projectId == projectId),
  );
}
