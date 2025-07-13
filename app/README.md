# WALL-E Flutter Controller

A Flutter mobile application to control the WALL-E robot through TCP/IP socket connection.

## Features

- **Movement Control**: Directional pad for forward/backward and left/right movement
- **Servo Control**: Individual sliders for all 7 servo motors (head, neck, arms, eyes)
- **Animation Control**: Play predefined animations (reset, bootup, inquisitive)
- **Status Monitoring**: Real-time display of robot connection, battery level, and server status
- **Settings Control**: Adjust steering offset, motor deadzone, and auto mode
- **Emergency Stop**: Immediate stop functionality for safety
- **TCP Connection**: Persistent socket connection for low-latency control
- **Camera Control**: Real-time camera streaming and frame capture
- **Audio Control**: Sound playback and text-to-speech functionality

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- WALL-E robot running the Dart TCP server at `192.168.0.155:5001`
- Mobile device connected to the same network as the robot

## Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## TCP Integration

The app communicates with the WALL-E robot through JSON-based TCP requests:

- `{"type": "move", "x": 50, "y": 0}` - Control robot movement
- `{"type": "servo", "name": "head_rotation", "value": 75}` - Control individual servos
- `{"type": "animation", "id": "1"}` - Play animations
- `{"type": "camera", "command": "start"}` - Camera control
- `{"type": "audio", "command": "play", "argument": "hello.wav"}` - Audio control
- `{"type": "stop"}` - Emergency stop
- `{"type": "disconnect"}` - Disconnect from robot

For complete API documentation, see [DART_TCP_API_DOCUMENTATION.md](../DART_TCP_API_DOCUMENTATION.md).

## Usage

1. **Launch the app** - The app will automatically connect to the robot
2. **Movement Tab** - Use the virtual joystick and directional buttons to move the robot
3. **Camera Tab** - Start camera streaming and view real-time video feed
4. **Audio Tab** - Play sound effects and use text-to-speech functionality
5. **Servos Tab** - Adjust individual servo positions with sliders
6. **Animations Tab** - Play predefined animation sequences
7. **Settings Tab** - Adjust robot calibration and behavior settings
8. **Emergency Stop** - Red button available on the main screen for safety

## Network Configuration

The robot IP address and port are configured in `lib/services/robot_api_service.dart`. To change the connection:

```dart
static const String _robotHost = 'YOUR_ROBOT_IP';
static const int _robotPort = 5001;
```

## Project Structure

The app follows MVVM (Model-View-ViewModel) architecture:

```
lib/
├── main.dart                           # App entry point with service locator
├── core/
│   └── service_locator.dart           # Dependency injection setup
├── services/
│   └── robot_api_service.dart         # TCP socket communication service
├── viewmodels/                        # Business logic layer
│   ├── base_viewmodel.dart            # Base ViewModel with common patterns
│   ├── robot_control_viewmodel.dart   # Main screen logic
│   ├── movement_viewmodel.dart        # Movement control logic
│   ├── camera_viewmodel.dart          # Camera streaming logic
│   ├── audio_viewmodel.dart           # Audio control logic
│   ├── servo_viewmodel.dart           # Servo control logic
│   ├── animation_viewmodel.dart       # Animation logic
│   └── settings_viewmodel.dart        # Settings management logic
├── screens/
│   └── robot_control_screen_mvvm.dart # Main control screen (MVVM)
└── widgets/                           # UI components (MVVM)
    ├── movement_control_mvvm.dart     # Virtual joystick and buttons
    ├── camera_control_mvvm.dart       # Camera streaming interface
    ├── audio_control_mvvm.dart        # Sound and TTS controls
    ├── servo_control_mvvm.dart        # Servo sliders
    ├── animation_control_mvvm.dart     # Animation grid
    ├── settings_control_mvvm.dart      # Settings interface
    └── status_display_mvvm.dart       # Connection status display
```

## Safety Features

- Emergency stop button prominently displayed
- Connection status monitoring
- Error handling with user feedback
- Automatic movement stop when buttons are released
- Persistent TCP connection with automatic reconnection
- Proper connection cleanup on app exit

## Troubleshooting

1. **Connection Issues**: Ensure your device is on the same network as the robot
2. **TCP Errors**: Check that the robot's Dart TCP server is running on port 5001
3. **Service Status**: Verify the service is running with `sudo systemctl status walle-tcp`
4. **Servo Control**: Verify Arduino connection in the status display
5. **Camera Issues**: Check camera permissions and hardware availability
6. **Audio Problems**: Verify sound files exist and audio system is working
7. **Socket Timeout**: If commands timeout, check network connectivity

## Contributing

Feel free to submit issues and pull requests to improve the controller functionality.