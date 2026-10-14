import 'dart:convert';

import 'package:f_clean_template/core/roble/roble_guard.dart';
import 'package:f_clean_template/core/roble/roble_optional_columns.dart';
import 'package:f_clean_template/core/roble/roble_rows.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_data_source.dart';
import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';
import 'package:f_clean_template/features/profile/domain/profile_failure.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';

/// Perfiles: convierte filas en [UserProfile] y traduce errores.
class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._source);

  final IProfileDataSource _source;

  static const _optionalColumns = {'avatarIcon'};

  Future<T> _guard<T>(Future<T> Function() action) =>
      robleGuard(action, ProfileFailure.new, notFound: 'Ese perfil ya no existe.');

  @override
  Future<UserProfile?> byUserId(String userId) async {
    if (userId.isEmpty) return null;
    final rows = await _guard(() => _source.readForUser(userId));
    // Solo vale la fila que escribió el propio usuario (`_owner`).
    final own = rows.where((row) => RobleRows.author(row, 'userId') == userId);
    return own.isEmpty ? null : _toProfile(own.first);
  }

  @override
  Future<UserProfile> save(UserProfile profile) async {
    // `avatarIcon` es columna nueva: si aún no existe, se guarda sin ella.
    final row = profile.id.isEmpty
        ? await _guard(
            () => RobleOptionalColumns.write(
              _toRow(profile),
              _source.create,
              optional: _optionalColumns,
            ),
          )
        : await _guard(
            () => RobleOptionalColumns.write(
              _toRow(profile),
              (changes) => _source.update(profile.id, changes),
              optional: _optionalColumns,
            ),
          );
    return row.isEmpty ? profile : _toProfile(row);
  }

  @override
  Future<void> delete(UserProfile profile) async {
    if (profile.id.isEmpty) return;
    await _guard(() => _source.delete(profile.id));
  }

  Map<String, dynamic> _toRow(UserProfile p) => {
    'userId': p.userId,
    'name': p.name,
    'username': p.username,
    'bio': p.bio,
    'career': p.career,
    'profileVisibility': p.visibility.name,
    'contactPermission': p.contact.name,
    'activityVisibility': p.activityVisibility.name,
    'notificationsEnabled': p.notificationsEnabled,
    'mutedNotifications': jsonEncode(p.mutedNotifications.toList()),
    'avatarIcon': p.avatarIcon,
    'updatedAt': RobleRows.nowIso(),
  };

  UserProfile _toProfile(Map<String, dynamic> row) => UserProfile(
    id: RobleRows.str(row['_id']),
    userId: RobleRows.str(row['userId']),
    name: RobleRows.str(row['name']),
    username: RobleRows.str(row['username']),
    bio: RobleRows.str(row['bio']),
    career: RobleRows.str(row['career']),
    visibility: RobleRows.str(row['profileVisibility']) == 'private'
        ? ProfileVisibility.private
        : ProfileVisibility.public,
    contact: RobleRows.str(row['contactPermission']) == 'nobody'
        ? ContactPermission.nobody
        : ContactPermission.everyone,
    activityVisibility: RobleRows.str(row['activityVisibility']) == 'onlyMe'
        ? ActivityVisibility.onlyMe
        : ActivityVisibility.everyone,
    notificationsEnabled: RobleRows.boolean(
      row['notificationsEnabled'],
      fallback: true,
    ),
    mutedNotifications: RobleRows.stringList(row['mutedNotifications']).toSet(),
    avatarIcon: RobleRows.str(row['avatarIcon']),
  );
}
