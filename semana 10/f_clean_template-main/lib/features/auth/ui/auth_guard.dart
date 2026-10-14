import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthenticationController>();
    if (auth.isLogged || auth.isRestoring) return null;

    // Visitante: solo puede entrar a Explorar proyectos (solo lectura).
    if (auth.isGuest && route == AppRoutes.home) return null;

    return const RouteSettings(name: '/');
  }
}
