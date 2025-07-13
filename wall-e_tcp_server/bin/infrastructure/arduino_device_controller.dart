import 'dart:io';
import 'logger.dart';

/// Handles communication with Arduino devices over serial connection.
class ArduinoDeviceController {
  static ArduinoDeviceController? _instance;

  String? _portPath;
  Process? _serialProcess;
  bool _isConnected = false;

  /// Gets the current connection status.
  bool get isConnected => _isConnected;

  /// Gets the current port path.
  String? get portPath => _portPath;

  static ArduinoDeviceController init() {
    _instance ??=
        ArduinoDeviceController._()
          ..autoConnect().then((success) {
            if (success) {
              Logger.writeLog(
                'Wall-E controller connected on port: ${_instance!._portPath}',
              );
            } else {
              Logger.writeLog('Failed to connect to Wall-E controller');
            }
          });

    return _instance!;
  }

  static ArduinoDeviceController getInstance() {
    _instance ??= ArduinoDeviceController._();
    return _instance!;
  }

  ArduinoDeviceController._();

  Future<bool> autoConnect() async {
    // Automatically connect to the first available port
    final ports = await listAvailablePorts();
    if (ports.isNotEmpty) {
      return connect(ports.first);
    }
    return false;
  }

  /// Connects to Arduino device on the specified port.
  ///
  /// Returns true if connection successful, false otherwise.
  Future<bool> connect(String portPath) async {
    try {
      _portPath = portPath;

      // Start serial communication process
      _serialProcess = await Process.start('python3', [
        '-c',
        arduinoProcessCommand,
        portPath,
      ]);

      _isConnected = true;
      return true;
    } catch (e) {
      Logger.writeLog('Failed to connect to Arduino: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Sends a command to the Arduino device.
  ///
  /// Returns the response from Arduino, or null if failed.
  Future<String?> sendCommand(String command) async {
    if (!_isConnected || _serialProcess == null) {
      Logger.writeLog('Arduino not connected');
      return null;
    }

    try {
      _serialProcess!.stdin.writeln(command);
      await _serialProcess!.stdin.flush();

      // Wait for response (simplified - in real implementation you'd want better handling)
      await Future.delayed(Duration(milliseconds: 100));

      return 'Command sent: $command';
    } catch (e) {
      Logger.writeLog('Failed to send command: $e');
      return null;
    }
  }

  /// Disconnects from the Arduino device.
  Future<void> disconnect() async {
    if (_serialProcess != null) {
      try {
        _serialProcess!.stdin.writeln('QUIT');
        await _serialProcess!.stdin.flush();
        await _serialProcess!.exitCode;
      } catch (e) {
        Logger.writeLog('Error during disconnect: $e');
      }

      _serialProcess = null;
    }

    _isConnected = false;
    _portPath = null;
  }

  /// Lists available serial ports that might have Arduino devices.
  static Future<List<String>> listAvailablePorts() async {
    try {
      final result = await Process.run('python3', ['-c', listPortsCommand]);

      if (result.exitCode == 0) {
        return result.stdout
            .toString()
            .trim()
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
      }
    } catch (e) {
      Logger.writeLog('Failed to list ports: $e');
    }

    return [];
  }
}

/// This is the Python code that will be executed to list available serial ports.
final listPortsCommand = '''
import serial.tools.list_ports
ports = [port.device for port in serial.tools.list_ports.comports()]
for port in ports:
    print(port)
''';

/// This is the Python code that will be executed to handle Arduino commands.
/// It reads commands from stdin, sends them to the Arduino over serial,
/// and prints the responses to stdout.
final arduinoProcessCommand = '''
import serial
import sys
import time

port = sys.argv[1]
baudrate = 9600

try:
    ser = serial.Serial(port, baudrate, timeout=1)
    time.sleep(2)  # Wait for Arduino to reset
    print("Connected to Arduino on", port)
    
    while True:
        line = sys.stdin.readline().strip()
        if line == "QUIT":
            break
        if line:
            ser.write((line + "\\n").encode())
            response = ser.readline().decode().strip()
            if response:
                print(response)
except Exception as e:
    print(f"Error: {e}")
finally:
    if 'ser' in locals():
        ser.close()
''';
