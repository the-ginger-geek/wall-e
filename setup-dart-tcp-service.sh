#!/bin/bash

# Setup script for Wall-E Dart TCP Server Service
# This script transitions from the Python TCP server to the Dart TCP server

set -e

echo "Setting up Wall-E Dart TCP Server Service..."

# Configuration
SERVICE_NAME="walle-tcp"
SERVICE_FILE="walle-tcp.service"
TARGET_DIR="/home/admin/walle-replica"
DART_SERVER_DIR="$TARGET_DIR/wall-e_tcp_server"
DART_EXECUTABLE="wall_e_tcp_server"

# Check if we're running as root or with sudo
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user with sudo privileges, not as root"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
echo "Checking dependencies..."

if ! command_exists dart; then
    echo "Error: Dart is not installed. Please install Dart SDK first."
    echo "Visit: https://dart.dev/get-dart"
    exit 1
fi

if ! command_exists systemctl; then
    echo "Error: systemctl not found. This script requires systemd."
    exit 1
fi

# Stop existing service if running
echo "Stopping existing TCP service..."
sudo systemctl stop $SERVICE_NAME 2>/dev/null || echo "Service was not running"

# Disable existing service
echo "Disabling existing TCP service..."
sudo systemctl disable $SERVICE_NAME 2>/dev/null || echo "Service was not enabled"

# Create target directory if it doesn't exist
echo "Creating target directory..."
sudo mkdir -p "$DART_SERVER_DIR"

# Copy Dart server files
echo "Copying Dart TCP server files..."
sudo cp -r wall-e_tcp_server/* "$DART_SERVER_DIR/"

# Compile Dart server if executable doesn't exist
if [ ! -f "$DART_SERVER_DIR/$DART_EXECUTABLE" ]; then
    echo "Compiling Dart TCP server..."
    cd "$DART_SERVER_DIR"
    sudo -u admin dart compile exe bin/wall_e_tcp_server.dart -o "$DART_EXECUTABLE"
    cd - >/dev/null
fi

# Make executable
sudo chmod +x "$DART_SERVER_DIR/$DART_EXECUTABLE"

# Set ownership
sudo chown -R admin:admin "$DART_SERVER_DIR"

# Copy service file
echo "Installing systemd service..."
sudo cp "$SERVICE_FILE" /etc/systemd/system/

# Reload systemd
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable service
echo "Enabling Dart TCP service..."
sudo systemctl enable $SERVICE_NAME

# Start service
echo "Starting Dart TCP service..."
sudo systemctl start $SERVICE_NAME

# Check status
echo ""
echo "Service status:"
sudo systemctl status $SERVICE_NAME --no-pager -l

echo ""
echo "Setup complete!"
echo ""
echo "Useful commands:"
echo "  Check status:    sudo systemctl status $SERVICE_NAME"
echo "  Stop service:    sudo systemctl stop $SERVICE_NAME"
echo "  Start service:   sudo systemctl start $SERVICE_NAME"
echo "  Restart service: sudo systemctl restart $SERVICE_NAME"
echo "  View logs:       sudo journalctl -u $SERVICE_NAME -f"
echo ""
echo "The Dart TCP server should now be running on port 5001"
echo "You can test it by connecting with the Flutter app or using:"
echo "  telnet localhost 5001"