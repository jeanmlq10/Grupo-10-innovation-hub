import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/projects/ui/views/create_project_page.dart';
import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/auth/ui/widgets/auth_form_widgets.dart';

/// "¿Qué quieres hacer?" — shown once, right after a new account finishes
/// sign-up + verification. It opens on top of Home:
/// - "Publicar una idea" replaces it with the existing "Crear proyecto"
///   flow (the same one "Crea otra idea" opens), so going back lands in Home.
/// - "Explorar proyectos" simply closes it, revealing Home.
class WhatToDoPage extends StatelessWidget {
  const WhatToDoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FlowScreenBody(
        horizontalFraction: 0.058,
        children: [
          const SizedBox(height: 24),
          const Spacer(flex: 10),
          const Text(
            '¿Qué quieres hacer?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.5,
              fontWeight: FontWeight.w800,
              color: HomeColors.flowNavy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige por dónde empezar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: HomeColors.flowSlate),
          ),
          const SizedBox(height: 30),
          _ChoiceCard(
            icon: const _IconSlot(
              background: HomeColors.flowLavenderFaint,
              child: _LightBulbIcon(size: 46),
            ),
            title: 'Publicar una idea',
            description: 'Comparte tu idea\ncon otros.',
            onTap: () => Get.off(() => const CreateProjectPage()),
          ),
          const SizedBox(height: 18),
          _ChoiceCard(
            icon: const _IconSlot(
              child: Icon(
                Icons.explore_outlined,
                size: 50,
                color: HomeColors.flowAccent,
              ),
            ),
            title: 'Explorar proyectos',
            description: 'Descubre proyectos\ny únete a ellos.',
            onTap: () => Get.back(),
          ),
          const SizedBox(height: 32),
          const Spacer(flex: 5),
          const Text(
            'Podrás cambiar esto más adelante\ndesde el menú principal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: HomeColors.flowFootnote,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HomeColors.flowBorder, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 16, 20),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: HomeColors.flowNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15.5,
                          color: HomeColors.flowSlate,
                          height: 1.35,
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

/// Square slot on the left of each choice card; both icons share it so
/// the texts line up, as in the reference.
class _IconSlot extends StatelessWidget {
  const _IconSlot({required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Light bulb with rays, as drawn in the reference.
class _LightBulbIcon extends StatelessWidget {
  const _LightBulbIcon({required this.size});

  final double size;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
<g stroke="#4B309E" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
<path d="M18.5 32.5C15 30 12.5 26.3 12.5 22C12.5 15.6 17.6 10.5 24 10.5C30.4 10.5 35.5 15.6 35.5 22C35.5 26.3 33 30 29.5 32.5V36H18.5V32.5Z"/>
<path d="M19.5 40H28.5M21.5 44H26.5"/>
<path d="M24 2.5V5.5M11 7.5L13.2 9.7M37 7.5L34.8 9.7M5.5 31L8.2 29.8M42.5 31L39.8 29.8"/>
</g>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(_svg),
    );
  }
}
