# WALL-E Robot Control Protocol

This document describes the TCP/IP protocol for controlling the WALL-E robot programmatically.

## Connection Details
```
Host: 192.168.0.155 (or your robot's IP)
Port: 5000
Protocol: TCP/IP
```

## Protocol Overview

The Wall-E robot uses a simple text-based TCP/IP protocol. Commands are sent as plain text strings, and responses are returned as JSON objects.

### Connection Flow
1. Connect to the robot via TCP socket
2. Receive welcome message as JSON
3. Send commands as text strings
4. Receive responses as JSON objects
5. Send `quit` command to disconnect

## Available Commands

### 1. Movement Control

#### `move <x> <y>`
Controls the robot's movement motors.

**Parameters:**
- `x`: Turn value (-100 to 100, negative = left, positive = right)
- `y`: Move value (-100 to 100, negative = backward, positive = forward)

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

### 2. Servo Control

#### `servo <name> <value>`
Controls individual servo motors.

**Parameters:**
- `name`: Servo name (see valid servos below)
- `value`: Position (0-100)

**Valid Servos:**
- `head_rotation` - Head rotation (left/right)
- `neck_top` - Upper neck tilt
- `neck_bottom` - Lower neck tilt
- `arm_left` - Left arm position
- `arm_right` - Right arm position
- `eye_left` - Left eye position
- `eye_right` - Right eye position

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

### 3. Animation Control

#### `animation <id>`
Plays predefined animation sequences.

**Parameters:**
- `id`: Animation number (0-based)

**Available Animations:**
- `0` - Reset Servo Positions
- `1` - Bootup Sequence
- `2` - Inquisitive Sequence

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

### 4. Settings Control

#### `setting <name> <value>`
Updates robot settings.

**Parameters:**
- `name`: Setting name
- `value`: Setting value

**Valid Settings:**
- `steering_offset` - Steering calibration offset (-100 to 100)
- `motor_deadzone` - Motor deadzone threshold (0 to 250)
- `auto_mode` - Automatic servo mode (0 = manual, 1 = automatic)

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

### 5. Status Information

#### `status`
Gets current robot status.

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

### 6. Emergency Stop

#### `stop`
Immediately stops all robot movement.

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

### 7. Disconnect

#### `quit`
Disconnects from the server.

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

## Error Responses

All commands return error responses in the following format:

```json
{
  "status": "Error",
  "msg": "Error description"
}
```

**Common Error Messages:**
- `"Arduino not connected"` - Robot hardware not available
- `"Invalid command"` - Unknown command sent
- `"Invalid numeric value"` - Non-numeric parameter provided
- `"Values must be between X and Y"` - Parameter out of range

## Example Python Client

```python
import socket
import json

class WallETCPClient:
    def __init__(self, host='192.168.0.155', port=5000):
        self.host = host
        self.port = port
        self.socket = None
        self.connected = False
    
    def connect(self):
        """Connect to the Wall-E robot"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            self.connected = True
            
            # Read welcome message
            welcome = self.receive_response()
            print(f"Connected: {welcome}")
            return True
            
        except Exception as e:
            print(f"Connection failed: {e}")
            return False
    
    def disconnect(self):
        """Disconnect from the robot"""
        if self.connected:
            self.send_command("quit")
            self.socket.close()
            self.connected = False
    
    def send_command(self, command):
        """Send a command and return the response"""
        if not self.connected:
            return {"status": "Error", "msg": "Not connected"}
        
        try:
            # Send command
            self.socket.send((command + '\n').encode('utf-8'))
            
            # Get response
            response = self.receive_response()
            return response
            
        except Exception as e:
            return {"status": "Error", "msg": str(e)}
    
    def receive_response(self):
        """Receive and parse JSON response"""
        try:
            data = self.socket.recv(1024).decode('utf-8').strip()
            return json.loads(data)
        except Exception as e:
            return {"status": "Error", "msg": f"Parse error: {str(e)}"}
    
    def move(self, x, y):
        """Move the robot"""
        return self.send_command(f"move {x} {y}")
    
    def control_servo(self, servo, value):
        """Control a servo"""
        return self.send_command(f"servo {servo} {value}")
    
    def play_animation(self, animation_id):
        """Play an animation"""
        return self.send_command(f"animation {animation_id}")
    
    def update_setting(self, setting, value):
        """Update a setting"""
        return self.send_command(f"setting {setting} {value}")
    
    def get_status(self):
        """Get robot status"""
        return self.send_command("status")
    
    def stop(self):
        """Emergency stop"""
        return self.send_command("stop")

# Usage example
if __name__ == "__main__":
    robot = WallETCPClient()
    
    if robot.connect():
        # Check status
        status = robot.get_status()
        print(f"Status: {status}")
        
        # Move forward
        result = robot.move(0, 50)
        print(f"Move result: {result}")
        
        # Control head
        result = robot.control_servo("head_rotation", 75)
        print(f"Servo result: {result}")
        
        # Play animation
        result = robot.play_animation(1)
        print(f"Animation result: {result}")
        
        # Stop
        result = robot.stop()
        print(f"Stop result: {result}")
        
        # Disconnect
        robot.disconnect()
```

## Running the TCP Server

### Manual Start
```bash
cd ~/walle-replica
python3 tcp_server.py
```

### Auto-Start on Boot (Recommended)
To have the TCP server start automatically when the Pi boots:

```bash
# Copy the service file to systemd
sudo cp walle-tcp.service /etc/systemd/system/

# Enable the service to start on boot
sudo systemctl enable walle-tcp.service

# Start the service now
sudo systemctl start walle-tcp.service

# Check service status
sudo systemctl status walle-tcp.service
```

### Service Management Commands
```bash
# Stop the service
sudo systemctl stop walle-tcp.service

# Restart the service
sudo systemctl restart walle-tcp.service

# View logs
sudo journalctl -u walle-tcp.service -f

# Disable auto-start
sudo systemctl disable walle-tcp.service
```

The server will:
1. Start listening on port 5000
2. Automatically attempt to connect to the Arduino
3. Display available commands in the console
4. Accept multiple concurrent client connections
5. Restart automatically if it crashes

### Testing with Telnet
You can test the protocol using telnet:

```bash
telnet 192.168.0.155 5000
```

Then send commands like:
```
move 0 50
servo head_rotation 75
animation 1
status
stop
quit
```

## Security Notes

The TCP protocol currently has minimal security:

1. **No authentication** - Anyone who can connect to the port can control the robot
2. **No encryption** - Commands are sent in plain text
3. **No rate limiting** - Clients can send commands as fast as they want

For production use, consider:
1. Adding authentication mechanisms
2. Implementing command rate limiting
3. Adding connection limits
4. Using SSL/TLS for encryption
5. Adding command logging

## Serial Command Reference

For understanding the underlying communication, here are the Arduino serial commands:

- `X{value}` - Turn control (-100 to 100)
- `Y{value}` - Move control (-100 to 100)
- `G{value}` - Head rotation (0-100)
- `T{value}` - Neck top (0-100)
- `B{value}` - Neck bottom (0-100)
- `L{value}` - Left arm (0-100)
- `R{value}` - Right arm (0-100)
- `E{value}` - Left eye (0-100)
- `U{value}` - Right eye (0-100)
- `A{value}` - Animation number
- `S{value}` - Steering offset (-100 to 100)
- `O{value}` - Motor deadzone (0 to 250)
- `M{value}` - Auto mode (0 or 1)