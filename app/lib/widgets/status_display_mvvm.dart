import 'package:flutter/material.dart';
import '../services/robot_api_service.dart';

class StatusDisplay extends StatelessWidget {
  final RobotStatus? robotStatus;
  final bool isConnected;
  final String statusMessage;
  final String? errorMessage;

  const StatusDisplay({
    super.key,
    this.robotStatus,
    required this.isConnected,
    required this.statusMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Robot Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isConnected ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.check_circle : Icons.error,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusMessage,
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Connection Details
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.wifi,
                    label: 'TCP Connection',
                    value: isConnected ? 'Connected' : 'Disconnected',
                    isPositive: isConnected,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.memory,
                    label: 'Arduino',
                    value: robotStatus?.arduinoConnected == true ? 'Connected' : 'Disconnected',
                    isPositive: robotStatus?.arduinoConnected == true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.battery_std,
                    label: 'Battery',
                    value: robotStatus?.batteryLevel ?? 'Unknown',
                    isPositive: robotStatus?.batteryLevel != 'Unknown',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.videocam,
                    label: 'Camera',
                    value: robotStatus?.cameraActive == true ? 'Available' : 'Unavailable',
                    isPositive: robotStatus?.cameraActive == true,
                  ),
                ),
              ],
            ),
            
            // Error Message
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPositive;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}