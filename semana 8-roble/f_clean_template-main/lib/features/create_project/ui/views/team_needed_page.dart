import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/team_role_tile.dart';
import '../widgets/wizard_nav_buttons.dart';
import 'estimated_time_page.dart';

/// "Equipo necesario" — step 2 of 4. Lets the user say how many of each
/// role the project needs. No role is mandatory: the reference doesn't
/// require a minimum team, so "Siguiente" always proceeds regardless of
/// whether any counter was touched.
///
/// A `StatefulWidget` only for the "Otro" text field's
/// `TextEditingController` — same reasoning as "Nueva idea"/"Información
/// básica": the ephemeral text-editing state lives here, the real data
/// (`otherRoleName`) lives on `CreateProjectController`.
class TeamNeededPage extends StatefulWidget {
  const TeamNeededPage({super.key});

  static const _roles = [
    _RoleInfo(
      role: 'Desarrollador/a',
      subtitle: 'Se encarga del desarrollo técnico',
      icon: Icons.code,
      background: Color(0xFFE9E4F7),
      iconColor: Color(0xFF6A4FC0),
    ),
    _RoleInfo(
      role: 'Diseñador/a',
      subtitle: 'Apoya con la parte visual',
      icon: Icons.palette_outlined,
      background: Color(0xFFFBE4EC),
      iconColor: Color(0xFFD6598A),
    ),
    _RoleInfo(
      role: 'Investigador/a',
      subtitle: 'Busca y analiza información',
      icon: Icons.search,
      background: Color(0xFFFCEEDD),
      iconColor: Color(0xFFE0A23C),
    ),
    _RoleInfo(
      role: 'Comunicador/a',
      subtitle: 'Maneja la difusión del proyecto',
      icon: Icons.campaign_outlined,
      background: Color(0xFFFBE1DE),
      iconColor: Color(0xFFD9695B),
    ),
    _RoleInfo(
      role: 'Líder de proyecto',
      subtitle: 'Coordina el equipo',
      icon: Icons.person_outline,
      background: Color(0xFFFCEEDD),
      iconColor: Color(0xFFE0A23C),
    ),
    _RoleInfo(
      role: 'Otro',
      subtitle: 'Especifica el rol',
      icon: Icons.more_horiz,
      background: Color(0xFFECECEC),
      iconColor: Color(0xFF8D8D8D),
    ),
  ];

  @override
  State<TeamNeededPage> createState() => _TeamNeededPageState();
}

class _TeamNeededPageState extends State<TeamNeededPage> {
  final CreateProjectController controller = Get.find();
  late final TextEditingController _otherRoleController;

  @override
  void initState() {
    super.initState();
    _otherRoleController = TextEditingController(
      text: controller.otherRoleName.value,
    );
  }

  @override
  void dispose() {
    _otherRoleController.dispose();
    super.dispose();
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
              Row(
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
                  const Expanded(
                    child: StepProgressBar(currentStep: 2, totalSteps: 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Equipo necesario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Qué miembros necesitas?',
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final role in TeamNeededPage._roles) ...[
                          TeamRoleTile(
                            icon: role.icon,
                            iconBackground: role.background,
                            iconColor: role.iconColor,
                            title: role.role,
                            subtitle: role.subtitle,
                            count: controller.roleCount(role.role),
                            onIncrement: () =>
                                controller.incrementRole(role.role),
                            onDecrement: () =>
                                controller.decrementRole(role.role),
                          ),
                          if (role.role == 'Otro' &&
                              controller.roleCount('Otro') > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                                left: 4,
                                right: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '¿Qué rol necesitas?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: HomeColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _otherRoleController,
                                    onChanged: controller.setOtherRoleName,
                                    style: const TextStyle(
                                      color: HomeColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Especifica el rol',
                                      hintStyle: const TextStyle(
                                        color: HomeColors.textSecondary,
                                      ),
                                      filled: true,
                                      fillColor: HomeColors.surfaceGrey,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              WizardNavButtons(
                onBack: () => Get.back(),
                onNext: () => Get.to(() => const EstimatedTimePage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleInfo {
  const _RoleInfo({
    required this.role,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final String role;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color iconColor;
}
