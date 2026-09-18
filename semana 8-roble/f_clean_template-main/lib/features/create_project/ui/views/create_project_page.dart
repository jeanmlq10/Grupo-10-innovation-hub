import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/create_project_step_tile.dart';
import 'new_idea_page.dart';

/// "Crear proyecto" — reached from the "+" button in "Mis proyectos".
/// Overview screen for the creation/editing wizard. It starts a new local
/// draft or loads an existing user project when editing.
class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key, this.editProjectId});

  final String? editProjectId;

  static const _steps = [
    _StepInfo('Información básica', 'Nombre y descripción'),
    _StepInfo('Equipo necesario', '¿Qué miembros necesitas?'),
    _StepInfo('Tiempo estimado', 'Define la duración del proyecto'),
    _StepInfo('Audiencia', '¿Quién puede ver tu proyecto?'),
    _StepInfo('Revisar y publicar', 'Confirma la información'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateProjectController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crear proyecto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Convierte tu idea en un proyecto real',
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return CreateProjectStepTile(
                      number: index + 1,
                      title: step.title,
                      subtitle: step.subtitle,
                      showConnector: index != _steps.length - 1,
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (editProjectId == null) {
                      controller.startNewDraft();
                      Get.to(() => const NewIdeaPage());
                      return;
                    }

                    final ok = controller.loadForEdit(editProjectId!);
                    if (ok) {
                      Get.to(() => const NewIdeaPage());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepInfo {
  const _StepInfo(this.title, this.subtitle);
  final String title;
  final String subtitle;
}
