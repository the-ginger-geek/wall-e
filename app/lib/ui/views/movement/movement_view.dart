import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'movement_viewmodel.dart';

class MovementView extends StackedView<MovementViewModel> {
  final bool isConnected;
  
  const MovementView({required this.isConnected, Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MovementViewModel viewModel,
    Widget? child,
  ) {
    return _MovementControlWidget(
      isConnected: isConnected,
      viewModel: viewModel,
    );
  }

  @override
  MovementViewModel viewModelBuilder(BuildContext context) => MovementViewModel();

  @override
  void onViewModelReady(MovementViewModel viewModel) {
    viewModel.initialise();
  }
}

class _MovementControlWidget extends StatefulWidget {
  final bool isConnected;
  final MovementViewModel viewModel;

  const _MovementControlWidget({
    required this.isConnected,
    required this.viewModel,
  });

  @override
  State<_MovementControlWidget> createState() => _MovementControlWidgetState();
}

class _MovementControlWidgetState extends State<_MovementControlWidget> {
  Offset _joystickPosition = Offset.zero;
  DateTime _lastCommandTime = DateTime.now();
  static const double _commandBufferMs = 100; // 100ms buffer between commands
  static const double _movementThreshold = 50; // 50 pixel threshold
  
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    
    // Calculate position relative to center
    final localPosition = details.localPosition;
    final deltaX = localPosition.dx - centerX;
    final deltaY = localPosition.dy - centerY;
    
    // Constrain to circle bounds
    final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
    final maxRadius = min(centerX, centerY) - 10; // 10px padding from edge
    
    if (distance <= maxRadius) {
      setState(() {
        _joystickPosition = Offset(deltaX, deltaY);
      });
    } else {
      // Constrain to circle edge
      final angle = atan2(deltaY, deltaX);
      final constrainedX = cos(angle) * maxRadius;
      final constrainedY = sin(angle) * maxRadius;
      setState(() {
        _joystickPosition = Offset(constrainedX, constrainedY);
      });
    }
    
    // Send movement command with buffer
    _sendMovementCommand();
  }
  
  void _sendMovementCommand() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastCommandTime).inMilliseconds;
    
    // Only send command if enough time has passed
    if (timeDiff < _commandBufferMs) return;
    
    // Check if movement is significant enough
    final distance = sqrt(_joystickPosition.dx * _joystickPosition.dx + 
                         _joystickPosition.dy * _joystickPosition.dy);
    if (distance < _movementThreshold) return;
    
    const centerX = 100.0; // Max range for calculations
    const centerY = 100.0;
    
    // Convert joystick position to movement values (-100 to 100)
    final x = (_joystickPosition.dx / centerX * 100).clamp(-100, 100);
    final y = (-_joystickPosition.dy / centerY * 100).clamp(-100, 100); // Inverted Y
    
    widget.viewModel.move(x.round(), y.round());
    _lastCommandTime = now;
  }
  
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _joystickPosition = Offset.zero;
    });
    widget.viewModel.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Movement Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Joystick control area
            LayoutBuilder(
              builder: (context, constraints) {
                const double joystickSize = 200;
                const double dotSize = 20;
                
                return Container(
                  width: joystickSize,
                  height: joystickSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) => _onPanUpdate(
                      details, 
                      const BoxConstraints(
                        maxWidth: joystickSize,
                        maxHeight: joystickSize,
                      ),
                    ),
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        // Center reference point
                        Positioned(
                          left: joystickSize / 2 - 2,
                          top: joystickSize / 2 - 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Moveable yellow dot
                        Positioned(
                          left: joystickSize / 2 + _joystickPosition.dx - dotSize / 2,
                          top: joystickSize / 2 + _joystickPosition.dy - dotSize / 2,
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Direction buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.isConnected ? () => widget.viewModel.move(-60, -60) : null,
                  child: const Text('Left'),
                ),
                ElevatedButton(
                  onPressed: widget.isConnected ? () => widget.viewModel.move(-60, 60) : null,
                  child: const Text('Right'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.isConnected ? () => widget.viewModel.move(-50, 0) : null,
                  child: const Text('Forward'),
                ),
                ElevatedButton(
                  onPressed: widget.isConnected ? () => widget.viewModel.move(50, 0) : null,
                  child: const Text('Backward'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stop button
            ElevatedButton(
              onPressed: widget.isConnected ? widget.viewModel.stop : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('STOP', style: TextStyle(color: Colors.white)),
            ),
            
            // Status indicators
            if (widget.viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            if (widget.viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (widget.viewModel.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.viewModel.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            
            // Connection status
            if (!widget.isConnected)
              Container(
                margin: const EdgeInsets.only(top: 16),
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
              ),
          ],
        ),
      ),
    );
  }
}