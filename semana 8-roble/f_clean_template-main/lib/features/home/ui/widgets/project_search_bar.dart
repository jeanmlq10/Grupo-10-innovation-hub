import 'package:flutter/material.dart';

import '../home_colors.dart';

/// Search field for "Buscar proyectos....". Purely presentational: it only
/// reports text changes through [onChanged] — filtering itself happens in
/// [HomeController], not here.
class ProjectSearchBar extends StatelessWidget {
  const ProjectSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeColors.flowSearchFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: HomeColors.flowNavy, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Buscar proyectos....',
          hintStyle: TextStyle(color: HomeColors.flowSearchHint, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: Icon(
            Icons.search_rounded,
            color: HomeColors.flowNavy,
            size: 25,
          ),
        ),
      ),
    );
  }
}
