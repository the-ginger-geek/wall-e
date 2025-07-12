import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/movement_viewmodel.dart';

class MovementControl extends StatelessWidget {
  final bool isConnected;

  const MovementControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<MovementViewModel>(),
      child: _MovementControlView(isConnected: isConnected),
    );
  }
}

class _MovementControlView extends StatelessWidget {
  final bool isConnected;

  const _MovementControlView({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Joystick Control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Movement Control',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Virtual Joystick
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Center dot
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                              ),
                              // Joystick handle
                              Positioned(
                                left: 100 + (state.currentX * 0.8) - 15,
                                top: 100 - (state.currentY * 0.8) - 15,
                                child: GestureDetector(
                                  onPanUpdate: isConnected
                                      ? (details) => _handleJoystickMove(
                                            context,
                                            details,
                                            viewModel,
                                          )
                                      : null,
                                  onPanEnd: isConnected
                                      ? (_) => viewModel.move(0, 0)
                                      : null,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isConnected ? Colors.blue : Colors.grey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Current Position Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ValueDisplay(
                            label: 'X (Turn)',
                            value: state.currentX,
                            color: Colors.blue,
                          ),
                          _ValueDisplay(
                            label: 'Y (Move)',
                            value: state.currentY,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Direction Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Direction Controls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Forward
                      Center(
                        child: _DirectionButton(
                          icon: Icons.keyboard_arrow_up,
                          label: 'Forward',
                          onPressed: isConnected && !state.isLoading
                              ? () => viewModel.move(0, 50)
                              : null,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Left, Stop, Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DirectionButton(
                            icon: Icons.keyboard_arrow_left,
                            label: 'Left',
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.move(-50, 0)
                                : null,
                          ),
                          _DirectionButton(
                            icon: Icons.stop,
                            label: 'Stop',
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.stop()
                                : null,
                            color: Colors.red,
                          ),
                          _DirectionButton(
                            icon: Icons.keyboard_arrow_right,
                            label: 'Right',
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.move(50, 0)
                                : null,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Backward
                      Center(
                        child: _DirectionButton(
                          icon: Icons.keyboard_arrow_down,
                          label: 'Backward',
                          onPressed: isConnected && !state.isLoading
                              ? () => viewModel.move(0, -50)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Status Messages
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

  void _handleJoystickMove(
    BuildContext context,
    DragUpdateDetails details,
    MovementViewModel viewModel,
  ) {
    // Calculate position relative to center of joystick
    const joystickRadius = 100.0;
    final dx = details.localPosition.dx - joystickRadius;
    final dy = joystickRadius - details.localPosition.dy;
    
    // Convert to range -100 to 100
    final x = (dx / joystickRadius * 100).round().clamp(-100, 100);
    final y = (dy / joystickRadius * 100).round().clamp(-100, 100);
    
    viewModel.move(x, y);
  }
}

class _ValueDisplay extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ValueDisplay({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _DirectionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color != null ? Colors.white : null,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
              'Robot not connected. Movement controls are disabled.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}