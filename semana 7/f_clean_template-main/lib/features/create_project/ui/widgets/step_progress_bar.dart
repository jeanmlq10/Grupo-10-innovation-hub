import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// The thin purple progress bar + "1/4" label at the top of each wizard
/// step from "Información básica" onward.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: 6,
              backgroundColor: HomeColors.surfaceGrey,
              valueColor: const AlwaysStoppedAnimation(
                HomeColors.primaryPurple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$currentStep/$totalSteps',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: HomeColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
