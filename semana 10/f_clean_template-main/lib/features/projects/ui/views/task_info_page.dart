import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/widgets/dashed_border.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/create_project_controller.dart';
import 'package:f_clean_template/features/projects/ui/views/estimated_time_page.dart';
import 'package:f_clean_template/features/projects/ui/widgets/deadline_picker_field.dart';
import 'package:f_clean_template/features/projects/ui/widgets/step_progress_bar.dart';
import 'package:f_clean_template/features/projects/ui/widgets/wizard_nav_buttons.dart';
import 'package:f_clean_template/features/tasks/domain/models/project_task.dart';

/// "Información de tareas" (Cambio 2 · paso 3 del diseño): para cada tarea
/// específica se escribe la descripción y hasta cuándo se puede postular
/// ("Disponible hasta"). Va entre "Equipo necesario" y "Tiempo estimado".
class TaskInfoPage extends StatelessWidget {
  const TaskInfoPage({super.key});

  Future<void> _addTask(CreateProjectController controller) async {
    final textController = TextEditingController();
    final title = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Nueva tarea'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Get.back(result: value),
          decoration: const InputDecoration(hintText: 'Ej: Diseñar la interfaz'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Get.back(result: textController.text),
            style: FilledButton.styleFrom(
              backgroundColor: HomeColors.primaryPurple,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (title != null) controller.addTask(title);
  }

  @override
  Widget build(BuildContext context) {
    final CreateProjectController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 8),
                  const Expanded(
                    child: StepProgressBar(currentStep: 2, totalSteps: 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Información de tareas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configura las tareas de tu proyecto',
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (controller.tasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: Text(
                              'Tareas puntuales en las que alguien puede '
                              'ayudar sin unirse al equipo. Agrégalas aquí '
                              'o sigue sin tareas.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: HomeColors.textSecondary,
                              ),
                            ),
                          ),
                        for (var i = 0; i < controller.tasks.length; i++)
                          _TaskInfoCard(
                            key: ValueKey('task-info-$i'),
                            task: controller.tasks[i],
                            onDescriptionChanged: (value) =>
                                controller.updateTaskDescription(i, value),
                            onDeadlinePicked: (value) =>
                                controller.setTaskDeadline(i, value),
                            onRemove: () => controller.removeTask(i),
                            onIncrement: () => controller.incrementTask(i),
                            onDecrement: () => controller.decrementTask(i),
                          ),
                        DashedBorder(
                          color: HomeColors.primaryPurple,
                          radius: 12,
                          child: Material(
                            color: HomeColors.navSelectedBackground,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _addTask(controller),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: HomeColors.primaryPurple,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Agregar otra tarea',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: HomeColors.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configura hasta cuándo pueden postularse.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HomeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              WizardNavButtons(
                onBack: () => Get.back(),
                onNext: () => Get.to(() => const EstimatedTimePage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de una tarea: título, estado, descripción y "Disponible hasta".
class _TaskInfoCard extends StatefulWidget {
  const _TaskInfoCard({
    super.key,
    required this.task,
    required this.onDescriptionChanged,
    required this.onDeadlinePicked,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ProjectTask task;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<DateTime> onDeadlinePicked;
  final VoidCallback onRemove;

  @override
  State<_TaskInfoCard> createState() => _TaskInfoCardState();
}

class _TaskInfoCardState extends State<_TaskInfoCard> {
  late final TextEditingController _description;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.task.description);
  }

  @override
  void didUpdateWidget(covariant _TaskInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && _description.text != widget.task.description) {
      _description.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
      decoration: BoxDecoration(
        border: Border.all(color: HomeColors.borderGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.drag_indicator,
                color: HomeColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: HomeColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E8A4C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 13, color: HomeColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextField(
              controller: _description,
              focusNode: _focus,
              onChanged: widget.onDescriptionChanged,
              maxLines: 2,
              minLines: 1,
              style: const TextStyle(color: HomeColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe qué hay que hacer',
                hintStyle: const TextStyle(color: HomeColors.textSecondary),
                filled: true,
                fillColor: HomeColors.surfaceGrey,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Personas necesarias',
                  style: TextStyle(
                    fontSize: 13,
                    color: HomeColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Menos personas',
                onPressed: widget.onDecrement,
                icon: const Icon(Icons.remove, size: 18),
              ),
              Text(
                '${task.numberNeeded}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              IconButton(
                tooltip: 'Más personas',
                onPressed: widget.onIncrement,
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Disponible hasta',
            style: TextStyle(fontSize: 13, color: HomeColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DeadlinePickerField(
                  value: task.deadline,
                  onPicked: widget.onDeadlinePicked,
                ),
              ),
              IconButton(
                tooltip: 'Quitar tarea',
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD9534F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
