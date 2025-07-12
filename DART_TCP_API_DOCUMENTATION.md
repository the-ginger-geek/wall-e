# WALL-E Dart TCP Server API Documentation

This document describes the JSON-based TCP/IP protocol for controlling the WALL-E robot using the new Dart TCP server.

## Connection Details
```
Host: 192.168.0.155 (or your robot's IP)
Port: 5001
Protocol: TCP/IP with JSON messages
```

## Protocol Overview

The Wall-E Dart TCP server uses a JSON-based protocol. All commands are sent as JSON objects, and responses are returned as JSON objects.

### Connection Flow
1. Connect to the robot via TCP socket on port 5001
2. Receive welcome message as JSON
3. Send commands as JSON objects
4. Receive responses as JSON objects
5. Send disconnect request or close socket to disconnect

### Welcome Message
Upon connection, the server sends a welcome message:
```json
{
  "status": "OK",
  "message": "Connected to Wall-E Dart TCP Control Server",
  "version": "1.1",
  "dart_version": "Dart VM version: ...",
  "arduino_connected": true,
  "camera_available": true,
  "audio_available": true
}
```

## Request Format

All requests must follow this JSON structure:
```json
{
  "type": "<command_type>",
  // additional parameters based on command type
}
```

## Response Format

All responses follow this JSON structure:
```json
{
  "status": "OK" | "Error",
  "statusCode": 200 | 400 | 404 | 500,
  "message": "Description of result or error"
}
```

## Available Commands

### 1. Movement Control

**Request:**
```json
{
  "type": "move",
  "x": 50.0,
  "y": -30.0
}
```

**Parameters:**
- `x`: Turn value (-100.0 to 100.0, negative = left, positive = right)
- `y`: Move value (-100.0 to 100.0, negative = backward, positive = forward)

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Move(50.0, -30.0) action handled successfully"
}
```

### 2. Servo Control

**Request:**
```json
{
  "type": "servo",
  "name": "head_rotation",
  "value": 75.0
}
```

**Parameters:**
- `name`: Servo name (see Available Servos below)
- `value`: Position value (0.0 to 100.0)

**Available Servos:**
- `head_rotation` - Head rotation servo (G)
- `neck_top` - Neck top servo (T)
- `neck_bottom` - Neck bottom servo (B)
- `arm_left` - Left arm servo (L)
- `arm_right` - Right arm servo (R)
- `eye_left` - Left eye servo (E)
- `eye_right` - Right eye servo (U)

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Action handled successfully: servo head_rotation 75.00"
}
```

### 3. Animation Control

**Request:**
```json
{
  "type": "animation",
  "id": "1"
}
```

**Parameters:**
- `id`: Animation ID as string

**Response:**
```json
{
  "status": "OK", 
  "statusCode": 200,
  "message": "Action handled successfully: A1"
}
```

### 4. Emergency Stop

**Request:**
```json
{
  "type": "stop"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Wall-E stop command issued successfully."
}
```

### 5. Camera Control

#### Start Camera
**Request:**
```json
{
  "type": "camera",
  "command": "start"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Camera started successfully"
}
```

#### Stop Camera
**Request:**
```json
{
  "type": "camera",
  "command": "stop"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Camera stopped successfully"
}
```

#### Get Frame
**Request:**
```json
{
  "type": "camera",
  "command": "frame"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Frame captured: <base64_image_data>"
}
```

### 6. Audio Control

#### Play Sound
**Request:**
```json
{
  "type": "audio",
  "command": "play",
  "argument": "hello.wav"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Playing sound: hello.wav"
}
```

#### Text-to-Speech
**Request:**
```json
{
  "type": "audio", 
  "command": "speak",
  "argument": "Hello, I am WALL-E!"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Speaking: Hello, I am WALL-E!"
}
```

#### List Available Sounds
**Request:**
```json
{
  "type": "audio",
  "command": "list"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Available sounds: hello.wav, goodbye.wav, beep.wav"
}
```

### 7. Disconnect

**Request:**
```json
{
  "type": "disconnect"
}
```

**Response:**
```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Wall-E controller disconnected successfully."
}
```

## Error Handling

When an error occurs, the server responds with:
```json
{
  "status": "Error",
  "statusCode": 400 | 404 | 500,
  "message": "Error description"
}
```

**Common Error Codes:**
- `400`: Bad Request (invalid parameters)
- `404`: Not Found (sound file not found, etc.)
- `500`: Internal Server Error (Arduino not connected, etc.)

## Example Client Session

```bash
# Connect to server
telnet 192.168.0.155 5001

# Server sends welcome message
{"status":"OK","message":"Connected to Wall-E Dart TCP Control Server",...}

# Send movement command
{"type":"move","x":50.0,"y":0.0}

# Server responds
{"status":"OK","statusCode":200,"message":"Move(50.0, 0.0) action handled successfully"}

# Send servo command
{"type":"servo","name":"head_rotation","value":75.0}

# Server responds
{"status":"OK","statusCode":200,"message":"Action handled successfully: servo head_rotation 75.00"}

# Disconnect
{"type":"disconnect"}

# Server responds and closes connection
{"status":"OK","statusCode":200,"message":"Wall-E controller disconnected successfully."}
```

## Service Installation

### Manual Installation

1. **Copy service file:**
```bash
sudo cp walle-tcp.service /etc/systemd/system/
```

2. **Reload systemd:**
```bash
sudo systemctl daemon-reload
```

3. **Enable service:**
```bash
sudo systemctl enable walle-tcp
```

4. **Start service:**
```bash
sudo systemctl start walle-tcp
```

### Automated Installation

Use the provided setup script:
```bash
./setup-dart-tcp-service.sh
```

### Service Management

- **Check status:** `sudo systemctl status walle-tcp`
- **View logs:** `sudo journalctl -u walle-tcp -f`
- **Restart:** `sudo systemctl restart walle-tcp`
- **Stop:** `sudo systemctl stop walle-tcp`

### Testing Service

Use the provided test script:
```bash
./test-dart-tcp-service.sh
```

## Differences from Python TCP Server

The Dart TCP server differs from the original Python TCP server:

1. **Protocol:** JSON-based instead of text commands
2. **Port:** Runs on port 5001 instead of 5000
3. **Architecture:** Domain-driven design with better separation of concerns
4. **Performance:** Compiled executable vs interpreted Python
5. **Features:** Currently implements core features (movement, servo, animation, camera, audio)

## Client Libraries

### Flutter/Dart Client
The Flutter app in the `app/` directory provides a complete client implementation with GUI controls for all robot functions.

### Custom Clients
To create a custom client:

1. Connect to TCP port 5001
2. Send JSON requests as specified above
3. Parse JSON responses
4. Handle connection management and errors

Example in Python:
```python
import socket
import json

# Connect
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('192.168.0.155', 5001))

# Send command
command = {"type": "move", "x": 50.0, "y": 0.0}
sock.send(json.dumps(command).encode() + b'\n')

# Receive response
response = sock.recv(1024).decode()
print(json.loads(response))

# Disconnect
sock.close()
```