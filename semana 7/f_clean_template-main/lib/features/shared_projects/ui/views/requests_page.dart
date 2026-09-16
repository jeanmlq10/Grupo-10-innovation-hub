import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../../domain/models/participation_request.dart';
import '../../domain/repositories/i_shared_projects_repository.dart';

/// "Solicitudes" — every participation request across every project the
/// user owns, split into three tabs. There's no per-user login in this
/// app, so this simply shows every request that exists locally rather
/// than filtering by "projects I created" — in the single-device test
/// flow described for this stage, that's the same set anyway.
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin {
  final ISharedProjectsRepository repository = Get.find();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ParticipationRequest> _byStatus(RequestStatus status) => repository
      .allRequests()
      .where((request) => request.status == status)
      .toList();

  void _accept(String requestId) {
    repository.acceptRequest(requestId);
    setState(() {});
  }

  void _reject(String requestId) {
    repository.rejectRequest(requestId);
    setState(() {});
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RequestList(
                    requests: _byStatus(RequestStatus.pending),
                    emptyMessage: 'No tienes solicitudes pendientes.',
                    onAccept: _accept,
                    onReject: _reject,
                  ),
                  _RequestList(
                    requests: _byStatus(RequestStatus.accepted),
                    emptyMessage: 'Todavía no aceptas ninguna solicitud.',
                  ),
                  _RequestList(
                    requests: _byStatus(RequestStatus.rejected),
                    emptyMessage: 'No has rechazado ninguna solicitud.',
                  ),
                ],
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
  });

  final List<ParticipationRequest> requests;
  final String emptyMessage;
  final ValueChanged<String>? onAccept;
  final ValueChanged<String>? onReject;

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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                          request.role,
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
                        onPressed: () => onReject!(request.id),
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
                        onPressed: () => onAccept!(request.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Aceptar'),
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
