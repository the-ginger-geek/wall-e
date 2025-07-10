import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class MovementControl extends StatefulWidget {
  final bool isConnected;
  
  const MovementControl({required this.isConnected, super.key});

  @override
  State<MovementControl> createState() => _MovementControlState();
}

class _MovementControlState extends State<MovementControl> {
  int _currentX = 0;
  int _currentY = 0;
  
  Future<void> _sendMovement(int x, int y) async {
    if (!widget.isConnected) return;
    
    try {
      await RobotAPI.move(x, y);
      setState(() {
        _currentX = x;
        _currentY = y;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movement failed: $e')),
      );
    }
  }
  
  Future<void> _stopMovement() async {
    await _sendMovement(0, 0);
  }
  
  Widget _buildDirectionalButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required VoidCallback onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: widget.isConnected ? Colors.orange : Colors.grey,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Position: X=$_currentX, Y=$_currentY',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Column(
              children: [
                _buildDirectionalButton(
                  icon: Icons.keyboard_arrow_up,
                  label: 'Forward',
                  onPressed: () => _sendMovement(0, 50),
                  onReleased: _stopMovement,
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDirectionalButton(
                      icon: Icons.keyboard_arrow_left,
                      label: 'Left',
                      onPressed: () => _sendMovement(-50, 0),
                      onReleased: _stopMovement,
                    ),
                    
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        onPressed: _stopMovement,
                        icon: const Icon(Icons.stop, color: Colors.white, size: 32),
                      ),
                    ),
                    
                    _buildDirectionalButton(
                      icon: Icons.keyboard_arrow_right,
                      label: 'Right',
                      onPressed: () => _sendMovement(50, 0),
                      onReleased: _stopMovement,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildDirectionalButton(
                  icon: Icons.keyboard_arrow_down,
                  label: 'Backward',
                  onPressed: () => _sendMovement(0, -50),
                  onReleased: _stopMovement,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDirectionalButton(
                  icon: Icons.rotate_left,
                  label: 'Turn Left',
                  onPressed: () => _sendMovement(-30, 30),
                  onReleased: _stopMovement,
                ),
                _buildDirectionalButton(
                  icon: Icons.rotate_right,
                  label: 'Turn Right',
                  onPressed: () => _sendMovement(30, 30),
                  onReleased: _stopMovement,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            if (!widget.isConnected)
              const Text(
                'Robot not connected',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}