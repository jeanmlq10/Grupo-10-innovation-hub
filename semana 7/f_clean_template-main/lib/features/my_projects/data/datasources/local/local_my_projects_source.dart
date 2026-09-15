import '../../../domain/models/my_project.dart';
import '../i_my_projects_source.dart';

/// Local/mock implementation of [IMyProjectsSource].
///
/// This stage is scoped to LOCAL data only: no Firebase, no Supabase, no
/// API, no database. When creation, drafts and publishing are
/// implemented in a later stage, this list becomes the in-memory store
/// those flows read from and write to — the shape (`isDraft`,
/// `isPlaceholder`, counters) is already prepared for that, it just
/// isn't wired up yet.
///
/// - `EcoCampus` is the one fully-specified published project from the
///   Figma reference, with its member/task/request counters.
/// - The two placeholder entries reproduce the grey low-fidelity cards
///   shown below EcoCampus in the reference.
/// - `Huerta comunitaria` is the one fully-specified draft: same card
///   style as EcoCampus, but with the "Borrador" status and no stats
///   row yet. A second placeholder draft keeps the "Mis borradores (2)"
///   count from the reference accurate.
class LocalMyProjectsSource implements IMyProjectsSource {
  final List<MyProject> _myProjects = [
    MyProject(
      id: '1',
      name: 'EcoCampus',
      description: 'Diseñemos juntos un campus más sostenible.',
      status: 'En desarrollo',
      isDraft: false,
      membersCount: 24,
      tasksCount: 3,
      requestsCount: 12,
    ),
    MyProject(
      id: '2',
      name: '',
      description: '',
      status: '',
      isDraft: false,
      isPlaceholder: true,
    ),
    MyProject(
      id: '3',
      name: '',
      description: '',
      status: '',
      isDraft: false,
      isPlaceholder: true,
    ),
    MyProject(
      id: '4',
      name: 'Huerta comunitaria',
      description:
          'Un espacio compartido para cultivar y aprender en comunidad.',
      status: 'Borrador',
      isDraft: true,
    ),
    MyProject(
      id: '5',
      name: '',
      description: '',
      status: '',
      isDraft: true,
      isPlaceholder: true,
    ),
  ];

  // Ids 1-5 are already used by the seeded mock data above.
  int _nextId = 6;

  @override
  Future<List<MyProject>> getMyProjects() async {
    // Small artificial delay so the loading state is visible, same spirit
    // as `LocalProjectSource.getProjects()` in the home feature.
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_myProjects);
  }

  @override
  void addProject({
    required String name,
    required String description,
    required int membersCount,
  }) {
    // Every project coming out of "Crear proyecto" starts the same way:
    // published (not a draft), "En desarrollo", with no tasks or
    // requests yet — that's a business rule about a brand-new project's
    // initial state, so it belongs here in the data layer, not in the
    // wizard's UI.
    _myProjects.insert(
      0,
      MyProject(
        id: '${_nextId++}',
        name: name,
        description: description,
        status: 'En desarrollo',
        isDraft: false,
        membersCount: membersCount,
        tasksCount: 0,
        requestsCount: 0,
      ),
    );
  }
}
