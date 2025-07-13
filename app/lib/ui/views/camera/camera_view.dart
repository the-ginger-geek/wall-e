import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'camera_viewmodel.dart';

class CameraView extends StackedView<CameraViewModel> {
  const CameraView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CameraViewModel viewModel,
    Widget? child,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Camera Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Camera preview area
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black12,
              ),
              child: viewModel.state.currentFrame != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        viewModel.state.currentFrame!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 48, color: Colors.red),
                                SizedBox(height: 8),
                                Text('Error loading image'),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Camera not active'),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Camera controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.state.isLoading 
                        ? null 
                        : (viewModel.state.isActive ? viewModel.stopCamera : viewModel.startCamera),
                    icon: viewModel.state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(viewModel.state.isActive ? Icons.videocam_off : Icons.videocam),
                    label: Text(
                      viewModel.state.isLoading
                          ? 'Loading...'
                          : (viewModel.state.isActive ? 'Stop Camera' : 'Start Camera'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: viewModel.state.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // Status indicators
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewModel.state.isActive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Camera: ${viewModel.state.isActive ? "Active" : "Inactive"}',
                  style: TextStyle(
                    color: viewModel.state.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                if (viewModel.state.isStreaming) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Streaming',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            
            // Error message
            if (viewModel.state.errorMessage != null) ...[
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
                        viewModel.state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: viewModel.clearError,
                      child: const Text('Dismiss'),
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
  CameraViewModel viewModelBuilder(BuildContext context) => CameraViewModel();
}