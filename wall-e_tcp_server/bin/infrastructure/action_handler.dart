import '../domain/responses/response.dart';
import '../domain/requests/request.dart';
import '../domain/requests/stop.dart';
import '../domain/requests/disconnect.dart';
import '../domain/requests/move.dart';
import '../domain/requests/camera.dart';
import '../domain/requests/audio.dart';
import '../domain/requests/status.dart';
import 'arduino_device_controller.dart';
import 'camera_streamer.dart';
import 'audio_player.dart';

/// Handles actions from requests, like move or turn ect.
class RequestHandler {
  /// Switches over the request using pattern matching to determine the action type.
  ///
  /// Returns a string message indicating the result of the action.
  static Future<Response> handleRequest(Request request) async {
    try {
      final deviceController = ArduinoDeviceController.getInstance();

      if (request is Disconnect) {
        return _processDisconnect(deviceController);
      }

      if (request is Stop) {
        return _processStop(deviceController);
      }

      if (request is Move) {
        return await _processMove(request, deviceController);
      }

      if (request is Camera) {
        return await _processCamera(request);
      }

      if (request is Audio) {
        return await _processAudio(request);
      }

      if (request is Status) {
        return _processStatus(deviceController);
      }

      final message = await deviceController.sendCommand(
        request.toExternalAction,
      );
      return Response(
        status: 'OK',
        statusCode: 200,
        message: 'Action handled successfully: ${message.toString}',
      );
    } catch (e) {
      return Response(
        status: 'Error',
        statusCode: 500,
        message: 'Failed to handle request: $e',
      );
    }
  }

  static Future<Response> _processMove(
    Move request,
    ArduinoDeviceController deviceController,
  ) async {
    final x = request.x.round();
    final y = request.y.round();

    if (x > -100 && x < 100) {
      await deviceController.sendCommand(
        'X$x',
      );
    }
    if (y > -100 && y < 100) {
      await deviceController.sendCommand(
        'Y$y',
      );
    }

    return Response(
      status: 'OK',
      statusCode: 200,
      message: 'Move($x, $y) action handled successfully',
    );
  }

  static Response _processStop(ArduinoDeviceController deviceController) {
    deviceController.sendCommand('X0');
    deviceController.sendCommand('Y0');
    return Response(
      status: 'OK',
      statusCode: 200,
      message: 'Wall-E stop command issued successfully.',
    );
  }

  static Response _processDisconnect(ArduinoDeviceController deviceController) {
    if (!deviceController.isConnected) {
      return Response(
        status: 'Error',
        statusCode: 400,
        message: 'Wall-E controller is not connected.',
      );
    }

    deviceController.disconnect();
    return Response(
      status: 'OK',
      statusCode: 200,
      message: 'Wall-E controller disconnected successfully.',
    );
  }

  static Future<Response> _processCamera(Camera request) async {
    final camera = CameraStreamer.getInstance();
    
    switch (request.command) {
      case CameraCommand.start:
        if (await camera.startCamera()) {
          return Response(
            status: 'OK',
            statusCode: 200,
            message: 'Camera started successfully',
          );
        } else {
          return Response(
            status: 'Error',
            statusCode: 500,
            message: 'Failed to start camera',
          );
        }
      
      case CameraCommand.stop:
        if (await camera.stopCamera()) {
          return Response(
            status: 'OK',
            statusCode: 200,
            message: 'Camera stopped successfully',
          );
        } else {
          return Response(
            status: 'Error',
            statusCode: 500,
            message: 'Failed to stop camera',
          );
        }
      
      case CameraCommand.frame:
        final frameData = await camera.getFrame();
        if (frameData != null) {
          return Response(
            status: 'OK',
            statusCode: 200,
            message: 'Frame captured: $frameData',
          );
        } else {
          return Response(
            status: 'Error',
            statusCode: 404,
            message: 'No frame available',
          );
        }
    }
  }

  static Future<Response> _processAudio(Audio request) async {
    final audio = AudioPlayer.getInstance();
    
    switch (request.command) {
      case AudioCommand.play:
        if (request.argument != null) {
          if (await audio.playSound(request.argument!)) {
            return Response(
              status: 'OK',
              statusCode: 200,
              message: 'Playing sound: ${request.argument}',
            );
          } else {
            return Response(
              status: 'Error',
              statusCode: 404,
              message: 'Sound not found: ${request.argument}',
            );
          }
        } else {
          return Response(
            status: 'Error',
            statusCode: 400,
            message: 'Sound name required for play command',
          );
        }
      
      case AudioCommand.speak:
        if (request.argument != null) {
          if (await audio.textToSpeech(request.argument!)) {
            return Response(
              status: 'OK',
              statusCode: 200,
              message: 'Speaking: ${request.argument}',
            );
          } else {
            return Response(
              status: 'Error',
              statusCode: 500,
              message: 'Text-to-speech failed',
            );
          }
        } else {
          return Response(
            status: 'Error',
            statusCode: 400,
            message: 'Text required for speak command',
          );
        }
      
      case AudioCommand.list:
        final sounds = await audio.getSoundList();
        return Response(
          status: 'OK',
          statusCode: 200,
          message: 'Available sounds: ${sounds.join(", ")}',
        );
    }
  }

  static Response _processStatus(ArduinoDeviceController deviceController) {
    return Response(
      status: 'OK',
      statusCode: 200,
      message: 'Status retrieved successfully',
    );
  }
}
