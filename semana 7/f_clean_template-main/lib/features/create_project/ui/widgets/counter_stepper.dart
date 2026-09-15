import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// The "–  0  +" control next to each role in "Equipo necesario".
class CounterStepper extends StatelessWidget {
  const CounterStepper({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 26,
          child: Center(
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: HomeColors.textPrimary,
              ),
            ),
          ),
        ),
        _StepperButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: HomeColors.surfaceGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: HomeColors.textPrimary),
      ),
    );
  }
}
