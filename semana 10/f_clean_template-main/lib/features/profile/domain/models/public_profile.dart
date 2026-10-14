import 'package:f_clean_template/features/profile/domain/models/activity_entry.dart';
import 'package:f_clean_template/features/profile/domain/models/trajectory_summary.dart';
import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';

/// Lo que se puede ver del perfil de otra persona, ya filtrado por su
/// privacidad: si el perfil es privado o su actividad es "Solo yo", esos
/// datos llegan vacíos.
class PublicProfile {
  const PublicProfile({
    required this.profile,
    required this.summary,
    required this.activity,
    required this.canSeeDetails,
  });

  final UserProfile profile;
  final TrajectorySummary? summary;
  final List<ActivityEntry> activity;

  final bool canSeeDetails;
}
