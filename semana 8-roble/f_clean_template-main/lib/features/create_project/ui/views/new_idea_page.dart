import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/ui/home_colors.dart';
import '../viewmodels/create_project_controller.dart';
import '../widgets/idea_cloud_illustration.dart';
import 'basic_info_page.dart';

/// "Comencemos" (referred to as "Nueva idea" in the step overview) — the
/// first real step of the wizard. It only collects the idea's name; that
/// name then pre-fills "Información básica" via `CreateProjectController`.
///
/// This is a `StatefulWidget` purely to own the `TextEditingController`
/// (ephemeral text-editing/cursor state) — the actual business state
/// (the idea's name) lives in `CreateProjectController`, never here.
class NewIdeaPage extends StatefulWidget {
  const NewIdeaPage({super.key});

  @override
  State<NewIdeaPage> createState() => _NewIdeaPageState();
}

class _NewIdeaPageState extends State<NewIdeaPage> {
  final CreateProjectController controller = Get.find();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: controller.name.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!controller.canContinue) {
      Get.snackbar(
        'Falta el nombre',
        'Escribe el nombre de tu idea para continuar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => const BasicInfoPage());
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
              const SizedBox(height: 20),
              const Text(
                'Comencemos',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: HomeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu idea puede generar un gran cambio. Cuéntanos un poco sobre ella.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: HomeColors.textSecondary,
                  height: 1.35,
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IdeaCloudIllustration(size: 230),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                onChanged: controller.updateName,
                style: const TextStyle(color: HomeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nombre de tu idea',
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
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
