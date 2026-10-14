import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/core/theme/app_theme.dart';
import 'package:f_clean_template/di/app_bindings.dart';
import 'package:f_clean_template/routes/app_pages.dart';
import 'package:f_clean_template/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.bindings});

  final Bindings? bindings;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Innovation Hub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialBinding: bindings ?? AppBindings(),
      initialRoute: AppRoutes.central,
      getPages: AppPages.routes,
    );
  }
}
