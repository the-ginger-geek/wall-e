import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/camera_viewmodel.dart';

class CameraControl extends StatelessWidget {
  final bool isConnected;

  const CameraControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<CameraViewModel>(),
      child: _CameraControlView(isConnected: isConnected),
    );
  }
}

class _CameraControlView extends StatefulWidget {
  final bool isConnected;

  const _CameraControlView({required this.isConnected});

  @override
  State<_CameraControlView> createState() => _CameraControlViewState();
}

class _CameraControlViewState extends State<_CameraControlView> {
  @override
  void dispose() {
    // Stop camera when widget is disposed
    final viewModel = context.read<CameraViewModel>();
    if (viewModel.state.isActive) {
      viewModel.stopCamera();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Camera Control',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(
                          state.isActive ? Icons.videocam : Icons.videocam_off,
                          color: state.isActive ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: state.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Camera feed display
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black12,
                    ),
                    child: state.currentFrame != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              state.currentFrame!,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Camera inactive',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Control buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading || !widget.isConnected || state.isActive
                            ? null
                            : () => viewModel.startCamera(),
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(state.isLoading ? 'Loading...' : 'Start Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isActive ? Colors.grey : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading || !widget.isConnected || !state.isActive
                            ? null
                            : () => viewModel.stopCamera(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !state.isActive ? Colors.grey : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Status indicators
                if (state.isStreaming) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Streaming',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Error message
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          onPressed: () => viewModel.clearError(),
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Connection warning
                if (!widget.isConnected) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Robot not connected. Camera functions are disabled.',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
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
      },
    );
  }
}