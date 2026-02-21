import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a injeção de dependência (GetIt)
  setupInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Esig Feed',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.primaryDark,
              brightness: Brightness.dark,
            ).copyWith(
              primary: AppColors.primaryDark,
              secondary: AppColors.accent,
              surface: AppColors.surface,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
