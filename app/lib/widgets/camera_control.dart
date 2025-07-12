import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/robot_api.dart';

class CameraControl extends StatefulWidget {
  const CameraControl({super.key});

  @override
  State<CameraControl> createState() => _CameraControlState();
}

class _CameraControlState extends State<CameraControl> {
  bool _cameraActive = false;
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _currentFrame;
  bool _isStreaming = false;

  @override
  void dispose() {
    if (_cameraActive) {
      _stopCamera();
    }
    super.dispose();
  }

  Future<void> _startCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await RobotAPI.startCamera();
      if (response['status'] == 'OK') {
        setState(() {
          _cameraActive = true;
          _isLoading = false;
        });
        _startFrameStream();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to start camera';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting camera: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _isStreaming = false;
      final response = await RobotAPI.stopCamera();
      if (response['status'] == 'OK') {
        setState(() {
          _cameraActive = false;
          _currentFrame = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to stop camera';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error stopping camera: $e';
        _isLoading = false;
      });
    }
  }

  void _startFrameStream() {
    if (!_cameraActive) return;
    
    setState(() {
      _isStreaming = true;
    });

    _getNextFrame();
  }

  Future<void> _getNextFrame() async {
    if (!_isStreaming || !_cameraActive) return;

    try {
      final response = await RobotAPI.getCameraFrame();
      if (response['status'] == 'OK' && response['frame'] != null) {
        final frameData = response['frame'] as String;
        final bytes = base64Decode(frameData);
        
        if (mounted) {
          setState(() {
            _currentFrame = bytes;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error getting frame: $e';
        });
      }
    }

    // Continue streaming if still active
    if (_isStreaming && _cameraActive && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      _getNextFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Camera Control',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (_cameraActive)
                      Icon(
                        Icons.videocam,
                        color: Colors.green,
                        size: 20,
                      )
                    else
                      Icon(
                        Icons.videocam_off,
                        color: Colors.grey,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _cameraActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: _cameraActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Camera feed display
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black12,
              ),
              child: _currentFrame != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _currentFrame!,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Camera inactive',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : (_cameraActive ? null : _startCamera),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isLoading ? 'Loading...' : 'Start Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cameraActive ? Colors.grey : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : (_cameraActive ? _stopCamera : null),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_cameraActive ? Colors.grey : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}