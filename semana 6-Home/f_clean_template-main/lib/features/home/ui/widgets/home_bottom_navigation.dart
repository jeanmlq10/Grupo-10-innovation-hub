import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_colors.dart';

/// Bottom navigation bar for "Explorar | Mis proyectos | Notificaciones |
/// Perfil".
///
/// Only "Explorar" is a real destination in this entrega — it is the
/// screen already shown. The other three are visual-only/pending, as the
/// assignment explicitly scopes out those features for now; tapping them
/// just informs the user instead of navigating or crashing.
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  static const _tabs = [
    _TabData(icon: Icons.explore_outlined, label: 'Explorar'),
    _TabData(icon: Icons.folder_shared_outlined, label: 'Mis proyectos'),
    _TabData(icon: Icons.notifications_none, label: 'Notificaciones', hasBadge: true),
    _TabData(icon: Icons.account_circle_outlined, label: 'Perfil'),
  ];

  void _onTabTapped(int index) {
    if (index == 0) return;
    Get.snackbar(
      _tabs[index].label,
      'Esta sección todavía no está implementada.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == 0;
          return _NavIcon(
            icon: _tabs[index].icon,
            selected: isSelected,
            hasBadge: _tabs[index].hasBadge,
            onTap: () => _onTabTapped(index),
          );
        }),
      ),
    );
  }
}

class _TabData {
  const _TabData({
    required this.icon,
    required this.label,
    this.hasBadge = false,
  });

  final IconData icon;
  final String label;
  final bool hasBadge;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.hasBadge = false,
  });

  final IconData icon;
  final bool selected;
  final bool hasBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // In Figma every icon is drawn in the same purple/indigo stroke — only
    // the selected tab additionally gets the light lavender circle behind
    // it. Unselected icons are NOT grey.
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? HomeColors.navSelectedBackground
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: HomeColors.primaryPurple, size: 26),
            if (hasBadge)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: HomeColors.circlePurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
