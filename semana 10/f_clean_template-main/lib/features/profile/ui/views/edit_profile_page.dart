import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/widgets/avatar_icon_picker.dart';
import 'package:f_clean_template/features/profile/ui/widgets/profile_avatar.dart';

/// "Editar perfil": nombre, usuario, biografía y carrera se guardan en
/// Roble (`user_profiles`). El correo es el de la cuenta (no se edita) y la
/// contraseña se cambia con el correo de recuperación de Roble.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController _controller = Get.find();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  late final TextEditingController _career;

  /// Icono elegido (se guarda en Roble al tocar "Guardar cambios").
  String _avatarIcon = '';

  @override
  void initState() {
    super.initState();
    final p = _controller.profile.value;
    _name = TextEditingController(text: p?.name ?? '');
    _username = TextEditingController(text: p?.username ?? '');
    _bio = TextEditingController(text: p?.bio ?? '');
    _career = TextEditingController(text: p?.career ?? '');
    _avatarIcon = p?.avatarIcon ?? '';
  }

  Future<void> _pickIcon() async {
    final picked = await showAvatarIconPicker(_avatarIcon);
    if (picked != null && mounted) setState(() => _avatarIcon = picked);
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    _career.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await _controller.saveBasics(
      name: _name.text,
      username: _username.text,
      bio: _bio.text,
      career: _career.text,
      avatarIcon: _avatarIcon,
    );
    if (!ok) return;
    Get.back();
    Get.snackbar(
      'Perfil',
      'Tus cambios se guardaron.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _changePassword() async {
    final ok = await _controller.requestPasswordChange();
    Get.snackbar(
      'Contraseña',
      ok
          ? 'Te enviamos un correo para cambiar tu contraseña.'
          : 'No se pudo enviar el correo. Intenta más tarde.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: HomeColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final email = _controller.profile.value?.email ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Guardar',
            onPressed: _save,
            icon: const Icon(Icons.check, color: HomeColors.primaryPurple),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Tocar la foto abre el selector de iconos.
          Center(
            child: GestureDetector(
              onTap: _pickIcon,
              child: Stack(
                children: [
                  ProfileAvatar(
                    name: _name.text,
                    iconKey: _avatarIcon,
                    size: 88,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: HomeColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _pickIcon,
              child: const Text('Cambiar icono'),
            ),
          ),
          const SizedBox(height: 20),
          _field('Nombre', _name),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    fontSize: 13,
                    color: HomeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _field('Nombre de usuario', _username),
          _field('Carrera o programa', _career),
          _field('Biografía', _bio, hint: 'Cuéntanos sobre ti...', maxLines: 3),
          const Text(
            'Contraseña',
            style: TextStyle(fontSize: 13, color: HomeColors.textSecondary),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _changePassword,
            icon: const Icon(Icons.lock_reset),
            label: const Text('Cambiar contraseña'),
          ),
          const SizedBox(height: 24),
          Obx(
            () => SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _controller.isSaving.value ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: HomeColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
