import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class StatusDisplay extends StatelessWidget {
  final RobotStatus? robotStatus;
  final bool isConnected;
  final String statusMessage;
  
  const StatusDisplay({
    required this.robotStatus,
    required this.isConnected,
    required this.statusMessage,
    super.key,
  });
  
  Color _getStatusColor() {
    if (isConnected) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
  
  IconData _getStatusIcon() {
    if (isConnected) {
      return Icons.check_circle;
    } else {
      return Icons.error;
    }
  }
  
  Widget _buildStatusItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Robot Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (robotStatus != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusItem(
                  label: 'Arduino',
                  value: robotStatus!.arduinoConnected ? 'Connected' : 'Disconnected',
                  icon: robotStatus!.arduinoConnected ? Icons.check : Icons.close,
                  color: robotStatus!.arduinoConnected ? Colors.green : Colors.red,
                ),
                _buildStatusItem(
                  label: 'Battery',
                  value: robotStatus!.batteryLevel,
                  icon: Icons.battery_std,
                  color: _getBatteryColor(robotStatus!.batteryLevel),
                ),
                _buildStatusItem(
                  label: 'Server',
                  value: robotStatus!.serverRunning ? 'Running' : 'Stopped',
                  icon: robotStatus!.serverRunning ? Icons.cloud : Icons.cloud_off,
                  color: robotStatus!.serverRunning ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getBatteryColor(String batteryLevel) {
    if (batteryLevel == 'Unknown') return Colors.grey;
    
    try {
      final percentage = int.parse(batteryLevel.replaceAll('%', ''));
      if (percentage > 50) return Colors.green;
      if (percentage > 20) return Colors.orange;
      return Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }
}