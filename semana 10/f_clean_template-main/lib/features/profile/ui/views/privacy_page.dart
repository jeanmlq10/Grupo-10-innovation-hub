import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/profile/domain/models/user_profile.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_menu_tile.dart';

/// "Privacidad": quién ve el perfil, quién puede escribir, quién ve la
/// actividad, descargar los datos y eliminar la cuenta.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  Future<T?> _choose<T>(String title, Map<T, String> options) =>
      Get.dialog<T>(
        SimpleDialog(
          title: Text(title),
          children: [
            for (final entry in options.entries)
              SimpleDialogOption(
                onPressed: () => Get.back(result: entry.key),
                child: Text(entry.value),
              ),
          ],
        ),
      );

  static const _visibility = {
    ProfileVisibility.public: 'Público',
    ProfileVisibility.private: 'Privado',
  };
  static const _contact = {
    ContactPermission.everyone: 'Todos los usuarios',
    ContactPermission.nobody: 'Nadie',
  };
  static const _activity = {
    ActivityVisibility.onlyMe: 'Solo yo',
    ActivityVisibility.everyone: 'Todos los usuarios',
  };

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Privacidad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final p = controller.profile.value;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            ProfileMenuTile(
              icon: Icons.person_outline,
              title: 'Visibilidad del perfil',
              subtitle: _visibility[p?.visibility ?? ProfileVisibility.public],
              onTap: () async {
                final value = await _choose('Visibilidad del perfil', _visibility);
                if (value != null) controller.savePrivacy(visibility: value);
              },
            ),
            ProfileMenuTile(
              icon: Icons.verified_user_outlined,
              title: 'Quién puede contactarte',
              subtitle: _contact[p?.contact ?? ContactPermission.everyone],
              onTap: () async {
                final value = await _choose('Quién puede contactarte', _contact);
                if (value != null) controller.savePrivacy(contact: value);
              },
            ),
            ProfileMenuTile(
              icon: Icons.schedule,
              title: 'Datos de actividad',
              subtitle:
                  _activity[p?.activityVisibility ?? ActivityVisibility.everyone],
              onTap: () async {
                final value = await _choose('Datos de actividad', _activity);
                if (value != null) {
                  controller.savePrivacy(activityVisibility: value);
                }
              },
            ),
            ProfileMenuTile(
              icon: Icons.download_outlined,
              title: 'Descargar mis datos',
              subtitle: 'Solicitar un archivo',
              onTap: () {
                final data = controller.exportMyData();
                Get.dialog(
                  AlertDialog(
                    title: const Text('Mis datos'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        data,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: data));
                          Get.back();
                          Get.snackbar('Mis datos', 'Copiados al portapapeles.');
                        },
                        child: const Text('Copiar'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ProfileMenuTile(
              icon: Icons.delete_outline,
              title: 'Eliminar cuenta',
              subtitle: 'Eliminar permanentemente',
              destructive: true,
              onTap: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('¿Eliminar cuenta?'),
                    content: const Text(
                      'Se borrarán los datos de tu perfil y se cerrará tu '
                      'sesión. Tus proyectos y comentarios se conservan. La '
                      'cuenta de acceso la elimina el administrador de Roble.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Color(0xFFD9534F)),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true && await controller.deleteProfileData()) {
                  Get.offAllNamed('/');
                }
              },
            ),
          ],
        );
      }),
    );
  }
}
