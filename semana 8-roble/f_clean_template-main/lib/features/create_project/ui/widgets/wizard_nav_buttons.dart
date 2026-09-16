import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// The "Anterior" / "Siguiente" button pair at the bottom of every
/// wizard step from "Equipo necesario" onward. [nextLabel] is
/// overridden to "Publicar proyecto" on the last step.
class WizardNavButtons extends StatelessWidget {
  const WizardNavButtons({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Siguiente',
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: HomeColors.textPrimary,
              side: const BorderSide(color: HomeColors.borderGrey),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Anterior',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              nextLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
