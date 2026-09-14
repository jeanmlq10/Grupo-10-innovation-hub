import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_colors.dart';
import 'dashed_border.dart';

/// "Crea otra idea" call-to-action card at the top of the project feed.
///
/// Publishing a new idea belongs to a different flow/entrega, so tapping
/// it only surfaces a placeholder message for now instead of navigating
/// anywhere — same "visual only, pending" treatment as the bottom
/// navigation tabs other than Explorar.
class CreateIdeaCard extends StatelessWidget {
  const CreateIdeaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: Colors.black.withValues(alpha: 0.85),
      radius: 20,
      child: Material(
        color: HomeColors.ideaCardBackground,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.snackbar(
              'Crea otra idea',
              'Publicar una idea nueva llega en una próxima entrega.',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: HomeColors.circlePurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Crea otra idea',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: HomeColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparte tu idea y encuentra personas que quieren construirla contigo',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HomeColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
