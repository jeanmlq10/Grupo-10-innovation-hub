import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/selectable_option_tile.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/wizard_nav_buttons.dart';
import 'audience_page.dart';

/// "Tiempo estimado" — step 3 of 4. Single-choice among four duration
/// buckets. "Siguiente" doesn't require a selection (the reference
/// doesn't mark this as mandatory either).
class EstimatedTimePage extends StatelessWidget {
  const EstimatedTimePage({super.key});

  static const _options = [
    _DurationInfo('Días', '1 - 30 días', Icons.calendar_today_outlined),
    _DurationInfo('Semanas', '1 - 12 semanas', Icons.calendar_today_outlined),
    _DurationInfo('Meses', '1 - 12 meses', Icons.calendar_today_outlined),
    _DurationInfo('Años', 'Más de 1 año', Icons.schedule_outlined),
  ];

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
                    child: StepProgressBar(currentStep: 3, totalSteps: 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Tiempo estimado',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Cuánto tiempo crees que tomará?',
                style: TextStyle(fontSize: 14.5, color: HomeColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final option in _options)
                          SelectableOptionTile(
                            icon: option.icon,
                            title: option.label,
                            subtitle: option.subtitle,
                            selected: controller.duration.value == option.label,
                            onTap: () => controller.selectDuration(option.label),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              WizardNavButtons(
                onBack: () => Get.back(),
                onNext: () => Get.to(() => const AudiencePage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationInfo {
  const _DurationInfo(this.label, this.subtitle, this.icon);
  final String label;
  final String subtitle;
  final IconData icon;
}
