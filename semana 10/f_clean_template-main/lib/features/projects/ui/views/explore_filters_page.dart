import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/projects/domain/models/explore_filters.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/home_controller.dart';
import 'package:f_clean_template/features/projects/ui/widgets/explore_filter_labels.dart';
import 'package:f_clean_template/features/projects/ui/widgets/filter_option_chip.dart';

/// "Filtros" de Explorar proyectos (requerimiento 1.2).
///
/// Se edita una copia local ([_draft]); nada cambia en Explorar hasta tocar
/// "Aplicar filtros", que se la entrega a [HomeController.applyFilters].
/// Los filtros aplican tanto en "Todos" como en "Seguidos".
class ExploreFiltersPage extends StatefulWidget {
  const ExploreFiltersPage({super.key});

  @override
  State<ExploreFiltersPage> createState() => _ExploreFiltersPageState();
}

class _ExploreFiltersPageState extends State<ExploreFiltersPage> {
  final HomeController _controller = Get.find();
  late ExploreFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = _controller.filters.value;
  }

  void _apply() {
    _controller.applyFilters(_draft);
    Get.back();
  }

  void _clear() => setState(() => _draft = ExploreFilters.none);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: HomeColors.flowNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: HomeColors.flowNavy),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _Section(
                    title: 'Fecha de creación',
                    icon: Icons.calendar_month_outlined,
                    children: [
                      for (final option in CreationDateFilter.values)
                        FilterOptionChip(
                          label: ExploreFilterLabels.creationDate[option]!,
                          selected: _draft.creationDate == option,
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(creationDate: option),
                          ),
                        ),
                    ],
                  ),
                  _Section(
                    title: 'Disponibilidad de tareas',
                    icon: Icons.check_box_outlined,
                    children: [
                      for (final option in TaskAvailabilityFilter.values)
                        FilterOptionChip(
                          label: ExploreFilterLabels.taskAvailability[option]!,
                          selected: _draft.taskAvailability == option,
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(
                              taskAvailability: option,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _Section(
                    title: 'Disponibilidad de miembros',
                    icon: Icons.group_outlined,
                    children: [
                      for (final option in MemberAvailabilityFilter.values)
                        FilterOptionChip(
                          label:
                              ExploreFilterLabels.memberAvailability[option]!,
                          selected: _draft.memberAvailability == option,
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(
                              memberAvailability: option,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _Section(
                    title: 'Rol del proyecto',
                    icon: Icons.manage_accounts_outlined,
                    children: [
                      // "Todos" = ningún rol marcado. Se pueden marcar varios.
                      FilterOptionChip(
                        label: 'Todos',
                        selected: _draft.roles.isEmpty,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(roles: const {}),
                        ),
                      ),
                      for (final role in ProjectRoleFilter.values)
                        FilterOptionChip(
                          label: ExploreFilterLabels.roles[role]!,
                          selected: _draft.roles.contains(role),
                          onTap: () => setState(
                            () => _draft = _draft.toggleRole(role),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.flowPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeColors.flowPurple,
                        backgroundColor: HomeColors.flowLavenderFaint,
                        side: const BorderSide(color: HomeColors.flowBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Limpiar filtros'),
                    ),
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

/// Un grupo del panel: título, icono a la derecha y sus opciones.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.flowNavy,
                  ),
                ),
              ),
              Icon(icon, color: HomeColors.flowPurple, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
