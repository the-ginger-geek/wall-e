import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'audio_viewmodel.dart';

class AudioView extends StackedView<AudioViewModel> {
  final bool isConnected;
  
  const AudioView({super.key, required this.isConnected});

  @override
  Widget builder(
    BuildContext context,
    AudioViewModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        // Sound Control Section
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
                      'Sound Control',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: isConnected && !viewModel.state.isLoading ? viewModel.loadSounds : null,
                      icon: viewModel.state.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(viewModel.state.isLoading ? 'Loading...' : 'Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (viewModel.state.availableSounds.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: viewModel.state.selectedSound,
                    decoration: const InputDecoration(
                      labelText: 'Select Sound',
                      border: OutlineInputBorder(),
                    ),
                    items: viewModel.state.availableSounds.map((sound) {
                      return DropdownMenuItem(
                        value: sound,
                        child: Text(sound),
                      );
                    }).toList(),
                    onChanged: isConnected ? viewModel.setSelectedSound : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isConnected && 
                                 !viewModel.state.isLoading && 
                                 viewModel.state.selectedSound != null
                          ? () => viewModel.playSound(viewModel.state.selectedSound!)
                          : null,
                      icon: viewModel.state.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(viewModel.state.isLoading ? 'Playing...' : 'Play Sound'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No sounds available. Click refresh to load sounds.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isConnected ? viewModel.loadSounds : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Sounds'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Text-to-Speech Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Text-to-Speech',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  onChanged: viewModel.setTtsText,
                  decoration: const InputDecoration(
                    labelText: 'Enter text to speak',
                    border: OutlineInputBorder(),
                    hintText: 'Hello, I am WALL-E!',
                  ),
                  maxLines: 3,
                  enabled: isConnected,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: viewModel.state.isLoading || !isConnected || viewModel.state.ttsText.trim().isEmpty
                            ? null
                            : () => viewModel.speakText(viewModel.state.ttsText),
                        icon: viewModel.state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.record_voice_over),
                        label: Text(viewModel.state.isLoading ? 'Speaking...' : 'Speak'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isConnected ? viewModel.clearTtsText : null,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                
                // Quick phrases
                const SizedBox(height: 16),
                const Text(
                  'Quick Phrases:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Hello, I am WALL-E!',
                    'How are you today?',
                    'I am ready for action!',
                    'Goodbye!',
                    'Thank you!',
                    'Error! Error!',
                  ].map((phrase) {
                    return ElevatedButton(
                      onPressed: isConnected && !viewModel.state.isLoading
                          ? () {
                              viewModel.setTtsText(phrase);
                              viewModel.speakText(phrase);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                      ),
                      child: Text(phrase),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        
        // Status messages
        if (viewModel.state.successMessage != null) ...[
          const SizedBox(height: 16),
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
              ],
            ),
          ),
        ],
        
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
              ],
            ),
          ),
        ],
        
        if (!isConnected) ...[
          const SizedBox(height: 16),
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
                    'Robot not connected. Audio functions are disabled.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  AudioViewModel viewModelBuilder(BuildContext context) => AudioViewModel();

  @override
  void onViewModelReady(AudioViewModel viewModel) {
    if (isConnected) {
      viewModel.loadSounds();
    }
  }
}