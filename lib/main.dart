import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 폰은 세로 고정, 태블릿(최단 변 600 이상)은 전체 회전 허용.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final isTablet = MediaQueryData.fromView(view).size.shortestSide >= 600;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : [DeviceOrientation.portraitUp],
  );
  runApp(const MuscleMapApp());
}

class MuscleMapApp extends StatelessWidget {
  const MuscleMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFD84A3A);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
