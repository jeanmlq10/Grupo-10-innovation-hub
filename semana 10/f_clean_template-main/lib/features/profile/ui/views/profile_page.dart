import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:f_clean_template/features/messages/ui/views/messages_page.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/views/activity_history_page.dart';
import 'package:f_clean_template/features/profile/ui/views/edit_profile_page.dart';
import 'package:f_clean_template/features/profile/ui/views/logout_page.dart';
import 'package:f_clean_template/features/profile/ui/views/my_ideas_page.dart';
import 'package:f_clean_template/features/profile/ui/views/notification_settings_page.dart';
import 'package:f_clean_template/features/profile/ui/views/privacy_page.dart';
import 'package:f_clean_template/features/profile/ui/views/settings_page.dart';
import 'package:f_clean_template/features/profile/ui/views/trajectory_page.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_avatar.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_menu_tile.dart';
import 'package:f_clean_template/features/profile/ui/widgets/trajectory_stats_grid.dart';
import 'package:f_clean_template/routes/app_routes.dart';

/// "Perfil" (Página 5): datos del usuario, resumen de trayectoria y el
/// menú hacia el resto de pantallas del perfil.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.loadMine());
  }

  /// Abre una pantalla y al volver recarga (pudo cambiar algo).
  Future<void> _go(Widget Function() page) async {
    await Get.to(page);
    _controller.loadMine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadMine,
          child: Obx(() {
            final profile = _controller.profile.value;
            final loading = _controller.isLoading.value && profile == null;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  // Tarjeta con nombre y "Editar perfil".
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: HomeColors.borderGrey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ProfileAvatar(
                          name: profile?.name ?? '',
                          iconKey: profile?.avatarIcon,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: HomeColors.textPrimary,
                                ),
                              ),
                              Text(
                                _controller.roleLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: HomeColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _go(() => const EditProfilePage()),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Editar perfil'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: HomeColors.textPrimary,
                                  visualDensity: VisualDensity.compact,
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_controller.loadError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _controller.loadError.value,
                        style: const TextStyle(color: Color(0xFFD9534F)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Resumen de trayectoria',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const TrajectoryPage()),
                        child: const Text('Ver más >'),
                      ),
                    ],
                  ),
                  TrajectoryStatsGrid(summary: _controller.summary.value),
                  const SizedBox(height: 14),
                  ProfileMenuTile(
                    icon: Icons.folder_open_outlined,
                    title: 'Mis proyectos',
                    onTap: () => Get.toNamed(AppRoutes.myProjects),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lightbulb_outline,
                    title: 'Mis ideas',
                    onTap: () => _go(() => const MyIdeasPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.history,
                    title: 'Historial de actividad',
                    onTap: () => Get.to(() => const ActivityHistoryPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Mensajes',
                    onTap: () => Get.to(() => const MessagesPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    onTap: () => _go(() => const SettingsPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notificaciones',
                    onTap: () => _go(() => const NotificationSettingsPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline,
                    title: 'Privacidad',
                    onTap: () => _go(() => const PrivacyPage()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    destructive: true,
                    onTap: () => Get.to(() => const LogoutPage()),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
