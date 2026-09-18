import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/app_theme.dart';
import 'core/i_local_preferences.dart';
import 'core/local_preferences_secured.dart';
import 'core/local_preferences_shared.dart';
import 'features/auth/auth_dependencies.dart';
import 'features/auth/ui/auth_guard.dart';
import 'features/create_project/create_project_dependencies.dart';
import 'features/home/home_dependencies.dart';
import 'features/home/ui/views/home_page.dart';
import 'features/my_projects/my_projects_dependencies.dart';
import 'features/my_projects/ui/views/my_projects_page.dart';
import 'features/product/product_dependencies.dart';
import 'features/shared_projects/shared_projects_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  final ILocalPreferences preferences = kIsWeb
      ? LocalPreferencesShared()
      : LocalPreferencesSecured();
  Get.put<ILocalPreferences>(preferences, permanent: true);

  registerAuth();
  registerProduct();
  registerSharedProjects();
  registerHome();
  registerMyProjects();
  registerCreateProject();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Innovation Hub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const Central()),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: '/mis-proyectos',
          page: () => const MyProjectsPage(),
          middlewares: [AuthGuard()],
        ),
      ],
    );
  }
}
