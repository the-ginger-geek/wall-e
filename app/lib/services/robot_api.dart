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

class RobotAPI {
  static const String robotHost = '192.168.0.155';
  static const int robotPort = 5001;
  
  static Socket? _socket;
  static final StreamController<String> _responseController = StreamController<String>.broadcast();
  static final Completer<void> _connectionCompleter = Completer<void>();
  static bool _isConnected = false;
  static bool _isConnecting = false;
  
  // Connect to the robot TCP server
  static Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      return;
    }
    
    _isConnecting = true;
    
    try {
      _socket = await Socket.connect(robotHost, robotPort);
      _isConnected = true;
      _isConnecting = false;
      
      // Listen for responses
      _socket!.listen(
        (List<int> data) {
          final response = String.fromCharCodes(data).trim();
          _responseController.add(response);
        },
        onError: (error) {
          _isConnected = false;
          _responseController.addError(RobotAPIException('Connection error: $error', 0));
        },
        onDone: () {
          _isConnected = false;
        },
      );
      
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.complete();
      }
    } catch (e) {
      _isConnecting = false;
      throw RobotAPIException('Failed to connect: $e', 0);
    }
  }
  
  // Disconnect from the robot
  static Future<void> disconnect() async {
    if (_isConnected) {
      try {
        await _sendCommand('quit');
      } catch (e) {
        // Ignore errors when disconnecting
      }
    }
    
    _socket?.close();
    _socket = null;
    _isConnected = false;
  }
  
  // Send a JSON request and wait for response
  static Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> request) async {
    if (!_isConnected) {
      await connect();
    }
    
    if (_socket == null) {
      throw RobotAPIException('Not connected to robot', 0);
    }
    
    try {
      // Send JSON request
      final jsonRequest = jsonEncode(request);
      _socket!.write('$jsonRequest\n');
      
      // Wait for response
      final response = await _responseController.stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw RobotAPIException('Request timeout', 0),
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
      if (e is RobotAPIException) {
        rethrow;
      }
      throw RobotAPIException('Request failed: $e', 0);
    }
  }
  
  // Legacy text command support (for disconnect)
  static Future<Map<String, dynamic>> _sendCommand(String command) async {
    if (!_isConnected) {
      await connect();
    }
    
    if (_socket == null) {
      throw RobotAPIException('Not connected to robot', 0);
    }
    
    try {
      // Send command
      _socket!.write('$command\n');
      
      // Wait for response
      final response = await _responseController.stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw RobotAPIException('Command timeout', 0),
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
      if (e is RobotAPIException) {
        rethrow;
      }
      throw RobotAPIException('Command failed: $e', 0);
    }
  }
  
  // Check if connected
  static bool get isConnected => _isConnected;
  
  // Movement control
  static Future<Map<String, dynamic>> move(int x, int y) async {
    return await _sendRequest({
      'type': 'move',
      'x': x.toDouble(),
      'y': y.toDouble(),
    });
  }
  
  // Servo control
  static Future<Map<String, dynamic>> controlServo(String servo, int value) async {
    return await _sendRequest({
      'type': 'servo',
      'name': servo,
      'value': value.toDouble(),
    });
  }
  
  // Multiple servo control (send multiple commands)
  static Future<List<Map<String, dynamic>>> controlMultipleServos(Map<String, int> servos) async {
    final List<Map<String, dynamic>> results = [];
    
    for (final entry in servos.entries) {
      final result = await controlServo(entry.key, entry.value);
      results.add(result);
    }
    
    return results;
  }
  
  // Animation control
  static Future<Map<String, dynamic>> playAnimation(int animationId) async {
    return await _sendRequest({
      'type': 'animation',
      'id': animationId.toString(),
    });
  }
  
  // Status check (not implemented in Dart server yet)
  static Future<Map<String, dynamic>> getStatus() async {
    // For now, return a mock status since Dart server doesn't have status command yet
    return {
      'status': 'OK',
      'message': 'Status check not yet implemented in Dart server',
      'statusCode': 200,
    };
  }
  
  // Emergency stop
  static Future<Map<String, dynamic>> emergencyStop() async {
    return await _sendRequest({
      'type': 'stop',
    });
  }
  
  // Disconnect
  static Future<Map<String, dynamic>> disconnectRobot() async {
    return await _sendRequest({
      'type': 'disconnect',
    });
  }
  
  // Settings control (not implemented in Dart server yet)
  static Future<Map<String, dynamic>> updateSetting(String setting, dynamic value) async {
    // Settings not implemented in Dart server yet
    return {
      'status': 'OK',
      'message': 'Settings not yet implemented in Dart server',
      'statusCode': 200,
    };
  }
  
  // Specific setting methods for better type safety
  static Future<Map<String, dynamic>> updateSteeringOffset(int offset) async {
    if (offset < -100 || offset > 100) {
      throw RobotAPIException('Steering offset must be between -100 and 100', 0);
    }
    return await updateSetting('steering_offset', offset);
  }
  
  static Future<Map<String, dynamic>> updateMotorDeadzone(int deadzone) async {
    if (deadzone < 0 || deadzone > 250) {
      throw RobotAPIException('Motor deadzone must be between 0 and 250', 0);
    }
    return await updateSetting('motor_deadzone', deadzone);
  }
  
  static Future<Map<String, dynamic>> updateAutoMode(bool enabled) async {
    return await updateSetting('auto_mode', enabled ? 1 : 0);
  }

  // Camera control
  static Future<Map<String, dynamic>> startCamera() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'start',
    });
  }

  static Future<Map<String, dynamic>> stopCamera() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'stop',
    });
  }

  static Future<Map<String, dynamic>> getCameraFrame() async {
    return await _sendRequest({
      'type': 'camera',
      'command': 'frame',
    });
  }
  
  // Audio control
  static Future<Map<String, dynamic>> playSound(String soundName) async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'play',
      'argument': soundName,
    });
  }
  
  static Future<Map<String, dynamic>> speakText(String text) async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'speak',
      'argument': text,
    });
  }
  
  static Future<Map<String, dynamic>> listSounds() async {
    return await _sendRequest({
      'type': 'audio',
      'command': 'list',
    });
  }
}

class RobotStatus {
  final String status;
  final bool arduinoConnected;
  final String batteryLevel = 'Unknown';
  
  RobotStatus({
    required this.status,
    required this.arduinoConnected,
  });
  
  factory RobotStatus.fromJson(Map<String, dynamic> json) {
    final robotStatus = json['status'] ?? {};

    return RobotStatus(
      status: robotStatus,
      arduinoConnected: robotStatus == 'OK',
    );
  }
  
  // Legacy compatibility for camera_active
  bool get cameraActive => arduinoConnected;
}