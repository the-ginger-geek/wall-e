import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/animation_viewmodel.dart';

class AnimationControl extends StatelessWidget {
  final bool isConnected;

  const AnimationControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<AnimationViewModel>(),
      child: _AnimationControlView(isConnected: isConnected),
    );
  }
}

class _AnimationControlView extends StatelessWidget {
  final bool isConnected;

  const _AnimationControlView({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Animation Controls
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
                            'Animation Control',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (state.currentAnimation != null)
                            ElevatedButton(
                              onPressed: isConnected && !state.isLoading
                                  ? () => viewModel.stopAnimation()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Stop'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Animation buttons grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: state.animations.length,
                        itemBuilder: (context, index) {
                          final animation = state.animations[index];
                          final isPlaying = state.currentAnimation == animation.id;
                          
                          return ElevatedButton(
                            onPressed: isConnected && !state.isLoading
                                ? () => viewModel.playAnimation(animation.id)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPlaying ? Colors.green : null,
                              foregroundColor: isPlaying ? Colors.white : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isPlaying && state.isLoading)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                else
                                  Icon(
                                    isPlaying ? Icons.play_circle_filled : Icons.play_circle_outline,
                                    size: 20,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  animation.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Current animation info
              if (state.currentAnimation != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Currently Playing',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.play_circle_filled, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.getAnimation(state.currentAnimation!)?.name ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    viewModel.getAnimation(state.currentAnimation!)?.description ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
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
              'Robot not connected. Animation controls are disabled.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}