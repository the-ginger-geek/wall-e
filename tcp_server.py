#!/usr/bin/env python3

#############################################
# Wall-e Robot TCP/IP Control Server
#
# @file       tcp_server.py
# @brief      TCP/IP server to control Wall-e robot
# @author     Claude (Anthropic)
# @copyright  Copyright (C) 2024 - Distributed under MIT license
# @version    1.0
# @date       2024
#############################################

import socket
import threading
import json
import logging
import sys
import os
import base64
import subprocess
from queue import Queue
from threading import Event, Thread
from serial import Serial
import serial.tools.list_ports
import time
from picamera2 import Picamera2
from picamera2.encoders import MJPEGEncoder
from picamera2.outputs import FileOutput
import io

# Import config
if os.path.isfile("web_interface/local_config.py"):
    sys.path.append("web_interface")
    from local_config import *
else:
    sys.path.append("web_interface")
    from config import *

# Set up logging
logger = logging.getLogger()
stream_handler = logging.StreamHandler(sys.stdout)
logger.setLevel(logging.INFO)
stream_handler.setLevel(logging.INFO)
logger.addHandler(stream_handler)


###############################################################
#
# Arduino Device Class (from web_interface/app.py)
#
###############################################################

class ArduinoDevice:
    """Class used for managing communication with the Arduino"""

    def __init__(self):
        """Constructor for Arduino serial communication thread class"""
        self.queue: Queue = Queue()
        self.exit_flag: Event = Event()
        self.port_name: str = ""
        self.serial_port: Serial | None = None
        self.serial_thread: Thread | None = None
        self.battery_level: str | None = None
        self.exit_flag.clear()

    def __del__(self):
        """Destructor - ensures serial port is closed correctly"""
        self.disconnect()

    def connect(self, port: str | int = "") -> bool:
        """
        Connect to the serial port
        :param port: The port to connect to (leave blank to use previous port)
        :return: True if connected successfully, False otherwise
        """
        try:
            usb_ports = [
                p.device for p in serial.tools.list_ports.comports()
            ]

            if type(port) is str and port == "":
                port = self.port_name

            if type(port) is int and port >= 0 and port < len(usb_ports):
                port = usb_ports[port]

            # Check port exists and we are not already connected
            if ((not self.is_connected() or port != self.port_name) and port in usb_ports):
                
               # Ensure old port is properly disconnected first
                self.disconnect() 

                # Connect to the new port
                self.serial_port = Serial(port, 115200)
                self.serial_port.flushInput()
                self.port_name = port

                # Start the command handler in a background thread
                self.exit_flag.clear()
                self.serial_thread = Thread(target = self.__communication_thread)
                self.serial_thread.start()

        except Exception as ex:
            logger.error(f'Serial connect error: {repr(ex)}')

        return self.is_connected()

    def disconnect(self) -> bool:
        """
        Disconnect from the serial port
        :return: True if disconnected successfully, False otherwise
        """
        try:
            self.battery_level = None

            if self.serial_thread is not None:
                self.exit_flag.set()
                self.serial_thread.join()
                self.serial_thread = None

            if self.serial_port is not None:
                self.serial_port.close()
                self.serial_port = None

        except Exception as ex:
            logger.error(f'Serial disconnect error: {repr(ex)}')

        return (self.serial_thread is None and self.serial_port is None)

    def is_connected(self) -> bool:
        """
        Check if serial device is connected
        :return: True if connected, False otherwise
        """
        return (self.serial_thread is not None and self.serial_thread.is_alive()
             and self.serial_port is not None and self.serial_port.is_open)

    def send_command(self, command: str) -> bool:
        """
        Send a serial command
        :param command: The command to be sent
        :return: True if port is open and message has been added to queue
        """
        success = False

        if self.is_connected():
            self.queue.put(command)
            success = True

        return success

    def clear_queue(self):
        """Clear the serial send queue"""
        while not self.queue.empty():
            self.queue.get()

    def get_battery_level(self) -> str | None:
        """
        Get the robot battery level
        :return: The battery level as a string, or None
        """
        return self.battery_level

    def __communication_thread(self):
        """Handle sending and receiving data with the serial device"""
        dataString: str = ""
        logger.info(f'Starting Arduino Thread ({self.port_name})')

        # Keep this thread running until the exit_flag changes
        while not self.exit_flag.is_set():
            try:
                # If there are any messages in the queue, send them
                if not self.queue.empty():
                    data = self.queue.get() + '\n'
                    self.serial_port.write(data.encode())

                # Read any incoming messages
                while (self.serial_port.in_waiting > 0):
                    data = self.serial_port.read()
                    if (data.decode() == '\n' or data.decode() == '\r'):
                        self.__parse_message(dataString)
                        dataString = ""
                    else:
                        dataString += data.decode()

            # If an error occurred in the serial communication
            except Exception as ex:
                logger.error(f'Serial handler error: {repr(ex)}')

            time.sleep(0.01)
        
        logger.info(f'Stopping Arduino Thread ({self.port_name})')

    def __parse_message(self, dataString: str):
        """
        Parse messages received from the connected device
        :param dataString: String containing the serial message to be parsed
        """
        try:
            # Battery level message
            if "Battery" in dataString:
                dataList = dataString.split('_')
                if len(dataList) > 1 and dataList[1].isdigit():
                    self.battery_level = dataList[1]

        except Exception as ex:
            logger.error(f'Error parsing message [{dataString}]: {repr(ex)}')


###############################################################
#
# Camera Streaming Class
#
###############################################################

class CameraStreamer:
    """Camera streaming for TCP server"""
    
    def __init__(self):
        self.picam2 = None
        self.streaming = False
        self.frame_buffer = None
        self.frame_lock = threading.Lock()
        
    def start_camera(self):
        """Start camera streaming"""
        try:
            if self.picam2 is None:
                self.picam2 = Picamera2()
                config = self.picam2.create_video_configuration(main={"size": (640, 480)})
                self.picam2.configure(config)
                self.picam2.start()
                self.streaming = True
                return True
        except Exception as ex:
            logger.error(f'Camera start error: {repr(ex)}')
            return False
        return self.streaming
        
    def stop_camera(self):
        """Stop camera streaming"""
        try:
            if self.picam2 is not None:
                self.picam2.stop()
                self.picam2.close()
                self.picam2 = None
            self.streaming = False
            return True
        except Exception as ex:
            logger.error(f'Camera stop error: {repr(ex)}')
            return False
            
    def get_frame(self):
        """Get current camera frame as base64 encoded JPEG"""
        if not self.streaming or self.picam2 is None:
            return None
            
        try:
            # Capture frame
            frame = self.picam2.capture_array()
            
            # Convert to JPEG
            import cv2
            _, jpeg = cv2.imencode('.jpg', frame)
            
            # Encode as base64
            frame_b64 = base64.b64encode(jpeg.tobytes()).decode('utf-8')
            return frame_b64
            
        except Exception as ex:
            logger.error(f'Frame capture error: {repr(ex)}')
            return None

###############################################################
#
# Audio Playback Class
#
###############################################################

class AudioPlayer:
    """Audio playback for TCP server"""
    
    def __init__(self):
        self.sound_folder = "/home/admin/walle-replica/web_interface/static/sounds/"
        
    def play_sound(self, sound_name):
        """Play a sound file"""
        try:
            # Find the sound file
            sound_file = None
            for file in os.listdir(self.sound_folder):
                if file.startswith(sound_name) or sound_name in file:
                    sound_file = os.path.join(self.sound_folder, file)
                    break
                    
            if sound_file and os.path.exists(sound_file):
                # Play using aplay
                subprocess.run(['aplay', sound_file], check=True)
                return True
            else:
                return False
                
        except Exception as ex:
            logger.error(f'Audio playback error: {repr(ex)}')
            return False
            
    def text_to_speech(self, text):
        """Convert text to speech and play"""
        try:
            # Use espeak for TTS
            subprocess.run(['espeak-ng', '-v', 'en', '-s', '150', text], check=True)
            return True
        except Exception as ex:
            logger.error(f'TTS error: {repr(ex)}')
            return False
            
    def get_sound_list(self):
        """Get list of available sounds"""
        try:
            sounds = []
            for file in os.listdir(self.sound_folder):
                if file.endswith('.wav') or file.endswith('.mp3'):
                    sounds.append(file)
            return sounds
        except Exception as ex:
            logger.error(f'Sound list error: {repr(ex)}')
            return []

###############################################################
#
# TCP/IP Protocol Handler Class
#
###############################################################

class WallETCPServer:
    """TCP/IP server for controlling Wall-E robot"""
    
    def __init__(self, host='0.0.0.0', port=5001):
        self.host = host
        self.port = port
        self.arduino = ArduinoDevice()
        self.camera = CameraStreamer()
        self.audio = AudioPlayer()
        self.running = False
        self.server_socket = None
        
        # Auto-connect to Arduino if configured
        self.auto_connect_arduino()
    
    def auto_connect_arduino(self):
        """Automatically connect to Arduino if configured"""
        try:
            usb_ports = [
                p.device for p in serial.tools.list_ports.comports()
            ]
            
            # Find preferred Arduino port
            selected_port = None
            for port in usb_ports:
                if ARDUINO_PORT in port:
                    selected_port = port
                    break
            
            # If preferred port not found, try any available port
            if not selected_port and usb_ports:
                selected_port = usb_ports[0]
                logger.info(f"Preferred Arduino port not found, trying {selected_port}")
            
            if selected_port and self.arduino.connect(selected_port):
                logger.info(f"Auto-connected to Arduino on {selected_port}")
            else:
                logger.warning("Failed to auto-connect to Arduino")
                
        except Exception as ex:
            logger.error(f'Auto-connect error: {repr(ex)}')
    
    def start(self):
        """Start the TCP server"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(5)
            self.running = True
            
            logger.info(f"Wall-E TCP Server started on {self.host}:{self.port}")
            logger.info("Available commands:")
            logger.info("  move <x> <y> - Move robot (x,y: -100 to 100)")
            logger.info("  servo <name> <value> - Control servo (value: 0-100)")
            logger.info("  animation <id> - Play animation")
            logger.info("  setting <name> <value> - Update setting")
            logger.info("  status - Get robot status")
            logger.info("  stop - Stop all movement")
            logger.info("  camera start - Start camera streaming")
            logger.info("  camera stop - Stop camera streaming")
            logger.info("  camera frame - Get current frame")
            logger.info("  audio play <sound> - Play sound file")
            logger.info("  audio speak <text> - Text to speech")
            logger.info("  audio list - List available sounds")
            logger.info("  quit - Disconnect client")
            
            while self.running:
                try:
                    client_socket, address = self.server_socket.accept()
                    logger.info(f"Client connected from {address}")
                    
                    # Handle client in a separate thread
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, address)
                    )
                    client_thread.start()
                    
                except socket.error as e:
                    if self.running:
                        logger.error(f"Socket error: {e}")
                    break
                    
        except Exception as ex:
            logger.error(f'Server start error: {repr(ex)}')
        finally:
            self.stop()
    
    def stop(self):
        """Stop the TCP server"""
        self.running = False
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        
        self.arduino.disconnect()
        logger.info("Wall-E TCP Server stopped")
    
    def handle_client(self, client_socket, address):
        """Handle individual client connections"""
        try:
            # Send welcome message
            welcome_msg = {
                "status": "OK",
                "message": "Connected to Wall-E TCP Control Server",
                "version": "1.1",
                "arduino_connected": self.arduino.is_connected(),
                "camera_available": True,
                "audio_available": True
            }
            self.send_response(client_socket, welcome_msg)
            
            while self.running:
                try:
                    # Receive data from client
                    data = client_socket.recv(1024).decode('utf-8').strip()
                    if not data:
                        break
                    
                    logger.debug(f"Received from {address}: {data}")
                    
                    # Parse and handle command
                    response = self.parse_command(data)
                    self.send_response(client_socket, response)
                    
                    # If client sent quit command, disconnect
                    if response.get('disconnect', False):
                        break
                        
                except socket.timeout:
                    continue
                except socket.error as e:
                    logger.error(f"Client {address} error: {e}")
                    break
                    
        except Exception as ex:
            logger.error(f'Client handler error: {repr(ex)}')
        finally:
            try:
                client_socket.close()
            except:
                pass
            logger.info(f"Client {address} disconnected")
    
    def send_response(self, client_socket, response):
        """Send JSON response to client"""
        try:
            json_response = json.dumps(response)
            client_socket.send(json_response.encode('utf-8'))
        except Exception as ex:
            logger.error(f'Send response error: {repr(ex)}')
    
    def parse_command(self, command_str):
        """Parse and execute client commands"""
        try:
            parts = command_str.split()
            if not parts:
                return {"status": "Error", "msg": "Empty command"}
            
            cmd = parts[0].lower()
            
            if cmd == "move":
                return self.handle_move(parts)
            elif cmd == "servo":
                return self.handle_servo(parts)
            elif cmd == "animation":
                return self.handle_animation(parts)
            elif cmd == "setting":
                return self.handle_setting(parts)
            elif cmd == "status":
                return self.handle_status()
            elif cmd == "stop":
                return self.handle_stop()
            elif cmd == "camera":
                return self.handle_camera(parts)
            elif cmd == "audio":
                return self.handle_audio(parts)
            elif cmd == "quit":
                return {"status": "OK", "msg": "Goodbye", "disconnect": True}
            else:
                return {"status": "Error", "msg": f"Unknown command: {cmd}"}
                
        except Exception as ex:
            return {"status": "Error", "msg": f"Command parse error: {str(ex)}"}
    
    def handle_move(self, parts):
        """Handle move command: move <x> <y>"""
        try:
            if len(parts) != 3:
                return {"status": "Error", "msg": "Usage: move <x> <y>"}
            
            x = int(parts[1])
            y = int(parts[2])
            
            if not (-100 <= x <= 100) or not (-100 <= y <= 100):
                return {"status": "Error", "msg": "Values must be between -100 and 100"}
            
            if self.arduino.is_connected():
                self.arduino.send_command(f"X{x}")
                self.arduino.send_command(f"Y{y}")
                return {"status": "OK", "x": x, "y": y}
            else:
                return {"status": "Error", "msg": "Arduino not connected"}
                
        except ValueError:
            return {"status": "Error", "msg": "Invalid numeric values"}
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_servo(self, parts):
        """Handle servo command: servo <name> <value>"""
        try:
            if len(parts) != 3:
                return {"status": "Error", "msg": "Usage: servo <name> <value>"}
            
            servo_name = parts[1]
            value = int(parts[2])
            
            if not (0 <= value <= 100):
                return {"status": "Error", "msg": "Value must be between 0 and 100"}
            
            # Map servo names to command characters
            servo_map = {
                'head_rotation': 'G',
                'neck_top': 'T', 
                'neck_bottom': 'B',
                'arm_left': 'L',
                'arm_right': 'R',
                'eye_left': 'E',
                'eye_right': 'U'
            }
            
            if servo_name not in servo_map:
                valid_servos = ', '.join(servo_map.keys())
                return {"status": "Error", "msg": f"Invalid servo. Valid servos: {valid_servos}"}
            
            if self.arduino.is_connected():
                self.arduino.send_command(f"{servo_map[servo_name]}{value}")
                return {"status": "OK", "servo": servo_name, "value": value}
            else:
                return {"status": "Error", "msg": "Arduino not connected"}
                
        except ValueError:
            return {"status": "Error", "msg": "Invalid numeric value"}
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_animation(self, parts):
        """Handle animation command: animation <id>"""
        try:
            if len(parts) != 2:
                return {"status": "Error", "msg": "Usage: animation <id>"}
            
            animation_id = int(parts[1])
            
            if animation_id < 0:
                return {"status": "Error", "msg": "Animation ID must be non-negative"}
            
            if self.arduino.is_connected():
                self.arduino.send_command(f"A{animation_id}")
                return {"status": "OK", "animation": animation_id}
            else:
                return {"status": "Error", "msg": "Arduino not connected"}
                
        except ValueError:
            return {"status": "Error", "msg": "Invalid animation ID"}
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_setting(self, parts):
        """Handle setting command: setting <name> <value>"""
        try:
            if len(parts) != 3:
                return {"status": "Error", "msg": "Usage: setting <name> <value>"}
            
            setting_name = parts[1]
            value = int(parts[2])
            
            if not self.arduino.is_connected():
                return {"status": "Error", "msg": "Arduino not connected"}
            
            if setting_name == 'steering_offset':
                if not (-100 <= value <= 100):
                    return {"status": "Error", "msg": "steering_offset must be between -100 and 100"}
                self.arduino.send_command(f"S{value}")
                
            elif setting_name == 'motor_deadzone':
                if not (0 <= value <= 250):
                    return {"status": "Error", "msg": "motor_deadzone must be between 0 and 250"}
                self.arduino.send_command(f"O{value}")
                
            elif setting_name == 'auto_mode':
                if value not in [0, 1]:
                    return {"status": "Error", "msg": "auto_mode must be 0 or 1"}
                self.arduino.send_command(f"M{value}")
                
            else:
                return {"status": "Error", "msg": "Invalid setting. Valid settings: steering_offset, motor_deadzone, auto_mode"}
            
            return {"status": "OK", "setting": setting_name, "value": value}
                
        except ValueError:
            return {"status": "Error", "msg": "Invalid numeric value"}
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_status(self):
        """Handle status command"""
        try:
            status = {
                'arduino_connected': self.arduino.is_connected(),
                'battery_level': self.arduino.get_battery_level(),
                'server_running': self.running
            }
            return {"status": "OK", "robot_status": status}
            
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_stop(self):
        """Handle stop command"""
        try:
            if self.arduino.is_connected():
                self.arduino.send_command("X0")
                self.arduino.send_command("Y0")
                return {"status": "OK", "msg": "Robot stopped"}
            else:
                return {"status": "Error", "msg": "Arduino not connected"}
                
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_camera(self, parts):
        """Handle camera commands"""
        try:
            if len(parts) < 2:
                return {"status": "Error", "msg": "Usage: camera <start|stop|frame>"}
            
            subcmd = parts[1].lower()
            
            if subcmd == "start":
                if self.camera.start_camera():
                    return {"status": "OK", "msg": "Camera started"}
                else:
                    return {"status": "Error", "msg": "Failed to start camera"}
                    
            elif subcmd == "stop":
                if self.camera.stop_camera():
                    return {"status": "OK", "msg": "Camera stopped"}
                else:
                    return {"status": "Error", "msg": "Failed to stop camera"}
                    
            elif subcmd == "frame":
                frame_data = self.camera.get_frame()
                if frame_data:
                    return {"status": "OK", "frame": frame_data, "format": "jpeg_base64"}
                else:
                    return {"status": "Error", "msg": "No frame available"}
                    
            else:
                return {"status": "Error", "msg": "Invalid camera command"}
                
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}
    
    def handle_audio(self, parts):
        """Handle audio commands"""
        try:
            if len(parts) < 2:
                return {"status": "Error", "msg": "Usage: audio <play|speak|list> [args]"}
            
            subcmd = parts[1].lower()
            
            if subcmd == "play":
                if len(parts) < 3:
                    return {"status": "Error", "msg": "Usage: audio play <sound_name>"}
                    
                sound_name = parts[2]
                if self.audio.play_sound(sound_name):
                    return {"status": "OK", "msg": f"Playing sound: {sound_name}"}
                else:
                    return {"status": "Error", "msg": f"Sound not found: {sound_name}"}
                    
            elif subcmd == "speak":
                if len(parts) < 3:
                    return {"status": "Error", "msg": "Usage: audio speak <text>"}
                    
                text = " ".join(parts[2:])
                if self.audio.text_to_speech(text):
                    return {"status": "OK", "msg": f"Speaking: {text}"}
                else:
                    return {"status": "Error", "msg": "TTS failed"}
                    
            elif subcmd == "list":
                sounds = self.audio.get_sound_list()
                return {"status": "OK", "sounds": sounds}
                
            else:
                return {"status": "Error", "msg": "Invalid audio command"}
                
        except Exception as ex:
            return {"status": "Error", "msg": str(ex)}


###############################################################
#
# Main Program
#
###############################################################

def main():
    """Main program entry point"""
    try:
        # Use different port from web interface (5000)
        server = WallETCPServer(host='0.0.0.0', port=5001)
        server.start()
        
    except KeyboardInterrupt:
        logger.info("Received interrupt signal")
    except Exception as ex:
        logger.error(f'Main error: {repr(ex)}')
    finally:
        logger.info("Shutting down...")


if __name__ == '__main__':
    main()