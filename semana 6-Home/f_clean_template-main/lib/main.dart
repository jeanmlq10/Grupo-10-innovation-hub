import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'core/app_theme.dart';
import 'core/i_local_preferences.dart';
import 'core/local_preferences_secured.dart';
import 'core/local_preferences_shared.dart';

import 'features/auth/auth_dependencies.dart';
import 'features/product/product_dependencies.dart';
import 'features/home/home_dependencies.dart';
import 'features/home/ui/views/home_page.dart';

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
  registerHome();
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
      // For this entrega only the Home ("Explorar proyectos") is in scope,
      // so the app opens directly on it instead of the auth-gated
      // `Central()` widget. `Central`, login and the product feature are
      // untouched and still compile — swap this back to `Central()` once
      // auth is wired into a real flow.
      home: const HomePage(),
    );
  }
}
