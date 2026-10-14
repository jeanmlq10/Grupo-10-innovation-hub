/// Mirrors the profile map returned by every Roble sign-in method
/// (`login`, `signInWithProvider`, `currentUser`, ...):
/// `{id, userId, email, name, role, extra, createdAt, updatedAt}`.
class AuthenticationUser {
  const AuthenticationUser({
    required this.id,
    required this.userId,
    required this.email,
    required this.name,
    this.role,
    this.extra = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String email;
  final String name;
  final String? role;
  final Map<String, dynamic> extra;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get career => _stringOrNull(extra['career'] ?? extra['programa']);

  String? get photoUrl => _stringOrNull(extra['photo_url'] ?? extra['picture']);

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
  String get lastName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.skip(1).join(' ') : '';
  }

  factory AuthenticationUser.fromProfile(Map<String, dynamic> json) {
    final extra = json['extra'];
    final email = (json['email']?.toString() ?? '').trim().toLowerCase();
    final name = (json['name']?.toString() ?? '').trim();
    return AuthenticationUser(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      email: email,
      name: name.isEmpty ? email : name,
      role: _stringOrNull(json['role']),
      extra: extra is Map ? Map<String, dynamic>.from(extra) : const {},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'email': email,
    'name': name,
    'role': role,
    'extra': extra,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static String? _stringOrNull(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
