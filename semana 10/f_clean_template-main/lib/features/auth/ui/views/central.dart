import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/views/welcome_page.dart';
import 'package:f_clean_template/features/projects/ui/views/home_page.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationController authenticationController = Get.find();
    return Obx(() {
      if (authenticationController.isRestoring) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Con sesión, o como visitante ("Continuar como visitante"), se ve
      // Explorar proyectos; si no, la bienvenida.
      return authenticationController.canBrowse
          ? const HomePage()
          : const WelcomePage();
    });
  }
}
