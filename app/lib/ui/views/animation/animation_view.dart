import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'animation_viewmodel.dart';

class AnimationView extends StackedView<AnimationViewModel> {
  final bool isConnected;
  
  const AnimationView({required this.isConnected, super.key});

  @override
  Widget builder(
    BuildContext context,
    AnimationViewModel viewModel,
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
                  'Animation Control',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (viewModel.state.currentAnimation != null)
                  ElevatedButton.icon(
                    onPressed: isConnected && !viewModel.state.isLoading ? viewModel.stopAnimation : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Animation grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: viewModel.state.animations.length,
              itemBuilder: (context, index) {
                final animation = viewModel.state.animations[index];
                final isPlaying = viewModel.state.currentAnimation == animation.id;
                
                return ElevatedButton(
                  onPressed: isConnected && !viewModel.state.isLoading 
                      ? () => viewModel.playAnimation(animation.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlaying 
                        ? Colors.green 
                        : (isConnected ? Colors.blue : Colors.grey),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPlaying ? Icons.play_arrow : _getAnimationIcon(animation.name),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        animation.name,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Current animation status
            if (viewModel.state.currentAnimation != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Playing: ${_getAnimationName(viewModel, viewModel.state.currentAnimation!)}',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
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
            if (!isConnected) ...[
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
                        'Robot not connected. Animation controls are disabled.',
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
  AnimationViewModel viewModelBuilder(BuildContext context) => AnimationViewModel();

  IconData _getAnimationIcon(String animationName) {
    switch (animationName.toLowerCase()) {
      case 'hello':
        return Icons.waving_hand;
      case 'look around':
        return Icons.visibility;
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'surprise':
        return Icons.sentiment_very_dissatisfied;
      case 'dance':
        return Icons.music_note;
      case 'sleep':
        return Icons.bedtime;
      case 'wake up':
        return Icons.wb_sunny;
      default:
        return Icons.smart_toy;
    }
  }

  String _getAnimationName(AnimationViewModel viewModel, int animationId) {
    final animation = viewModel.getAnimation(animationId);
    return animation?.name ?? 'Unknown';
  }
}