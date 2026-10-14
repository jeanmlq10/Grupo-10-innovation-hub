import 'package:get/get.dart';

import 'package:f_clean_template/features/auth/ui/auth_guard.dart';
import 'package:f_clean_template/features/auth/ui/views/central.dart';
import 'package:f_clean_template/features/projects/ui/views/home_page.dart';
import 'package:f_clean_template/features/notifications/ui/views/notifications_page.dart';
import 'package:f_clean_template/features/profile/ui/views/profile_page.dart';
import 'package:f_clean_template/features/projects/ui/views/my_projects_page.dart';
import 'package:f_clean_template/routes/app_routes.dart';

/// Las paginas con nombre. /home y /mis-proyectos exigen sesion (AuthGuard).
abstract class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.central, page: () => const Central()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.myProjects,
      page: () => const MyProjectsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      middlewares: [AuthGuard()],
    ),
  ];
}
