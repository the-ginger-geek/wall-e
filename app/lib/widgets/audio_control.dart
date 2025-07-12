import 'package:flutter/material.dart';
import '../services/robot_api.dart';

class AudioControl extends StatefulWidget {
  final bool isConnected;
  
  const AudioControl({super.key, required this.isConnected});

  @override
  State<AudioControl> createState() => _AudioControlState();
}

class _AudioControlState extends State<AudioControl> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<String> _availableSounds = [];
  String? _selectedSound;
  final TextEditingController _ttsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isConnected) {
      _loadSounds();
    }
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  Future<void> _loadSounds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await RobotAPI.listSounds();
      if (response['status'] == 'OK') {
        final soundsStr = response['message'] as String? ?? '';
        final sounds = soundsStr.replaceFirst('Available sounds: ', '')
            .split(', ')
            .where((s) => s.isNotEmpty)
            .toList();
        
        setState(() {
          _availableSounds = sounds;
          _isLoading = false;
          if (sounds.isNotEmpty) {
            _selectedSound = sounds.first;
          }
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load sounds';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading sounds: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _playSound(String soundName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await RobotAPI.playSound(soundName);
      if (response['status'] == 'OK') {
        setState(() {
          _successMessage = response['message'] ?? 'Playing sound: $soundName';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to play sound';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error playing sound: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter text to speak';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await RobotAPI.speakText(text);
      if (response['status'] == 'OK') {
        setState(() {
          _successMessage = response['message'] ?? 'Speaking: $text';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to speak text';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error speaking text: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: widget.isConnected ? _loadSounds : null,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh sound list',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_availableSounds.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedSound,
                      decoration: const InputDecoration(
                        labelText: 'Select Sound',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableSounds.map((sound) {
                        return DropdownMenuItem<String>(
                          value: sound,
                          child: Text(sound),
                        );
                      }).toList(),
                      onChanged: widget.isConnected
                          ? (String? newValue) {
                              setState(() {
                                _selectedSound = newValue;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading || !widget.isConnected || _selectedSound == null
                            ? null
                            : () => _playSound(_selectedSound!),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isLoading ? 'Playing...' : 'Play Sound'),
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
                        onPressed: widget.isConnected ? _loadSounds : null,
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
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading || !widget.isConnected
                              ? null
                              : () => _speakText(_ttsController.text),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.record_voice_over),
                          label: Text(_isLoading ? 'Speaking...' : 'Speak'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: widget.isConnected
                            ? () {
                                _ttsController.clear();
                                setState(() {
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
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
                                _speakText(phrase);
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
          if (_successMessage != null) ...[
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
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_errorMessage != null) ...[
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
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (!widget.isConnected) ...[
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
      ),
    );
  }
}