import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class AnimationControl extends StatefulWidget {
  final bool isConnected;
  
  const AnimationControl({required this.isConnected, super.key});

  @override
  State<AnimationControl> createState() => _AnimationControlState();
}

class _AnimationControlState extends State<AnimationControl> {
  bool _isPlayingAnimation = false;
  
  final Map<int, Map<String, dynamic>> _animations = {
    0: {
      'name': 'Reset Position',
      'description': 'Reset all servos to neutral positions',
      'duration': 'Instant',
      'icon': Icons.refresh,
      'color': Colors.blue,
    },
    1: {
      'name': 'Bootup Sequence',
      'description': 'WALL-E startup animation',
      'duration': '8.6 seconds',
      'icon': Icons.power_settings_new,
      'color': Colors.green,
    },
    2: {
      'name': 'Inquisitive',
      'description': 'Curious and exploratory movements',
      'duration': '18 seconds',
      'icon': Icons.search,
      'color': Colors.orange,
    },
  };
  
  Future<void> _playAnimation(int animationId) async {
    if (!widget.isConnected || _isPlayingAnimation) return;
    
    setState(() {
      _isPlayingAnimation = true;
    });
    
    try {
      await RobotAPI.playAnimation(animationId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playing: ${_animations[animationId]!['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      final duration = _getAnimationDuration(animationId);
      if (duration > 0) {
        await Future.delayed(Duration(seconds: duration));
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animation failed: $e')),
      );
    } finally {
      setState(() {
        _isPlayingAnimation = false;
      });
    }
  }
  
  int _getAnimationDuration(int animationId) {
    switch (animationId) {
      case 0: return 0;
      case 1: return 9;
      case 2: return 18;
      default: return 0;
    }
  }
  
  Widget _buildAnimationCard(int animationId) {
    final animation = _animations[animationId]!;
    final isEnabled = widget.isConnected && !_isPlayingAnimation;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              animation['color'].withOpacity(0.1),
              animation['color'].withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: isEnabled ? animation['color'] : Colors.grey,
            child: Icon(
              animation['icon'],
              color: Colors.white,
            ),
          ),
          title: Text(
            animation['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                animation['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: isEnabled ? Colors.black54 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Duration: ${animation['duration']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? animation['color'] : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: isEnabled ? () => _playAnimation(animationId) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? animation['color'] : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play'),
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Animations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_isPlayingAnimation)
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Playing...'),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAnimationCard(0),
                  _buildAnimationCard(1),
                  _buildAnimationCard(2),
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