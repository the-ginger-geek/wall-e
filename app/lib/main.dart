import 'package:flutter/material.dart';
import 'app/app.locator.dart';
import 'ui/views/robot_control/robot_control_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator and dependencies
  await setupLocator();
  
  runApp(const WallEControllerApp());
}

class WallEControllerApp extends StatelessWidget {
  const WallEControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WALL-E Controller',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE6B84A),
          primary: const Color(0xFFE6B84A),
          secondary: const Color(0xFF8B7355),
          error: const Color(0xFFDC143C),
          // rust-tinted colors for authentic WALL-E look
          surface: const Color(0xFF4A453E),
          onSurface: const Color(0xFFFFFFFF),
          onPrimary: const Color(0xFF000000),
          onSecondary: const Color(0xFFFFFFFF),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF3D3931),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE6B84A),
          foregroundColor: Color(0xFF000000),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE6B84A),
            foregroundColor: const Color(0xFF000000),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFDC143C),
          foregroundColor: Color(0xFFFFFFFF),
        ),
      ),
      home: const RobotControlView(),
    );
  }
}