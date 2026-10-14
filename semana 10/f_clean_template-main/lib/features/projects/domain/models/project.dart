import 'package:f_clean_template/core/utils/deadline.dart';

/// A project shown in "Explorar proyectos".
class Project {
  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    this.canApply = false,
    this.teamRoles = const {},
    this.duration,
    this.audience,
    this.isDraft = false,
    this.acceptedMembersCount = 0,
    this.acceptedRoleCounts = const {},
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
    this.teamDeadline,
  });

  final String id;
  final String name;
  final String description;
  final List<String> categories;

  final bool canApply;

  final Map<String, int> teamRoles;

  final String? duration;
  final String? audience;

  final bool isDraft;

  final int acceptedMembersCount;

  final Map<String, int> acceptedRoleCounts;
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final DateTime? teamDeadline;

  bool isTeamCallOpenAt([DateTime? now]) => isBeforeDeadline(teamDeadline, now);

  bool get isPublic => !isDraft && audience == 'Toda la comunidad';

  Project copyWith({
    String? name,
    String? description,
    List<String>? categories,
    bool? canApply,
    Map<String, int>? teamRoles,
    String? duration,
    String? audience,
    bool? isDraft,
    int? acceptedMembersCount,
    Map<String, int>? acceptedRoleCounts,
    String? createdBy,
    String? createdByName,
    DateTime? updatedAt,
    DateTime? teamDeadline,
  }) => Project(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    categories: categories ?? this.categories,
    canApply: canApply ?? this.canApply,
    teamRoles: teamRoles ?? this.teamRoles,
    duration: duration ?? this.duration,
    audience: audience ?? this.audience,
    isDraft: isDraft ?? this.isDraft,
    acceptedMembersCount: acceptedMembersCount ?? this.acceptedMembersCount,
    acceptedRoleCounts: acceptedRoleCounts ?? this.acceptedRoleCounts,
    createdBy: createdBy ?? this.createdBy,
    createdByName: createdByName ?? this.createdByName,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    teamDeadline: teamDeadline ?? this.teamDeadline,
  );

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] ?? '0',
    name: json['name'] ?? '---',
    description: json['description'] ?? '',
    categories:
        (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    canApply: json['canApply'] ?? false,
    teamRoles:
        (json['teamRoles'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int),
        ) ??
        const {},
    duration: json['duration'],
    audience: json['audience'],
    isDraft: json['isDraft'] ?? false,
    acceptedMembersCount: json['acceptedMembersCount'] ?? 0,
    createdBy: json['createdBy'],
    createdByName: json['createdByName'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categories': categories,
    'canApply': canApply,
    'teamRoles': teamRoles,
    'duration': duration,
    'audience': audience,
    'isDraft': isDraft,
    'acceptedMembersCount': acceptedMembersCount,
    'createdBy': createdBy,
    'createdByName': createdByName,
  };

  @override
  String toString() => 'Project{id: $id, name: $name}';
}
