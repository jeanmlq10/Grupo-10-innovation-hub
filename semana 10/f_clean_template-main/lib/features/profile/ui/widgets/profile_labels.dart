import 'package:flutter/material.dart';

import 'package:f_clean_template/features/profile/domain/models/activity_entry.dart';
import 'package:f_clean_template/features/profile/domain/models/trajectory_summary.dart';

/// Textos e iconos del perfil (la vista; el dominio no sabe de textos).
abstract final class ProfileLabels {
  static String commitment(CommitmentLevel level) => switch (level) {
    CommitmentLevel.high => 'Alto',
    CommitmentLevel.medium => 'Medio',
    CommitmentLevel.low => 'Bajo',
    CommitmentLevel.newcomer => 'Nuevo',
  };

  static String activityTitle(ActivityKind kind, {required bool self}) =>
      switch (kind) {
        ActivityKind.publication =>
          self ? 'Publicaste un nuevo proyecto' : 'Publicó un nuevo proyecto',
        ActivityKind.participation =>
          self ? 'Te uniste a un proyecto' : 'Se unió a un proyecto',
        ActivityKind.taskAssignment =>
          self ? 'Fuiste asignado a una tarea' : 'Fue asignado a una tarea',
        ActivityKind.comment =>
          self ? 'Comentaste en un proyecto' : 'Comentó en un proyecto',
        ActivityKind.follow =>
          self ? 'Seguiste un proyecto' : 'Siguió un proyecto',
      };

  static IconData activityIcon(ActivityKind kind) => switch (kind) {
    ActivityKind.publication => Icons.add_circle_outline,
    ActivityKind.participation => Icons.group_outlined,
    ActivityKind.taskAssignment => Icons.assignment_ind_outlined,
    ActivityKind.comment => Icons.chat_bubble_outline,
    ActivityKind.follow => Icons.notifications_none,
  };
}
