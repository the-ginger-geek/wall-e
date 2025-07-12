import 'package:flutter/material.dart';
import 'screens/robot_control_screen.dart';

void main() {
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
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFF808080),
          error: const Color(0xFFDC143C),
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF000000),
          onPrimary: const Color(0xFF000000),
          onSecondary: const Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Color(0xFF000000),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF000000),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFDC143C),
          foregroundColor: Color(0xFFFFFFFF),
        ),
      ),
      home: const RobotControlScreen(),
    );
  }
}