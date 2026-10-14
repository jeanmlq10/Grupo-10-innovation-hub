import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/auth/ui/widgets/login_required_dialog.dart';
import 'package:f_clean_template/routes/app_routes.dart';

/// Barra inferior "Explorar | Mis proyectos | Notificaciones | Perfil".
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key, this.currentIndex = 0});

  final int currentIndex;

  static const _tabs = [
    _TabData(icon: Icons.explore_outlined, label: 'Explorar'),
    _TabData(icon: Icons.folder_shared_outlined, label: 'Mis proyectos'),
    _TabData(
      icon: Icons.notifications_none,
      label: 'Notificaciones',
      hasBadge: true,
    ),
    _TabData(icon: Icons.person_outline, label: 'Perfil'),
  ];

  void _onTabTapped(int index) {
    if (index == currentIndex) return;
    if (index != 0 && !requireSession()) return;
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home);
        break;
      case 1:
        Get.offNamed(AppRoutes.myProjects);
        break;
      case 2:
        Get.offNamed(AppRoutes.notifications);
        break;
      case 3:
        Get.offNamed(AppRoutes.profile);
        break;
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
                    color: HomeColors.flowAccent,
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
