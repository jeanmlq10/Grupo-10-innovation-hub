import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'viewmodels/authentication_controller.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthenticationController>();
    if (auth.isLogged || auth.isRestoring) return null;

    return const RouteSettings(name: '/');
  }
}
