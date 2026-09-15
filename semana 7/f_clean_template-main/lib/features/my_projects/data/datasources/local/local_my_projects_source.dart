import '../../../domain/models/my_project.dart';
import '../i_my_projects_source.dart';

/// Local/mock implementation of [IMyProjectsSource].
///
/// This stage is scoped to LOCAL data only: no Firebase, no Supabase, no
/// API, no database.
///
/// - `EcoCampus` is the one fully-specified published project from the
///   Figma reference, with its member/task/request counters.
/// - The two placeholder entries reproduce the grey low-fidelity cards
///   shown below EcoCampus in the reference.
/// - `Huerta comunitaria` is the one fully-specified draft: same card
///   style as EcoCampus, but with the "Borrador" status and no stats
///   row yet. A second placeholder draft keeps the "Mis borradores (2)"
///   count from the reference accurate.
///
/// Projects created through "Crear proyecto" are NOT added here — they
/// live in `ISharedProjectsRepository` and `MyProjectsController` merges
/// them into its list at read time, so there's only ever one copy of a
/// user-created project, never a second one duplicated into this file.
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

  @override
  Future<List<MyProject>> getMyProjects() async {
    // Small artificial delay so the loading state is visible, same spirit
    // as `LocalProjectSource.getProjects()` in the home feature.
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_myProjects);
  }
}
