import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/error_message.dart';
import '../../../home/ui/home_colors.dart';
import '../../domain/models/participation_request.dart';
import '../viewmodels/project_application_controller.dart';

/// "Solicitudes" — participation requests received on the projects the
/// logged-in user created (read from Roble), split into three tabs. Only
/// the creator can accept or reject; that is also enforced when saving.
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin {
  final ProjectApplicationController _controller = Get.find();
  late final TabController _tabController;
  late Future<List<ParticipationRequest>> _future;

  /// Request being accepted/rejected right now (its buttons show loading).
  String? _processingId;

  /// Decisions taken in this screen, applied immediately so the request
  /// leaves "Pendientes" at once and can never be decided twice.
  final Map<String, RequestStatus> _decided = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = _controller.requestsForMyProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = _controller.requestsForMyProjects());
  }

  Future<void> _decide(ParticipationRequest request, bool accept) async {
    if (_decided.containsKey(request.id)) {
      Get.snackbar(
        'Solicitudes',
        _decided[request.id] == RequestStatus.accepted
            ? 'Esta solicitud ya fue aceptada.'
            : 'Esta solicitud ya fue rechazada.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // Only one decision at a time; extra taps while it loads do nothing.
    if (_processingId != null) return;
    setState(() => _processingId = request.id);
    try {
      if (accept) {
        await _controller.acceptRequest(request);
      } else {
        await _controller.rejectRequest(request);
      }
      if (!mounted) return;
      setState(() {
        _decided[request.id] = accept
            ? RequestStatus.accepted
            : RequestStatus.rejected;
      });
      Get.snackbar(
        'Solicitudes',
        accept
            ? '${request.applicantName} ahora es parte del equipo.'
            : 'Solicitud rechazada.',
        snackPosition: SnackPosition.BOTTOM,
      );
      _reload();
    } catch (error, stack) {
      debugPrint('RequestsPage: decision failed: $error\n$stack');
      Get.snackbar(
        'Solicitudes',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
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
                  const SizedBox(width: 8),
                  const Text(
                    'Solicitudes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: HomeColors.primaryPurple,
              unselectedLabelColor: HomeColors.textSecondary,
              indicatorColor: HomeColors.primaryPurple,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              tabs: const [
                Tab(text: 'Pendientes'),
                Tab(text: 'Aceptadas'),
                Tab(text: 'Rechazadas'),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<ParticipationRequest>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        errorMessage(snapshot.error!),
                        style: const TextStyle(
                          color: HomeColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  final all = (snapshot.data ?? const <ParticipationRequest>[])
                      .map(
                        (request) => _decided.containsKey(request.id)
                            ? request.copyWith(status: _decided[request.id])
                            : request,
                      )
                      .toList();
                  List<ParticipationRequest> byStatus(RequestStatus status) =>
                      all.where((request) => request.status == status).toList();
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _RequestList(
                        requests: byStatus(RequestStatus.pending),
                        emptyMessage: 'No tienes solicitudes pendientes.',
                        processingId: _processingId,
                        onAccept: (request) => _decide(request, true),
                        onReject: (request) => _decide(request, false),
                      ),
                      _RequestList(
                        requests: byStatus(RequestStatus.accepted),
                        emptyMessage: 'Todavía no aceptas ninguna solicitud.',
                      ),
                      _RequestList(
                        requests: byStatus(RequestStatus.rejected),
                        emptyMessage: 'No has rechazado ninguna solicitud.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.requests,
    required this.emptyMessage,
    this.onAccept,
    this.onReject,
    this.processingId,
  });

  /// While set, every Aceptar/Rechazar is disabled and this one spins.
  final String? processingId;

  final List<ParticipationRequest> requests;
  final String emptyMessage;
  final ValueChanged<ParticipationRequest>? onAccept;
  final ValueChanged<ParticipationRequest>? onReject;

  /// "Tarea: X · Proyecto" or "Equipo: X · Proyecto".
  static String _subtitle(ParticipationRequest request) {
    final kind = request.type == RequestType.task ? 'Tarea' : 'Equipo';
    final project = request.projectName ?? '';
    return project.isEmpty
        ? '$kind: ${request.role}'
        : '$kind: ${request.role} · $project';
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: HomeColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: HomeColors.borderGrey),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: HomeColors.navSelectedBackground,
                    child: Icon(
                      Icons.person,
                      color: HomeColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.applicantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: HomeColors.textPrimary,
                          ),
                        ),
                        Text(
                          _subtitle(request),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: HomeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.message,
                style: const TextStyle(
                  fontSize: 13,
                  color: HomeColors.textPrimary,
                  height: 1.3,
                ),
              ),
              if (onAccept != null && onReject != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: processingId != null
                            ? null
                            : () => onReject!(request),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomeColors.textPrimary,
                          side: const BorderSide(color: HomeColors.borderGrey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: processingId != null
                            ? null
                            : () => onAccept!(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeColors.primaryPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: HomeColors.primaryPurple
                              .withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: processingId == request.id
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
