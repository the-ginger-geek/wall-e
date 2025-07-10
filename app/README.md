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

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- WALL-E robot running the TCP server at `192.168.0.155:5000`
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

The app communicates with the WALL-E robot through TCP socket commands:

- `status` - Check robot status
- `move <x> <y>` - Control robot movement
- `servo <name> <value>` - Control individual servos
- `animation <id>` - Play animations
- `setting <name> <value>` - Update settings
- `stop` - Emergency stop
- `quit` - Disconnect from robot

## Usage

1. **Launch the app** - The app will automatically connect to the robot
2. **Movement Tab** - Use the directional pad to move the robot
3. **Servos Tab** - Adjust individual servo positions with sliders
4. **Animations Tab** - Play predefined animation sequences
5. **Settings Tab** - Adjust robot calibration and behavior settings
6. **Emergency Stop** - Red button available on the main screen for safety

## Network Configuration

The robot IP address and port are configured in `lib/services/robot_api.dart`. To change the connection:

```dart
static const String robotHost = 'YOUR_ROBOT_IP';
static const int robotPort = 5000;
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   └── robot_control_screen.dart # Main control screen
├── widgets/
│   ├── movement_control.dart    # Movement directional pad
│   ├── servo_control.dart       # Servo sliders
│   ├── animation_control.dart   # Animation buttons
│   ├── settings_control.dart    # Settings adjustments
│   └── status_display.dart      # Status information
└── services/
    └── robot_api.dart           # TCP socket communication
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
2. **TCP Errors**: Check that the robot's TCP server is running on port 5000
3. **Servo Control**: Verify Arduino connection in the status display
4. **Battery Status**: Monitor battery level in the status display
5. **Socket Timeout**: If commands timeout, check network connectivity

## Contributing

Feel free to submit issues and pull requests to improve the controller functionality.