import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// One row of the vertical step list in "Crear proyecto": a numbered
/// purple circle, a title and a subtitle, with a thin connector line
/// down to the next circle (matching the stepper look in the Figma
/// reference).
class CreateProjectStepTile extends StatelessWidget {
  const CreateProjectStepTile({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    this.showConnector = true,
  });

  final int number;
  final String title;
  final String subtitle;

  /// `false` for the last step, which has nothing left to connect to.
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: HomeColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    color: HomeColors.navSelectedBackground,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 22 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
