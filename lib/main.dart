import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_routes.dart';
import 'package:su/data/device_info_service.dart';
import 'package:su/pages/home_page.dart';
import 'package:su/pages/semester_page.dart';
import 'package:su/pages/settings_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DeviceInfoService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SU BCA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.sem1: (_) =>
            const SemesterPage(title: 'SEM 1', apiPath: 'SEM1'),
        AppRoutes.sem2: (_) =>
            const SemesterPage(title: 'SEM 2', apiPath: 'SEM2'),
        AppRoutes.sem3: (_) =>
            const SemesterPage(title: 'SEM 3', apiPath: 'SEM3'),
        AppRoutes.sem4: (_) =>
            const SemesterPage(title: 'SEM 4', apiPath: 'SEM4'),
        AppRoutes.sem5: (_) =>
            const SemesterPage(title: 'SEM 5', apiPath: 'SEM5'),
        AppRoutes.sem6: (_) =>
            const SemesterPage(title: 'SEM 6', apiPath: 'SEM6'),
      },
    );
  }
}
