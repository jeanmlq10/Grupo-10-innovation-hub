import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_colors.dart';
import '../../../shared_projects/ui/views/notifications_page.dart';

/// Bottom navigation bar for "Explorar | Mis proyectos | Notificaciones |
/// Perfil".
///
/// "Explorar" and "Mis proyectos" are real destinations, registered as
/// named routes in `main.dart` ('/home' and '/mis-proyectos'). Navigating
/// by route name — instead of importing `HomePage`/`MyProjectsPage`
/// directly — keeps this shared widget free of a circular import with
/// the pages that embed it. "Notificaciones" now opens `NotificationsPage`
/// (pushed, not a named route, since it's not a peer tab you toggle back
/// and forth into — it's a normal screen you visit and back out of).
/// "Perfil" stays visual-only/pending, out of scope for this block.
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key, this.currentIndex = 0});

  /// Which tab is currently active (0 = Explorar, 1 = Mis proyectos).
  final int currentIndex;

  static const _tabs = [
    _TabData(icon: Icons.explore_outlined, label: 'Explorar'),
    _TabData(icon: Icons.folder_shared_outlined, label: 'Mis proyectos'),
    _TabData(icon: Icons.notifications_none, label: 'Notificaciones', hasBadge: true),
    _TabData(icon: Icons.account_circle_outlined, label: 'Perfil'),
  ];

  void _onTabTapped(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/mis-proyectos');
        break;
      case 2:
        Get.to(() => const NotificationsPage());
        break;
      default:
        Get.snackbar(
          _tabs[index].label,
          'Esta sección todavía no está implementada.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
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
          final isSelected = index == currentIndex;
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
