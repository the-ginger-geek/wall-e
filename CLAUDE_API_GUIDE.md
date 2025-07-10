# WALL-E Robot Control Protocol - Claude Integration Guide

This document provides Claude AI with the information needed to control a WALL-E robot through the TCP/IP protocol.

## System Overview

You are controlling a physical WALL-E robot located at `192.168.0.155:5000`. The robot has:
- **Movement motors** for forward/backward and left/right motion
- **7 servo motors** for head, neck, arms, and eyes
- **Predefined animations** for complex movements
- **Status monitoring** for battery and connection health

## Connection Method

The robot now uses a **TCP/IP socket connection** instead of HTTP. This provides:
- Lower latency for real-time control
- Persistent connection for continuous communication
- Simple text-based command protocol
- JSON responses for easy parsing

## Available Commands

### Movement Control
**Command:** `move <x> <y>`
**Purpose:** Control robot wheels for movement
**Parameters:**
- `x`: Turn control (-100 = full left, 0 = straight, 100 = full right)
- `y`: Speed control (-100 = full backward, 0 = stop, 100 = full forward)

**Example:**
```
move 0 50
```

**Response:**
```json
{
  "status": "OK",
  "x": 0,
  "y": 50
}
```

### Servo Control
**Command:** `servo <name> <value>`
**Purpose:** Control individual servo motors
**Parameters:**
- `name`: Servo name (see valid servos below)
- `value`: Position (0-100)

**Valid Servos:**
- `head_rotation` - Turn head left/right
- `neck_top` - Tilt head up/down (upper joint)
- `neck_bottom` - Tilt head up/down (lower joint)
- `arm_left` - Move left arm
- `arm_right` - Move right arm
- `eye_left` - Move left eye
- `eye_right` - Move right eye

**Example:**
```
servo head_rotation 75
```

**Response:**
```json
{
  "status": "OK",
  "servo": "head_rotation",
  "value": 75
}
```

### Animation Control
**Command:** `animation <id>`
**Purpose:** Play predefined animation sequences
**Parameters:**
- `id`: Animation ID (integer)

**Available Animations:**
- `0` - Reset all servos to neutral positions
- `1` - Bootup sequence (8.6 seconds)
- `2` - Inquisitive sequence (18 seconds)

**Example:**
```
animation 1
```

**Response:**
```json
{
  "status": "OK",
  "animation": 1
}
```

### Status Check
**Command:** `status`
**Purpose:** Get current robot status
**No parameters required**

**Example:**
```
status
```

**Response:**
```json
{
  "status": "OK",
  "robot_status": {
    "arduino_connected": true,
    "battery_level": "85",
    "server_running": true
  }
}
```

### Emergency Stop
**Command:** `stop`
**Purpose:** Immediately stop all robot movement
**No parameters required**

**Example:**
```
stop
```

**Response:**
```json
{
  "status": "OK",
  "msg": "Robot stopped"
}
```

### Settings Control
**Command:** `setting <name> <value>`
**Purpose:** Update robot calibration settings
**Parameters:**
- `name`: Setting name
- `value`: Setting value

**Valid Settings:**
- `steering_offset` (-100 to 100) - Calibrate steering
- `motor_deadzone` (0 to 250) - Motor sensitivity threshold
- `auto_mode` (0 or 1) - Enable/disable automatic servo animations

**Example:**
```
setting steering_offset 10
```

**Response:**
```json
{
  "status": "OK",
  "setting": "steering_offset",
  "value": 10
}
```

### Disconnect
**Command:** `quit`
**Purpose:** Disconnect from the robot
**No parameters required**

**Example:**
```
quit
```

**Response:**
```json
{
  "status": "OK",
  "msg": "Goodbye",
  "disconnect": true
}
```

## Response Format

All commands return JSON responses:

**Success Response:**
```json
{
  "status": "OK",
  "additional_fields": "..."
}
```

**Error Response:**
```json
{
  "status": "Error",
  "msg": "Error description"
}
```

## TCP Socket Connection

To connect to the robot, you'll need to establish a TCP socket connection:

```python
import socket
import json

# Connect to robot
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('192.168.0.155', 5000))

# Send command
sock.send(b'move 0 50\n')

# Read response
response = sock.recv(1024).decode('utf-8')
result = json.loads(response)

# Close connection when done
sock.close()
```

## Usage Guidelines for Claude

### When controlling the robot:

1. **Establish TCP connection** before sending commands
2. **Always check status first** before attempting control
3. **Use appropriate values** within the specified ranges
4. **Handle errors gracefully** and inform the user
5. **Stop movement** when tasks are complete
6. **Be mindful of timing** - allow animations to complete
7. **Close connection** when finished

### Common Movement Patterns:

**Forward movement:**
```
move 0 50
```

**Turn left while moving:**
```
move -30 30
```

**Stop:**
```
move 0 0
```

**Look around (head movement):**
```
servo head_rotation 75
```

**Multiple servo control (send multiple commands):**
```
servo head_rotation 60
servo neck_top 70
servo arm_left 80
servo arm_right 20
```

### Example Task Flow:

1. Connect to TCP socket
2. Check robot status
3. If connected, perform requested action
4. Provide feedback to user
5. Stop movement when complete
6. Disconnect from socket

### Safety Considerations:

- Always use the `stop` command if something goes wrong
- Don't send rapid successive commands (allow time for execution)
- Check Arduino connection status before sending commands
- Monitor battery level if available
- Close TCP connection when done

### Error Handling:

If you receive an error response:
1. Check the error message
2. Verify parameters are within valid ranges
3. Ensure Arduino is connected
4. Retry if appropriate or inform user of the issue

## Starting the TCP Server

### Auto-Start Service (Recommended)
The TCP server can be configured to start automatically on boot:

```bash
# Copy the service file to systemd
sudo cp walle-tcp.service /etc/systemd/system/

# Enable the service to start on boot
sudo systemctl enable walle-tcp.service

# Start the service now
sudo systemctl start walle-tcp.service
```

### Manual Start
If not using the service, you can start manually:

```bash
cd ~/walle-replica
python3 tcp_server.py
```

### Check if Server is Running
```bash
# Check service status
sudo systemctl status walle-tcp.service

# Or check if port is listening
netstat -an | grep :5000
```

The server will automatically connect to the Arduino and start listening for connections.

## Personality Integration

You can make the robot's movements match its personality:
- Use gentle, curious movements for exploration
- Combine head tilts with arm movements for expressiveness
- Use the inquisitive animation for showing interest
- Send multiple servo commands for coordinated behavior

Remember: This is a physical robot, so movements take time to execute. Be patient and allow actions to complete before sending new commands.