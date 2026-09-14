import '../../../domain/models/project.dart';
import '../i_project_source.dart';

/// Local/dummy implementation of [IProjectSource].
///
/// No backend, no Firebase/Supabase, no HTTP: this entrega only needs the
/// Home to show and scroll through data. When a real API is connected
/// later, a `RemoteProjectSource implements IProjectSource` can replace
/// this in `home_dependencies.dart` without touching the controller, the
/// repository contract, or any widget.
class LocalProjectSource implements IProjectSource {
  final List<Project> _projects = [
    Project(
      id: '1',
      name: 'EcoCampus',
      description: 'Diseñemos juntos un campus más sostenible.',
      categories: const ['Medio ambiente', 'Impacto social'],
    ),
    Project(
      id: '2',
      name: 'InnovAcción',
      description:
          'Un espacio para llevar ideas de innovación social del papel a la práctica.',
      categories: const ['Innovación', 'Impacto social'],
    ),
    Project(
      id: '3',
      name: 'GreenLab',
      description:
          'Laboratorio estudiantil de soluciones ambientales de bajo costo.',
      categories: const ['Medio ambiente', 'Tecnología'],
    ),
    Project(
      id: '4',
      name: 'Aula Verde',
      description:
          'Huertas urbanas dentro del campus, cuidadas por estudiantes voluntarios.',
      categories: const ['Educación', 'Medio ambiente'],
    ),
    Project(
      id: '5',
      name: 'DataX',
      description:
          'Analizamos datos abiertos de la ciudad para proponer mejoras urbanas.',
      categories: const ['Tecnología', 'Impacto social'],
    ),
    Project(
      id: '6',
      name: 'Voces Estudiantiles',
      description:
          'Plataforma de encuestas rápidas para escuchar a la comunidad universitaria.',
      categories: const ['Comunidad', 'Innovación'],
    ),
  ];

  @override
  Future<List<Project>> getProjects() async {
    // Small artificial delay so the loading state is visible, same spirit
    // as a real network/local-storage read.
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_projects);
  }
}
