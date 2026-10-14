import 'package:flutter/material.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/core/utils/date_format.dart';

/// Campo de fecha límite ("30 oct 2026" con el icono de calendario).
/// Al tocarlo abre el calendario; solo deja elegir desde hoy en adelante.
/// Solo presentación: la fecha elegida se entrega por [onPicked].
class DeadlinePickerField extends StatelessWidget {
  const DeadlinePickerField({
    super.key,
    required this.value,
    required this.onPicked,
    this.placeholder = 'Elegir fecha',
  });

  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final String placeholder;

  Future<void> _pick(BuildContext context) async {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day);
    final current = value;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(first) ? current : first,
      firstDate: first,
      lastDate: DateTime(today.year + 3, 12, 31),
      helpText: 'Fecha límite',
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final date = value;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: HomeColors.borderGrey),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: HomeColors.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  date == null ? placeholder : formatShortDate(date),
                  style: TextStyle(
                    fontSize: 14,
                    color: date == null
                        ? HomeColors.textSecondary
                        : HomeColors.textPrimary,
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
