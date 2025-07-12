import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/servo_viewmodel.dart';

class ServoControl extends StatelessWidget {
  final bool isConnected;

  const ServoControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<ServoViewModel>(),
      child: _ServoControlView(isConnected: isConnected),
    );
  }
}

class _ServoControlView extends StatelessWidget {
  final bool isConnected;

  const _ServoControlView({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServoViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Servo Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Servo Control',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.resetAllServos()
                                : null,
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Servo sliders
                      ...state.servos.map((servo) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  servo.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${servo.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: servo.value.toDouble(),
                              min: servo.minValue.toDouble(),
                              max: servo.maxValue.toDouble(),
                              divisions: 100,
                              onChanged: isConnected && !state.isLoading
                                  ? (value) => viewModel.controlServo(servo.name, value.round())
                                  : null,
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              // Status messages
              if (state.successMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: state.successMessage!,
                  isError: false,
                  onDismiss: () => viewModel.clearMessages(),
                ),
              ],
              
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: state.errorMessage!,
                  isError: true,
                  onDismiss: () => viewModel.clearMessages(),
                ),
              ],
              
              if (!isConnected) ...[
                const SizedBox(height: 16),
                const _DisconnectedWarning(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _StatusMessage({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: isError ? Colors.red : Colors.green),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DisconnectedWarning extends StatelessWidget {
  const _DisconnectedWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Robot not connected. Servo controls are disabled.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}