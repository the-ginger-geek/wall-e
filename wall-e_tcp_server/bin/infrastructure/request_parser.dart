import 'dart:convert';
import '../domain/requests/request.dart';
import '../domain/requests/move.dart';
import '../domain/requests/servo.dart';
import '../domain/requests/animation.dart';
import '../domain/requests/stop.dart';
import '../domain/requests/camera.dart';
import '../domain/requests/audio.dart';

class RequestParser {

  static Request parseRequest(String requestBody) {
    try {
      final Map<String, dynamic> json = requestBody.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(requestBody))
          : {};

      if (json.containsKey('type')) {
        final requestType = json['type'] as String;
        switch(requestType) {
          case 'move':
            return Move.fromJson(json);
          case 'servo':
            return Servo.fromJson(json);
          case 'animation':
            return Animation.fromJson(json);
          case 'stop':
            return Stop.fromJson(json);
          case 'camera':
            return Camera.fromJson(json);
          case 'audio':
            return Audio.fromJson(json);
          default:
            throw FormatException('Unknown request type: $requestType');
        }
      } else {
        throw FormatException('Invalid request format: Missing "type" key');
      }
    } catch (e) {
      throw FormatException('Invalid request format: $e');
    }
  }
}