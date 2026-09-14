/// A project owned by the current user, shown in "Mis proyectos".
///
/// Unlike `features/home/domain/models/project.dart` (read-only cards in
/// the public "Explorar" feed), a [MyProject] also carries the data this
/// screen needs: whether it is still a [isDraft] or already published,
/// its [status] label, and the member/task/request counters shown on the
/// detailed card.
///
/// [isPlaceholder] marks the grey low-fidelity cards from the Figma
/// reference (no data yet, just a visual placeholder) so the UI can
/// render them without a name/description/stats.
class MyProject {
  MyProject({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.isDraft,
    this.membersCount,
    this.tasksCount,
    this.requestsCount,
    this.isPlaceholder = false,
  });

  final String id;
  final String name;
  final String description;
  final String status;
  final bool isDraft;
  final int? membersCount;
  final int? tasksCount;
  final int? requestsCount;
  final bool isPlaceholder;

  factory MyProject.fromJson(Map<String, dynamic> json) => MyProject(
    id: json['id'] ?? '0',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? '',
    isDraft: json['isDraft'] ?? false,
    membersCount: json['membersCount'],
    tasksCount: json['tasksCount'],
    requestsCount: json['requestsCount'],
    isPlaceholder: json['isPlaceholder'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
    'isDraft': isDraft,
    'membersCount': membersCount,
    'tasksCount': tasksCount,
    'requestsCount': requestsCount,
    'isPlaceholder': isPlaceholder,
  };

  @override
  String toString() => 'MyProject{id: $id, name: $name, isDraft: $isDraft}';
}
