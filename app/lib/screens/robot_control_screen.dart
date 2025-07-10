import 'package:flutter/material.dart';
import '../services/robot_api.dart';
import '../widgets/movement_control.dart';
import '../widgets/servo_control.dart';
import '../widgets/animation_control.dart';
import '../widgets/settings_control.dart';
import '../widgets/status_display.dart';

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  RobotStatus? _robotStatus;
  bool _isConnected = false;
  String _statusMessage = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    // Disconnect when the widget is disposed
    RobotAPI.disconnect();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final response = await RobotAPI.getStatus();
      final status = RobotStatus.fromJson(response);
      setState(() {
        _robotStatus = status;
        _isConnected = status.arduinoConnected;
        _statusMessage = _isConnected ? 'Connected' : 'Arduino not connected';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Connection failed: $e';
      });
    }
  }

  Future<void> _emergencyStop() async {
    try {
      await RobotAPI.emergencyStop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency stop activated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergency stop failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WALL-E Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStatus,
          ),
        ],
      ),
      body: Column(
        children: [
          StatusDisplay(
            robotStatus: _robotStatus,
            isConnected: _isConnected,
            statusMessage: _statusMessage,
          ),
          
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _emergencyStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('EMERGENCY STOP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Movement'),
                      Tab(text: 'Servos'),
                      Tab(text: 'Animations'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MovementControl(isConnected: _isConnected),
                        ServoControl(isConnected: _isConnected),
                        AnimationControl(isConnected: _isConnected),
                        SettingsControl(isConnected: _isConnected),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}