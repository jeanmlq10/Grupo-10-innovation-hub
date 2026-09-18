import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../home/ui/home_colors.dart';
import '../viewmodels/project_application_controller.dart';
import 'request_sent_page.dart';

/// "Envía tu solicitud" — the shared destination for both "Unirme al
/// equipo" (no [initialRole]) and "Postularme a una tarea" (arrives with
/// [initialRole] already set from "Tareas disponibles"). One form
/// instead of two nearly-identical screens.
class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key, required this.project, this.initialRole});

  final Project project;
  final String? initialRole;

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  late final TextEditingController _messageController;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRole == null) {
      Get.snackbar(
        'Falta el rol',
        'Selecciona a qué rol quieres aplicar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Falta el mensaje',
        'Cuéntanos por qué quieres unirte al equipo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.find<ProjectApplicationController>().submitRequest(
      projectId: widget.project.id,
      role: _selectedRole!,
      message: _messageController.text.trim(),
    );
    Get.to(() => const RequestSentPage());
  }

  @override
  Widget build(BuildContext context) {
    final roles = widget.project.teamRoles.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Envía tu solicitud',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cuéntanos por qué quieres unirte al equipo.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                style: const TextStyle(color: HomeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: const TextStyle(color: HomeColors.textSecondary),
                  filled: true,
                  fillColor: HomeColors.surfaceGrey,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rol al que aplicas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: HomeColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    hint: const Text(
                      'Selecciona un rol',
                      style: TextStyle(color: HomeColors.textSecondary),
                    ),
                    items: roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Enviar solicitud',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
