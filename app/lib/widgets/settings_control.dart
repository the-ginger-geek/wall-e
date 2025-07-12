import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class SettingsControl extends StatefulWidget {
  final bool isConnected;
  
  const SettingsControl({required this.isConnected, super.key});

  @override
  State<SettingsControl> createState() => _SettingsControlState();
}

class _SettingsControlState extends State<SettingsControl> {
  double _steeringOffset = 0.0;
  double _motorDeadzone = 100.0;
  bool _autoMode = false;
  
  Future<void> _updateSteeringOffset(double value) async {
    if (!widget.isConnected) return;
    
    try {
      await RobotAPI.updateSteeringOffset(value.round());
      setState(() {
        _steeringOffset = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Steering offset updated to ${value.round()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }
  
  Future<void> _updateMotorDeadzone(double value) async {
    if (!widget.isConnected) return;
    
    try {
      await RobotAPI.updateMotorDeadzone(value.round());
      setState(() {
        _motorDeadzone = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Motor deadzone updated to ${value.round()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }
  
  Future<void> _updateAutoMode(bool value) async {
    if (!widget.isConnected) return;
    
    try {
      await RobotAPI.updateAutoMode(value);
      setState(() {
        _autoMode = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto mode ${value ? 'enabled' : 'disabled'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }
  
  Widget _buildSettingCard({
    required String title,
    required String description,
    required Widget control,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            control,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Robot Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSettingCard(
                    title: 'Steering Offset',
                    description: 'Calibrate robot steering (-100 to 100)',
                    icon: Icons.tune,
                    color: Colors.blue,
                    control: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('-100'),
                            Text(
                              '${_steeringOffset.round()}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text('100'),
                          ],
                        ),
                        Slider(
                          value: _steeringOffset,
                          min: -100,
                          max: 100,
                          divisions: 200,
                          onChanged: widget.isConnected ? (value) {
                            setState(() {
                              _steeringOffset = value;
                            });
                          } : null,
                          onChangeEnd: widget.isConnected ? _updateSteeringOffset : null,
                        ),
                      ],
                    ),
                  ),
                  
                  _buildSettingCard(
                    title: 'Motor Deadzone',
                    description: 'Motor sensitivity threshold (0 to 250)',
                    icon: Icons.speed,
                    color: Colors.orange,
                    control: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('0'),
                            Text(
                              '${_motorDeadzone.round()}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text('250'),
                          ],
                        ),
                        Slider(
                          value: _motorDeadzone,
                          min: 0,
                          max: 250,
                          divisions: 250,
                          onChanged: widget.isConnected ? (value) {
                            setState(() {
                              _motorDeadzone = value;
                            });
                          } : null,
                          onChangeEnd: widget.isConnected ? _updateMotorDeadzone : null,
                        ),
                      ],
                    ),
                  ),
                  
                  _buildSettingCard(
                    title: 'Auto Mode',
                    description: 'Enable/disable automatic servo animations',
                    icon: Icons.auto_mode,
                    color: Colors.green,
                    control: SwitchListTile(
                      value: _autoMode,
                      onChanged: widget.isConnected ? _updateAutoMode : null,
                      title: Text(_autoMode ? 'Enabled' : 'Disabled'),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (!widget.isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Robot not connected',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}