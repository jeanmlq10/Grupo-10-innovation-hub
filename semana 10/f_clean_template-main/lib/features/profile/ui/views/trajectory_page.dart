import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/widgets/performance_bar.dart';
import 'package:f_clean_template/features/profile/ui/widgets/trajectory_stats_grid.dart';

/// "Resumen de trayectoria (detalle)": los indicadores y "Tu desempeño".
class TrajectoryPage extends StatelessWidget {
  const TrajectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Resumen de trayectoria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final s = controller.summary.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TrajectoryStatsGrid(summary: s),
            const SizedBox(height: 22),
            const Text(
              'Tu desempeño',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            PerformanceBar(label: 'Colaboración', value: s.collaboration),
            PerformanceBar(label: 'Cumplimiento', value: s.fulfillment),
            PerformanceBar(label: 'Calidad de aportes', value: s.quality),
            const SizedBox(height: 16),
            const Text(
              'Colaboración: participaciones, proyectos creados y comentarios. '
              'Cumplimiento: tareas asignadas que se completaron. '
              'Calidad de aportes: solicitudes tuyas que fueron aceptadas.',
              style: TextStyle(fontSize: 12, color: HomeColors.textSecondary),
            ),
          ],
        );
      }),
    );
  }
}
