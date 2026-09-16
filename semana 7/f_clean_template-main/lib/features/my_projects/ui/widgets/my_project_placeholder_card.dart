import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// Low-fidelity grey placeholder card — a grey image box next to a few
/// grey text bars, no real data yet.
class MyProjectPlaceholderCard extends StatelessWidget {
  const MyProjectPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: HomeColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: HomeColors.placeholderGrey,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Bar(widthFactor: 1),
                SizedBox(height: 8),
                _Bar(widthFactor: 1),
                SizedBox(height: 8),
                _Bar(widthFactor: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: HomeColors.placeholderGrey,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
