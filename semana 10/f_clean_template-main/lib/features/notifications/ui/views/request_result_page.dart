import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/quote_box.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/projects/ui/views/project_detail_page.dart';
import 'package:f_clean_template/routes/app_routes.dart';

/// Respuesta para quien pidió participar (Página 4.2, pantallas 9 a 12):
/// solicitud o postulación, aceptada o rechazada, con el proyecto y qué
/// puede hacer ahora.
class RequestResultPage extends StatefulWidget {
  const RequestResultPage({super.key, required this.notification});

  final AppNotification notification;

  @override
  State<RequestResultPage> createState() => _RequestResultPageState();
}

class _RequestResultPageState extends State<RequestResultPage> {
  final NotificationsController _controller = Get.find();
  late final Future<Project?> _project;

  AppNotification get _n => widget.notification;

  @override
  void initState() {
    super.initState();
    _project = _controller.projectById(_n.projectId);
  }

  void _openProject(Project? project) {
    if (project == null) return;
    Get.off(() => ProjectDetailPage(project: project));
  }

  @override
  Widget build(BuildContext context) {
    final accepted = _n.isAccepted;
    final task = _n.isAboutTask;
    final detail = _n.detail ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Project?>(
          future: _project,
          builder: (context, snapshot) {
            final project = snapshot.data;
            final projectName = project?.name ?? 'el proyecto';
            final String title;
            final String subtitle;
            final String hint;
            final String button;
            if (accepted && task) {
              title = '¡Listo!';
              subtitle = 'Fuiste asignado a la tarea\n$detail';
              hint =
                  'Ya puedes ver los detalles de la tarea y comenzar a '
                  'trabajar en ella.';
              button = 'Ver tarea';
            } else if (accepted) {
              title = '¡Listo!';
              subtitle = 'Fuiste aceptado en el proyecto\n$projectName';
              hint =
                  'Ahora puedes acceder al proyecto y comenzar a colaborar '
                  'con el equipo.';
              button = 'Ir al proyecto';
            } else if (task) {
              title = 'Postulación rechazada';
              subtitle =
                  'Tu postulación para la tarea $detail no fue aceptada.';
              hint =
                  'Puedes seguir explorando otras tareas dentro del proyecto '
                  'o en otros proyectos.';
              button = 'Explorar proyectos';
            } else {
              title = 'Solicitud rechazada';
              subtitle =
                  'Tu solicitud para unirte al proyecto $projectName no fue '
                  'aceptada.';
              hint =
                  'Puedes seguir explorando otros proyectos o postularte a '
                  'nuevas oportunidades.';
              button = 'Explorar proyectos';
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accepted ? HomeColors.primaryPurple : Colors.white,
                      border: accepted
                          ? null
                          : Border.all(color: const Color(0xFFE35D5B), width: 3),
                    ),
                    child: Icon(
                      accepted ? Icons.check_rounded : Icons.close_rounded,
                      size: 48,
                      color: accepted ? Colors.white : const Color(0xFFE35D5B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: HomeColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: HomeColors.borderGrey),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEFE1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: Color(0xFF3E8E5A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: HomeColors.textPrimary,
                                ),
                              ),
                              if (detail.isNotEmpty)
                                Text(
                                  detail,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: HomeColors.textSecondary,
                                  ),
                                ),
                              if (project != null)
                                GestureDetector(
                                  onTap: () => _openProject(project),
                                  child: const Text(
                                    'Ver proyecto >',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: HomeColors.primaryPurple,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  QuoteBox(text: hint),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: accepted
                          ? () => _openProject(project)
                          : () => Get.offAllNamed(AppRoutes.home),
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        button,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
