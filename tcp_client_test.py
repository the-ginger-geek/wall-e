#!/usr/bin/env python3

#############################################
# Wall-e Robot TCP/IP Client Test Program
#
# @file       tcp_client_test.py
# @brief      Test client for Wall-e TCP/IP control server
# @author     Claude (Anthropic)
# @copyright  Copyright (C) 2024 - Distributed under MIT license
# @version    1.0
# @date       2024
#############################################

import socket
import json
import time
import sys
import threading
from typing import Dict, Any, Optional

class WallETCPClient:
    """TCP/IP client for testing Wall-E robot server"""
    
    def __init__(self, host='localhost', port=5001):
        self.host = host
        self.port = port
        self.socket = None
        self.connected = False
        
    def connect(self) -> bool:
        """Connect to the Wall-E server"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            self.connected = True
            
            # Receive welcome message
            welcome = self.receive_response()
            if welcome:
                print(f"Connected: {welcome.get('message', 'Unknown')}")
                print(f"Arduino Connected: {welcome.get('arduino_connected', False)}")
                return True
            return False
            
        except Exception as e:
            print(f"Connection error: {e}")
            return False
    
    def disconnect(self):
        """Disconnect from the server"""
        if self.connected and self.socket:
            try:
                self.send_command("quit")
                self.socket.close()
            except:
                pass
            self.connected = False
    
    def send_command(self, command: str) -> Optional[Dict[str, Any]]:
        """Send a command to the server and return response"""
        if not self.connected:
            print("Not connected to server")
            return None
            
        try:
            # Send command
            self.socket.send((command + '\n').encode('utf-8'))
            
            # Receive response
            response = self.receive_response()
            return response
            
        except Exception as e:
            print(f"Send command error: {e}")
            return None
    
    def receive_response(self) -> Optional[Dict[str, Any]]:
        """Receive and parse JSON response from server"""
        try:
            data = self.socket.recv(1024).decode('utf-8').strip()
            if data:
                return json.loads(data)
            return None
        except Exception as e:
            print(f"Receive response error: {e}")
            return None

def print_response(response: Dict[str, Any]):
    """Pretty print server response"""
    if response:
        status = response.get('status', 'Unknown')
        msg = response.get('msg', response.get('message', ''))
        
        print(f"Status: {status}")
        if msg:
            print(f"Message: {msg}")
        
        # Print additional data
        for key, value in response.items():
            if key not in ['status', 'msg', 'message', 'disconnect']:
                print(f"{key}: {value}")
        print()

def run_interactive_mode(client: WallETCPClient):
    """Run interactive command mode"""
    print("\n=== Wall-E TCP Client Interactive Mode ===")
    print("Available commands:")
    print("  move <x> <y>           - Move robot (x,y: -100 to 100)")
    print("  servo <name> <value>   - Control servo (value: 0-100)")
    print("  animation <id>         - Play animation")
    print("  setting <name> <value> - Update setting")
    print("  status                 - Get robot status")
    print("  stop                   - Stop all movement")
    print("  quit                   - Disconnect")
    print("  exit                   - Exit program")
    print()
    
    while True:
        try:
            command = input("wall-e> ").strip()
            if not command:
                continue
                
            if command.lower() == 'exit':
                break
                
            response = client.send_command(command)
            print_response(response)
            
            if response and response.get('disconnect'):
                break
                
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except EOFError:
            break

def run_automated_tests(client: WallETCPClient):
    """Run automated test suite"""
    print("\n=== Running Automated Tests ===")
    
    tests = [
        # Status tests
        ("status", "Get robot status"),
        
        # Movement tests
        ("move 50 0", "Move forward"),
        ("move -50 0", "Move backward"),
        ("move 0 50", "Turn right"),
        ("move 0 -50", "Turn left"),
        ("move 100 100", "Maximum values"),
        ("move -100 -100", "Minimum values"),
        ("stop", "Stop movement"),
        
        # Servo tests
        ("servo head_rotation 50", "Center head rotation"),
        ("servo neck_top 25", "Neck top position"),
        ("servo neck_bottom 75", "Neck bottom position"),
        ("servo arm_left 0", "Left arm down"),
        ("servo arm_right 100", "Right arm up"),
        ("servo eye_left 50", "Left eye center"),
        ("servo eye_right 50", "Right eye center"),
        
        # Animation tests
        ("animation 1", "Play animation 1"),
        ("animation 0", "Play animation 0"),
        
        # Setting tests
        ("setting steering_offset 0", "Reset steering offset"),
        ("setting motor_deadzone 10", "Set motor deadzone"),
        ("setting auto_mode 0", "Disable auto mode"),
        
        # Error tests
        ("move 150 50", "Invalid move values (should fail)"),
        ("servo invalid_servo 50", "Invalid servo name (should fail)"),
        ("animation -1", "Invalid animation ID (should fail)"),
        ("unknown_command", "Unknown command (should fail)"),
        ("", "Empty command (should fail)"),
        
        # Final status
        ("status", "Final status check"),
    ]
    
    passed = 0
    failed = 0
    
    for i, (command, description) in enumerate(tests, 1):
        print(f"\nTest {i}: {description}")
        print(f"Command: {command}")
        
        response = client.send_command(command)
        if response:
            print_response(response)
            if response.get('status') == 'OK':
                print("✓ PASSED")
                passed += 1
            else:
                print("✗ FAILED (expected for error tests)")
                if "should fail" in description:
                    passed += 1
                else:
                    failed += 1
        else:
            print("✗ FAILED - No response")
            failed += 1
        
        # Small delay between tests
        time.sleep(0.5)
    
    print(f"\n=== Test Results ===")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Total: {passed + failed}")

def main():
    """Main program entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 tcp_client_test.py [host] [port] [mode]")
        print("  host: Server hostname (default: localhost)")
        print("  port: Server port (default: 5001)")
        print("  mode: 'interactive' or 'test' (default: interactive)")
        print()
        print("Examples:")
        print("  python3 tcp_client_test.py")
        print("  python3 tcp_client_test.py localhost 5001 interactive")
        print("  python3 tcp_client_test.py 192.168.1.100 5001 test")
        return
    
    # Parse command line arguments
    host = sys.argv[1] if len(sys.argv) > 1 else 'localhost'
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 5001
    mode = sys.argv[3] if len(sys.argv) > 3 else 'interactive'
    
    print(f"Wall-E TCP Client Test Program")
    print(f"Connecting to {host}:{port}")
    
    client = WallETCPClient(host, port)
    
    try:
        if client.connect():
            if mode.lower() == 'test':
                run_automated_tests(client)
            else:
                run_interactive_mode(client)
        else:
            print("Failed to connect to server")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\nReceived interrupt signal")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client.disconnect()
        print("Disconnected from server")

if __name__ == '__main__':
    main()