import 'dart:io';
import 'logger.dart';

/// Camera streaming for TCP server
class CameraStreamer {
  static CameraStreamer? _instance;
  Process? _cameraProcess;
  bool _streaming = false;

  static CameraStreamer getInstance() {
    _instance ??= CameraStreamer._();
    return _instance!;
  }

  CameraStreamer._();

  /// Gets the current streaming status
  bool get isStreaming => _streaming;

  /// Start camera streaming
  Future<bool> startCamera() async {
    try {
      if (_cameraProcess == null) {
        _cameraProcess = await Process.start('python3', [
          '-c',
          _cameraProcessCommand,
        ]);
        _streaming = true;
        Logger.writeLog('Camera streaming started');
        return true;
      }
    } catch (e) {
      Logger.writeLog('Camera start error: $e');
      return false;
    }
    return _streaming;
  }

  /// Stop camera streaming
  Future<bool> stopCamera() async {
    try {
      if (_cameraProcess != null) {
        _cameraProcess!.stdin.writeln('QUIT');
        await _cameraProcess!.stdin.flush();
        await _cameraProcess!.exitCode;
        _cameraProcess = null;
      }
      _streaming = false;
      Logger.writeLog('Camera streaming stopped');
      return true;
    } catch (e) {
      Logger.writeLog('Camera stop error: $e');
      return false;
    }
  }

  /// Get current camera frame as base64 encoded JPEG
  Future<String?> getFrame() async {
    if (!_streaming || _cameraProcess == null) {
      return null;
    }

    try {
      _cameraProcess!.stdin.writeln('FRAME');
      await _cameraProcess!.stdin.flush();

      // Wait for response with timeout
      await Future.delayed(Duration(milliseconds: 200));
      
      // In a real implementation, you'd read from stdout
      // For now, return a placeholder response
      return 'frame_data_placeholder';
    } catch (e) {
      Logger.writeLog('Frame capture error: $e');
      return null;
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await stopCamera();
  }
}

/// Python code for camera streaming using PiCamera2
final _cameraProcessCommand = '''
import sys
import time
import base64
import io

try:
    from picamera2 import Picamera2
    import cv2
    
    picam2 = None
    
    def start_camera():
        global picam2
        try:
            picam2 = Picamera2()
            config = picam2.create_video_configuration(main={"size": (640, 480)})
            picam2.configure(config)
            picam2.start()
            print("Camera started successfully")
            return True
        except Exception as e:
            print(f"Camera start error: {e}")
            return False
    
    def capture_frame():
        global picam2
        if picam2 is None:
            return None
        try:
            # Capture frame
            frame = picam2.capture_array()
            
            # Convert to JPEG
            _, jpeg = cv2.imencode('.jpg', frame)
            
            # Encode as base64
            frame_b64 = base64.b64encode(jpeg.tobytes()).decode('utf-8')
            return frame_b64
        except Exception as e:
            print(f"Frame capture error: {e}")
            return None
    
    def stop_camera():
        global picam2
        if picam2 is not None:
            try:
                picam2.stop()
                picam2.close()
                picam2 = None
                print("Camera stopped")
            except Exception as e:
                print(f"Camera stop error: {e}")
    
    # Start camera automatically
    if start_camera():
        print("Camera ready")
        
        while True:
            try:
                command = sys.stdin.readline().strip()
                if command == "QUIT":
                    break
                elif command == "FRAME":
                    frame_data = capture_frame()
                    if frame_data:
                        print(f"FRAME_DATA:{frame_data}")
                    else:
                        print("FRAME_ERROR:No frame available")
                elif command == "START":
                    if start_camera():
                        print("CAMERA_STARTED")
                    else:
                        print("CAMERA_START_ERROR")
                elif command == "STOP":
                    stop_camera()
                    print("CAMERA_STOPPED")
                    
            except Exception as e:
                print(f"Command error: {e}")
                break
    else:
        print("Failed to initialize camera")
        
except ImportError:
    print("Camera libraries not available - using mock implementation")
    # Mock implementation for development
    while True:
        try:
            command = sys.stdin.readline().strip()
            if command == "QUIT":
                break
            elif command == "FRAME":
                # Return mock base64 data
                mock_data = base64.b64encode(b"mock_jpeg_data").decode('utf-8')
                print(f"FRAME_DATA:{mock_data}")
            elif command == "START":
                print("CAMERA_STARTED")
            elif command == "STOP":
                print("CAMERA_STOPPED")
        except Exception as e:
            print(f"Mock command error: {e}")
            break
            
except Exception as e:
    print(f"Camera initialization error: {e}")
finally:
    if 'picam2' in locals() and picam2 is not None:
        try:
            picam2.stop()
            picam2.close()
        except:
            pass
''';