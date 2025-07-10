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
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const RobotControlScreen(),
    );
  }
}