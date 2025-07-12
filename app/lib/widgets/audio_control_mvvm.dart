import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/service_locator.dart';
import '../viewmodels/audio_viewmodel.dart';

class AudioControl extends StatelessWidget {
  final bool isConnected;

  const AudioControl({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => serviceLocator<AudioViewModel>(),
      child: _AudioControlView(isConnected: isConnected),
    );
  }
}

class _AudioControlView extends StatefulWidget {
  final bool isConnected;

  const _AudioControlView({required this.isConnected});

  @override
  State<_AudioControlView> createState() => _AudioControlViewState();
}

class _AudioControlViewState extends State<_AudioControlView> {
  final TextEditingController _ttsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AudioViewModel>().loadSounds();
      });
    }
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sound Effects Section
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
                            'Sound Effects',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: widget.isConnected ? () => viewModel.loadSounds() : null,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh sound list',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (state.availableSounds.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: state.selectedSound,
                          decoration: const InputDecoration(
                            labelText: 'Select Sound',
                            border: OutlineInputBorder(),
                          ),
                          items: state.availableSounds.map((sound) {
                            return DropdownMenuItem<String>(
                              value: sound,
                              child: Text(sound),
                            );
                          }).toList(),
                          onChanged: widget.isConnected
                              ? (String? newValue) => viewModel.setSelectedSound(newValue)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading || !widget.isConnected || state.selectedSound == null
                                ? null
                                : () => viewModel.playSound(state.selectedSound!),
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(state.isLoading ? 'Playing...' : 'Play Sound'),
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
                            onPressed: widget.isConnected ? () => viewModel.loadSounds() : null,
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
                        controller: _ttsController,
                        decoration: const InputDecoration(
                          labelText: 'Enter text to speak',
                          border: OutlineInputBorder(),
                          hintText: 'Hello, I am WALL-E!',
                        ),
                        maxLines: 3,
                        enabled: widget.isConnected,
                        onChanged: (text) => viewModel.setTtsText(text),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.isLoading || !widget.isConnected
                                  ? null
                                  : () => viewModel.speakText(_ttsController.text),
                              icon: state.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.record_voice_over),
                              label: Text(state.isLoading ? 'Speaking...' : 'Speak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: widget.isConnected
                                ? () {
                                    _ttsController.clear();
                                    viewModel.clearTtsText();
                                    viewModel.clearMessages();
                                  }
                                : null,
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
                            onPressed: widget.isConnected
                                ? () {
                                    _ttsController.text = phrase;
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
              
              if (!widget.isConnected) ...[
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
              'Robot not connected. Audio functions are disabled.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}