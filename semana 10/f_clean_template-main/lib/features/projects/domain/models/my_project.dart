/// A project owned by the current user, shown in "Mis proyectos".
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
