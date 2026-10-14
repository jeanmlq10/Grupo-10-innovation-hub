import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Recuadro gris con un texto (mensaje de presentación, comentario...).
class QuoteBox extends StatelessWidget {
  const QuoteBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          color: HomeColors.textSecondary,
          height: 1.35,
        ),
      ),
    );
  }
}
