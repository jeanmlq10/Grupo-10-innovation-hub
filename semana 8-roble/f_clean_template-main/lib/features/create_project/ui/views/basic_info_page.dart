import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/step_progress_bar.dart';
import 'team_needed_page.dart';

/// "Información básica" — step 1 of 4 in the wizard's numbered progress
/// bar (the overview screen's step 1, "Información básica", covers
/// steps 1-4 of the progress bar shown here; "Equipo necesario", "Tiempo
/// estimado", "Audiencia" and "Revisar y publicar" are the remaining 2/4,
/// 3/4 and 4/4 steps, not implemented yet).
///
/// Deliberately has NO category field — the assignment explicitly says
/// the category shown in the "Crear proyecto" overview text will be
/// removed later, so it was never added here in the first place.
class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final CreateProjectController controller = Get.find();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Pre-filled with whatever was typed in "Nueva idea" — this is the
    // carry-over the assignment asked to verify.
    _nameController = TextEditingController(text: controller.name.value);
    _descriptionController = TextEditingController(
      text: controller.description.value,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
                    child: StepProgressBar(currentStep: 1, totalSteps: 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Información básica',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cuéntanos sobre tu proyecto',
                style: TextStyle(fontSize: 14.5, color: HomeColors.textSecondary),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCEFE1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: Color(0xFF3E8E5C),
                                size: 34,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Get.snackbar(
                                  'Imagen del proyecto',
                                  'Subir una imagen llega en una próxima entrega.',
                                  snackPosition: SnackPosition.BOTTOM,
                                ),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: HomeColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Nombre del proyecto',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: HomeColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        onChanged: controller.updateName,
                        style: const TextStyle(color: HomeColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ej. Mi proyecto',
                          hintStyle: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
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
                      const SizedBox(height: 18),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: HomeColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        onChanged: controller.updateDescription,
                        maxLines: 4,
                        style: const TextStyle(color: HomeColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Describe tu proyecto...',
                          hintStyle: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const TeamNeededPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Siguiente',
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
