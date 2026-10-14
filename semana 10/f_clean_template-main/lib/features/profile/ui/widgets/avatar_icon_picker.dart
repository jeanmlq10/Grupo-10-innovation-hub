import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/ui/widgets/avatar_icons.dart';

/// Hoja inferior para elegir el icono del perfil. Devuelve la clave elegida,
/// '' para volver a la inicial, o null si se cierra sin elegir.
Future<String?> showAvatarIconPicker(String current) =>
    Get.bottomSheet<String>(
      _AvatarIconPicker(current: current),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

class _AvatarIconPicker extends StatelessWidget {
  const _AvatarIconPicker({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Elige tu icono',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: HomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in AvatarIcons.all.entries)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Get.back(result: entry.key),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HomeColors.navSelectedBackground,
                        border: Border.all(
                          color: entry.key == current
                              ? HomeColors.primaryPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        color: HomeColors.primaryPurple,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(result: ''),
              child: const Text('Usar mi inicial'),
            ),
          ],
        ),
      ),
    );
  }
}
