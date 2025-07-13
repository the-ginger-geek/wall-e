import 'dart:convert';
import 'dart:io';
import 'dart:async';

class RobotAPIException implements Exception {
  final String message;
  final int statusCode;
  
  RobotAPIException(this.message, this.statusCode);
  
  @override
  String toString() => 'RobotAPIException: $message (Status: $statusCode)';
}

class RobotStatus {
  final String status;
  final bool arduinoConnected;
  final String batteryLevel;
  
  RobotStatus({
    required this.status,
    required this.arduinoConnected,
    this.batteryLevel = 'Unknown',
  });
  
  factory RobotStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final status = json['status'] ?? 'Unknown';

    return RobotStatus(
      status: status,
      arduinoConnected: data['arduino_connected'] ?? false,
      batteryLevel: data['battery_level'] ?? 'Unknown',
    );
  }
  
  // Legacy compatibility for camera_active
  bool get cameraActive => arduinoConnected;
}

/// Service for communicating with the Wall-E robot TCP server
class RobotApiService {
  static const String _robotHost = '192.168.0.155';
  static const int _robotPort = 5001;
  
  Socket? _socket;
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  bool _isConnected = false;
  bool _isConnecting = false;
  final Map<String, Completer<String>> _pendingRequests = {};
  int _requestCounter = 0;
  
  /// Stream of connection status changes
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  /// Check if connected to robot
  bool get isConnected => _isConnected;
  
  /// Connect to the robot TCP server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      return;
    }
    
    _isConnecting = true;
    
    try {
      _socket = await Socket.connect(_robotHost, _robotPort);
      _isConnected = true;
      _isConnecting = false;
      _connectionStatusController.add(true);
      
      // Listen for responses
      _socket!.listen(
        (List<int> data) {
          final response = String.fromCharCodes(data).trim();
          _handleResponse(response);
        },
        onError: (error) {
          _isConnected = false;
          _connectionStatusController.add(false);
          _handleError(RobotAPIException('Connection error: $error', 0));
        },
        onDone: () {
          _isConnected = false;
          _connectionStatusController.add(false);
          _handleError(RobotAPIException('Connection closed', 0));
        },
      );
    } catch (e) {
      _isConnecting = false;
      _connectionStatusController.add(false);
      throw RobotAPIException('Failed to connect: $e', 0);
    }
  }
  
  /// Disconnect from the robot
  Future<void> disconnect() async {
    if (_isConnected) {
      try {
        await _sendRequest({'type': 'disconnect'});
      } catch (e) {
        // Ignore errors when disconnecting
      }
    }
    
    _socket?.close();
    _socket = null;
    _isConnected = false;
    _connectionStatusController.add(false);
  }
  
  void _handleResponse(String response) {
    try {
      final responseData = jsonDecode(response);
      final requestId = responseData['request_id'] as String?;
      
      if (requestId != null && _pendingRequests.containsKey(requestId)) {
        final completer = _pendingRequests.remove(requestId);
        completer?.complete(response);
      } else {
        // Handle responses without request_id (legacy support)
        if (_pendingRequests.isNotEmpty) {
          final firstCompleter = _pendingRequests.values.first;
          final firstKey = _pendingRequests.keys.first;
          _pendingRequests.remove(firstKey);
          firstCompleter.complete(response);
        }
      }
    } catch (e) {
      // If JSON parsing fails, complete any pending request
      if (_pendingRequests.isNotEmpty) {
        final firstCompleter = _pendingRequests.values.first;
        final firstKey = _pendingRequests.keys.first;
        _pendingRequests.remove(firstKey);
        firstCompleter.complete(response);
      }
    }
  }
  
  void _handleError(RobotAPIException error) {
    // Complete all pending requests with error
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingRequests.clear();
  }
  
  /// Send a JSON request and wait for response
  Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> request) async {
    if (!_isConnected) {
      await connect();
    }
    
    if (_socket == null) {
      throw RobotAPIException('Not connected to robot', 0);
    }
    
    // Generate unique request ID
    final requestId = 'req_${++_requestCounter}_${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<String>();
    _pendingRequests[requestId] = completer;
    
    try {
      // Add request ID to request
      final requestWithId = Map<String, dynamic>.from(request);
      requestWithId['request_id'] = requestId;
      
      // Send JSON request
      final jsonRequest = jsonEncode(requestWithId);
      _socket!.write('$jsonRequest\n');
      
      // Wait for response with timeout
      final response = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw RobotAPIException('Request timeout', 0);
        },
      );
      
      // Parse JSON response
      final responseData = jsonDecode(response);
      
      if (responseData['status'] == 'OK') {
        return responseData;
      } else if (responseData['status'] == 'Error') {
        throw RobotAPIException(
          'Robot error: ${responseData['message'] ?? 'Unknown error'}',
          responseData['statusCode'] ?? 1,
        );
      } else {
        return responseData;
      }
    } catch (e) {
      _pendingRequests.remove(requestId);
      if (e is RobotAPIException) {
        rethrow;
      }
      throw RobotAPIException('Request failed: $e', 0);
    }
  }
  
  // Movement control
  Future<Map<String, dynamic>> move(int x, int y) async {
    return await _sendRequest({
      'type': 'move',
      'x': x.toDouble(),
      'y': y.toDouble(),
    });
  }
  
  // Servo control
  Future<Map<String, dynamic>> controlServo(String servo, int value) async {
    return await _sendRequest({
      'type': 'servo',
      'name': servo,
      'value': value.toDouble(),
    });
  }
  
  // Multiple servo control
  Future<List<Map<String, dynamic>>> controlMultipleServos(Map<String, int> servos) async {
    final List<Map<String, dynamic>> results = [];
    
    for (final entry in servos.entries) {
      final result = await controlServo(entry.key, entry.value);
      results.add(result);
    }
    
    return results;
  }
  
  // Animation control
  Future<Map<String, dynamic>> playAnimation(int animationId) async {
    return await _sendRequest({
      'type': 'animation',
      'id': animationId.toString(),
    });
  }
  
  // Status check
  Future<Map<String, dynamic>> getStatus() async {
    return await _sendRequest({
      'type': 'status',
    });
  }
  
  // Emergency stop
  Future<Map<String, dynamic>> emergencyStop() async {
    return await _sendRequest({
      'type': 'stop',
    });
  }
  
  // Disconnect robot
  Future<Map<String, dynamic>> disconnectRobot() async {
    return await _sendRequest({
      'type': 'disconnect',
    });
  }
  
  // Settings control
  Future<Map<String, dynamic>> updateSetting(String setting, dynamic value) async {
    return await _sendRequest({
      'type': 'setting',
      'setting': setting,
      'value': value,
    });
  }

  // Settings control helpers
  Future<Map<String, dynamic>> updateSteeringOffset(int value) async {
    return await updateSetting('steering_offset', value);
  }

  Future<Map<String, dynamic>> updateMotorDeadzone(int value) async {
    return await updateSetting('motor_deadzone', value);
  }

  Future<Map<String, dynamic>> updateAutoMode(bool value) async {
    return await updateSetting('auto_mode', value);
  }
  
  // Camera control
  Future<Map<String, dynamic>> startCamera() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'start',
    });
  }

  Future<Map<String, dynamic>> stopCamera() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'stop',
    });
  }

  Future<Map<String, dynamic>> getCameraFrame() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'frame',
    });
  }
  
  // Audio control
  Future<Map<String, dynamic>> playSound(String soundName) async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'play',
      'argument': soundName,
    });
  }
  
  Future<Map<String, dynamic>> speakText(String text) async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'speak',
      'argument': text,
    });
  }
  
  Future<Map<String, dynamic>> listSounds() async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'list',
    });
  }
  
  /// Dispose resources
  void dispose() {
    // Cancel all pending requests
    _handleError(RobotAPIException('Service disposed', 0));
    
    disconnect();
    _responseController.close();
    _connectionStatusController.close();
  }
}