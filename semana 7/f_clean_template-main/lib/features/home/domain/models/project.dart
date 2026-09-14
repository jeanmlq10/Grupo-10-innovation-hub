class Project {
  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
  });

  final String id;
  final String name;
  final String description;
  final List<String> categories;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] ?? '0',
    name: json['name'] ?? '---',
    description: json['description'] ?? '',
    categories:
        (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categories': categories,
  };

  @override
  String toString() => 'Project{id: $id, name: $name}';
}
