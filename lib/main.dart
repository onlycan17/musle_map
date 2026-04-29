import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuscleMapApp());
}

class MuscleMapApp extends StatelessWidget {
  const MuscleMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFD84A3A);
    return MaterialApp(
      title: '근육 지도',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F6),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF2B1D1B),
          centerTitle: false,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF2B1D1B),
          displayColor: const Color(0xFF2B1D1B),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2B1D1B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
