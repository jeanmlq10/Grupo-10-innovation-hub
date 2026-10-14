import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/core/utils/time_ago.dart';
import 'package:f_clean_template/features/notifications/domain/models/app_notification.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/info_nav_tile.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/person_header.dart';
import 'package:f_clean_template/features/notifications/ui/widgets/quote_box.dart';
import 'package:f_clean_template/features/profile/ui/views/public_profile_page.dart';
import 'package:f_clean_template/features/profile/ui/views/user_participations_page.dart';
import 'package:f_clean_template/features/projects/domain/models/project.dart';
import 'package:f_clean_template/features/requests/domain/models/participation_request.dart';
import 'package:f_clean_template/features/requests/ui/viewmodels/requests_controller.dart';

/// "Solicitud de miembro" / "Postulación a tarea" para el creador
/// (Página 4.3, pantallas 4 y 5): quién es, su mensaje, enlaces a su perfil
/// y a sus participaciones, y Rechazar / Aceptar.
class RequestNotificationPage extends StatefulWidget {
  const RequestNotificationPage({super.key, required this.notification});

  final AppNotification notification;

  @override
  State<RequestNotificationPage> createState() =>
      _RequestNotificationPageState();
}

class _RequestNotificationPageState extends State<RequestNotificationPage> {
  final RequestsController _requests = Get.find();
  final NotificationsController _notifications = Get.find();

  late Future<(ParticipationRequest?, Project?)> _future;
  bool _deciding = false;

  AppNotification get _n => widget.notification;
  bool get _isTask => _n.type == AppNotificationType.taskApplication;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(ParticipationRequest?, Project?)> _load() async {
    final project = await _notifications.projectById(_n.projectId);
    final requestId = _n.requestId;
    final request = requestId == null
        ? null
        : await _requests.requestFor(_n.projectId, requestId);
    return (request, project);
  }

  Future<void> _decide(ParticipationRequest request, bool accept) async {
    if (_deciding) return;
    setState(() => _deciding = true);
    try {
      if (accept) {
        await _requests.acceptRequest(request);
      } else {
        await _requests.rejectRequest(request);
      }
      Get.back();
      Get.snackbar(
        accept ? '¡Listo!' : 'Solicitud rechazada',
        accept
            ? '${request.applicantName} ahora es parte del equipo.'
            : 'Le avisamos a ${request.applicantName}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Solicitudes',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<(ParticipationRequest?, Project?)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(errorMessage(snapshot.error!)));
            }
            final (request, project) = snapshot.data!;
            final applicantName =
                request?.applicantName ?? _n.actorName ?? 'Usuario';
            final applicantId = request?.applicantUserId ?? _n.actorUserId;
            final projectName = project?.name ?? 'tu proyecto';
            final role = request?.role ?? _n.detail ?? '';

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      PersonHeader(
                        name: applicantName,
                        lines: _isTask
                            ? ['se postuló a la tarea', role]
                            : ['quiere unirse a tu proyecto', projectName],
                        time: timeAgo(_n.createdAt),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isTask
                            ? 'Mensaje de postulación'
                            : 'Mensaje de presentación',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HomeColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      QuoteBox(
                        text: (request?.message ?? '').isEmpty
                            ? 'Sin mensaje.'
                            : request!.message,
                      ),
                      if (!_isTask && role.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Rol: $role',
                          style: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const Text(
                        'Información del usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HomeColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (applicantId != null) ...[
                        InfoNavTile(
                          label: 'Perfil',
                          onTap: () => Get.to(
                            () => PublicProfilePage(
                              userId: applicantId,
                              name: applicantName,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InfoNavTile(
                          label: 'Proyectos en los que ha participado',
                          onTap: () => Get.to(
                            () => UserParticipationsPage(
                              userId: applicantId,
                              name: applicantName,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: request == null
                      ? const Text(
                          'Esta solicitud ya no está disponible.',
                          style: TextStyle(color: HomeColors.textSecondary),
                        )
                      : request.status != RequestStatus.pending
                      ? Text(
                          request.status == RequestStatus.accepted
                              ? 'Ya aceptaste esta solicitud.'
                              : 'Ya rechazaste esta solicitud.',
                          style: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _deciding
                                    ? null
                                    : () => _decide(request, false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: HomeColors.primaryPurple,
                                  side: const BorderSide(
                                    color: HomeColors.primaryPurple,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text('Rechazar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _deciding
                                    ? null
                                    : () => _decide(request, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: HomeColors.primaryPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text('Aceptar'),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
