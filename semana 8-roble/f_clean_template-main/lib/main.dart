import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'core/app_theme.dart';
import 'core/i_local_preferences.dart';
import 'core/local_preferences_secured.dart';
import 'core/local_preferences_shared.dart';

import 'features/auth/auth_dependencies.dart';
import 'features/create_project/create_project_dependencies.dart';
import 'features/product/product_dependencies.dart';
import 'features/home/home_dependencies.dart';
import 'features/home/ui/views/home_page.dart';
import 'features/my_projects/my_projects_dependencies.dart';
import 'features/my_projects/ui/views/my_projects_page.dart';
import 'features/shared_projects/shared_projects_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  final ILocalPreferences preferences = kIsWeb
      ? LocalPreferencesShared()
      : LocalPreferencesSecured();
  Get.put<ILocalPreferences>(preferences, permanent: true);

  // auth/product stay registered so that feature is untouched and still
  // compiles/works — this entrega just doesn't route through it yet.
  registerAuth();
  registerProduct();
  // Must come before home/my_projects/create_project: all three read
  // from (or write to) the shared projects store via Get.find().
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
      title: 'Clean template',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      // This entrega's scope is "Explorar proyectos" (Home) and now
      // "Mis proyectos", so the app opens directly on Home instead of the
      // auth-gated `Central()` widget. Both screens are registered as
      // named routes so the shared bottom navigation can switch between
      // them (`Get.offNamed`) without either page importing the other.
      // `Central`, login and the product feature are untouched and still
      // compile — swap `initialRoute` back to `Central()` once auth is
      // wired into a real flow.
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/mis-proyectos', page: () => const MyProjectsPage()),
      ],
    );
  }
}
