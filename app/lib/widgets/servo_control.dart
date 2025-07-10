import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class ServoControl extends StatefulWidget {
  final bool isConnected;
  
  const ServoControl({required this.isConnected, super.key});

  @override
  State<ServoControl> createState() => _ServoControlState();
}

class _ServoControlState extends State<ServoControl> {
  final Map<String, double> _servoValues = {
    'head_rotation': 50.0,
    'neck_top': 50.0,
    'neck_bottom': 50.0,
    'arm_left': 50.0,
    'arm_right': 50.0,
    'eye_left': 50.0,
    'eye_right': 50.0,
  };
  
  final Map<String, String> _servoLabels = {
    'head_rotation': 'Head Rotation',
    'neck_top': 'Neck Top',
    'neck_bottom': 'Neck Bottom',
    'arm_left': 'Left Arm',
    'arm_right': 'Right Arm',
    'eye_left': 'Left Eye',
    'eye_right': 'Right Eye',
  };
  
  Future<void> _updateServo(String servo, double value) async {
    if (!widget.isConnected) return;
    
    try {
      await RobotAPI.controlServo(servo, value.round());
      setState(() {
        _servoValues[servo] = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Servo control failed: $e')),
      );
    }
  }
  
  Future<void> _resetAllServos() async {
    if (!widget.isConnected) return;
    
    try {
      final Map<String, int> resetValues = {};
      for (String servo in _servoValues.keys) {
        resetValues[servo] = 50;
      }
      
      await RobotAPI.controlMultipleServos(resetValues);
      
      setState(() {
        for (String servo in _servoValues.keys) {
          _servoValues[servo] = 50.0;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All servos reset to center')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset failed: $e')),
      );
    }
  }
  
  Widget _buildServoSlider(String servo) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _servoLabels[servo]!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_servoValues[servo]!.round()}',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _servoValues[servo]!,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: widget.isConnected ? (value) {
                setState(() {
                  _servoValues[servo] = value;
                });
              } : null,
              onChangeEnd: widget.isConnected ? (value) {
                _updateServo(servo, value);
              } : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Servo Controls',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: widget.isConnected ? _resetAllServos : null,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildServoSlider('head_rotation'),
                  _buildServoSlider('neck_top'),
                  _buildServoSlider('neck_bottom'),
                  _buildServoSlider('arm_left'),
                  _buildServoSlider('arm_right'),
                  _buildServoSlider('eye_left'),
                  _buildServoSlider('eye_right'),
                ],
              ),
            ),
          ),
          
          if (!widget.isConnected)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Robot not connected',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}