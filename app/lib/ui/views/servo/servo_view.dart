import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'servo_viewmodel.dart';

class ServoView extends StackedView<ServoViewModel> {
  const ServoView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ServoViewModel viewModel,
    Widget? child,
  ) {
    return Card(
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
                ElevatedButton.icon(
                  onPressed: viewModel.state.isConnected && !viewModel.state.isLoading ? viewModel.resetAllServos : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Servo sliders
            ...viewModel.state.servos.map((servo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          servo.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${servo.value}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
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
                      onChanged: (value) {},
                      onChangeEnd: viewModel.state.isConnected && !viewModel.state.isLoading
                          ? (value) => viewModel.controlServo(servo.name, value.round())
                          : null,
                      activeColor: viewModel.state.isConnected ? Colors.blue : Colors.grey,
                      inactiveColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            // Loading indicator
            if (viewModel.state.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
            
            // Success message
            if (viewModel.state.successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.state.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: viewModel.clearMessages,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Error message
            if (viewModel.state.errorMessage != null) ...[
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
                        viewModel.state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: viewModel.clearMessages,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Connection status
            if (!viewModel.state.isConnected) ...[
              Container(
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  ServoViewModel viewModelBuilder(BuildContext context) => ServoViewModel();
}