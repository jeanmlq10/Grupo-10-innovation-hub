import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/widgets/dashed_border.dart';
import 'package:f_clean_template/features/auth/ui/widgets/login_required_dialog.dart';
import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';

/// "Crea otra idea" call-to-action card at the top of the project feed.
/// Opens the same "Crear proyecto" flow reachable from "Mis proyectos"'s
/// "+" button.
class CreateIdeaCard extends StatelessWidget {
  const CreateIdeaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: HomeColors.flowIdeaDash,
      strokeWidth: 1.4,
      radius: 16,
      child: Material(
        color: HomeColors.flowIdeaCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Visitante: crear un proyecto requiere cuenta.
            if (!requireSession()) return;
            Get.to(() => const CreateProjectPage());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: HomeColors.flowIdeaPlus,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crea otra idea',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: HomeColors.flowNavy,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Comparte tu idea y encuentra personas que quieren construirla contigo',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HomeColors.flowNavy,
                          height: 1.3,
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
