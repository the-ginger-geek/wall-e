import 'dart:convert';
import 'dart:io';

import 'infrastructure/logger.dart';
import 'infrastructure/request_parser.dart';
import 'infrastructure/action_handler.dart';
import 'infrastructure/arduino_device_controller.dart';

void main(List<String> arguments) {
  Logger.init();
  ArduinoDeviceController.init();
  startServer();
}

void startServer() {
  ServerSocket.bind('0.0.0.0', 5001).then((ServerSocket server) {
    server.listen((Socket socket) {
      // Send a welcome message to the new client
      _welcomeNewClient(socket);

      socket.listen((List<int> data) async {
        final message = String.fromCharCodes(data);
        Logger.writeLog('Request: $message');

        final request = RequestParser.parseRequest(message);
        final response = await RequestHandler.handleRequest(request);
        Logger.writeLog('Response: ${response.message}');
        socket.writeln(jsonEncode(response.toJson()));
      });
    });
  });
}

/// Welcomes a new client by sending a welcome message.
void _welcomeNewClient(Socket socket) {
  socket.writeln(jsonEncode({
    "status": "OK",
    "message": "Connected to Wall-E Dart TCP Control Server",
    "version": "1.1",
    "dart_version": Platform.version,
    "arduino_connected": ArduinoDeviceController.getInstance().isConnected,
    "camera_available": true,
    "audio_available": true
  }));
}