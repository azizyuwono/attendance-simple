import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'constants/theme.dart';
import 'routes/app_pages.dart';
import 'routes/route_names.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical services before app start
  final databaseService = DatabaseService();
  await databaseService.init();
  Get.put(databaseService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance App',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Changed to system to respect user preference
      initialBinding: InitialBinding(),
      getPages: AppPages.appPages,
      initialRoute: RouteNames.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
