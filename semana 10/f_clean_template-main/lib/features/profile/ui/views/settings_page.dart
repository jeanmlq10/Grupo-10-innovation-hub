import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/profile/ui/views/edit_profile_page.dart';
import 'package:f_clean_template/features/profile/ui/views/notification_settings_page.dart';
import 'package:f_clean_template/features/profile/ui/views/privacy_page.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_menu_tile.dart';

/// "Configuración" del perfil.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _soon(String title) => Get.snackbar(
    title,
    'Esta opción estará disponible en una próxima versión.',
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          ProfileMenuTile(
            icon: Icons.person_outline,
            title: 'Cuenta',
            subtitle: 'Información personal',
            onTap: () => Get.to(() => const EditProfilePage()),
          ),
          ProfileMenuTile(
            icon: Icons.settings_suggest_outlined,
            title: 'Apariencia',
            subtitle: 'Tema, idioma, accesibilidad',
            onTap: () => _soon('Apariencia'),
          ),
          ProfileMenuTile(
            icon: Icons.notifications_none,
            title: 'Notificaciones',
            subtitle: 'Preferencias de notificaciones',
            onTap: () => Get.to(() => const NotificationSettingsPage()),
          ),
          ProfileMenuTile(
            icon: Icons.lock_outline,
            title: 'Privacidad',
            subtitle: 'Quién ve tu perfil y tu actividad',
            onTap: () => Get.to(() => const PrivacyPage()),
          ),
          ProfileMenuTile(
            icon: Icons.storage_outlined,
            title: 'Datos y almacenamiento',
            subtitle: 'Uso de datos, caché',
            onTap: () => _soon('Datos y almacenamiento'),
          ),
          ProfileMenuTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Centro de ayuda',
            onTap: () => Get.dialog(
              AlertDialog(
                title: const Text('Ayuda'),
                content: const Text(
                  'Publica tu idea desde "Crea otra idea", explora proyectos '
                  'y postúlate a una tarea o al equipo. El creador decide y '
                  'te avisamos en Notificaciones.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ),
          ),
          ProfileMenuTile(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión de la app',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Movil',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Programación Móvil · Uninorte · Grupo 10',
            ),
          ),
        ],
      ),
    );
  }
}
