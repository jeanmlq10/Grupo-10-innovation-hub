import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/domain/models/project.dart';
import '../../../../core/error_message.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/models/project_task.dart';
import '../../domain/models/project_team_role.dart';
import '../viewmodels/project_application_controller.dart';
import 'request_sent_page.dart';

/// "Envía tu solicitud" — shared by the two ways of participating:
/// - with a [task]: "Postularme a una tarea" (request type `task`);
/// - without it: "Unirme al equipo", choosing one of the project's open
///   team roles loaded from Roble (request type `team`).
class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({
    super.key,
    required this.project,
    this.task,
    this.initialRoleName,
  });

  final Project project;
  final ProjectTask? task;

  /// Team role to preselect (when opened from a role in "Miembros").
  final String? initialRoleName;

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final ProjectApplicationController _controller = Get.find();
  late final TextEditingController _messageController;
  Future<List<ProjectTeamRole>>? _rolesFuture;
  ProjectTeamRole? _selectedRole;
  bool _sending = false;

  bool get _isTask => widget.task != null;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    if (!_isTask) {
      _rolesFuture = _controller.rolesFor(widget.project.id).then((roles) {
        final open = roles.where((role) => role.hasSpots).toList();
        final initial = open.where(
          (role) => role.role == widget.initialRoleName,
        );
        if (initial.isNotEmpty && mounted) {
          setState(() => _selectedRole = initial.first);
        }
        return open;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (!_isTask && _selectedRole == null) {
      Get.snackbar(
        'Falta el rol',
        'Selecciona a qué rol quieres aplicar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar(
        'Falta el mensaje',
        _isTask
            ? 'Cuéntanos por qué quieres ayudar en esta tarea.'
            : 'Cuéntanos por qué quieres unirte al equipo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _sending = true);
    try {
      if (_isTask) {
        await _controller.submitTaskRequest(
          project: widget.project,
          task: widget.task!,
          message: message,
        );
      } else {
        await _controller.submitTeamRequest(
          project: widget.project,
          role: _selectedRole!,
          message: message,
        );
      }
      Get.to(() => const RequestSentPage());
    } catch (error) {
      Get.snackbar(
        'No se pudo enviar',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _roleSelector() {
    if (_isTask) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: HomeColors.surfaceGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.task!.title,
          style: const TextStyle(color: HomeColors.textPrimary),
        ),
      );
    }
    return FutureBuilder<List<ProjectTeamRole>>(
      future: _rolesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final roles = snapshot.data ?? const <ProjectTeamRole>[];
        if (snapshot.hasError || roles.isEmpty) {
          return Text(
            snapshot.hasError
                ? errorMessage(snapshot.error!)
                : 'Este proyecto no tiene roles disponibles en este momento.',
            style: const TextStyle(color: HomeColors.textSecondary),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: HomeColors.surfaceGrey,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole?.id,
              isExpanded: true,
              hint: const Text(
                'Selecciona un rol',
                style: TextStyle(color: HomeColors.textSecondary),
              ),
              items: roles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role.id,
                      child: Text(role.role),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(
                () => _selectedRole = roles.firstWhere(
                  (role) => role.id == value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                _isTask
                    ? 'Cuéntanos por qué quieres ayudar en esta tarea.'
                    : 'Cuéntanos por qué quieres unirte al equipo.',
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
              Text(
                _isTask ? 'Tarea a la que te postulas' : 'Rol al que aplicas',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _roleSelector(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
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
