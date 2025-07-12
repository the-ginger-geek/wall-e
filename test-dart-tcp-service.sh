#!/bin/bash

# Test script for Wall-E Dart TCP Server Service
# This script validates the service configuration and tests connectivity

set -e

echo "Testing Wall-E Dart TCP Server Service..."

SERVICE_NAME="walle-tcp"
TARGET_DIR="/home/admin/walle-replica"
DART_SERVER_DIR="$TARGET_DIR/wall-e_tcp_server"
DART_EXECUTABLE="wall_e_tcp_server"
TCP_PORT=5001

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
    fi
}

# Test 1: Check if Dart executable exists and is executable
echo "1. Checking Dart TCP server executable..."
if [ -f "$DART_SERVER_DIR/$DART_EXECUTABLE" ] && [ -x "$DART_SERVER_DIR/$DART_EXECUTABLE" ]; then
    print_status "OK" "Dart executable found and is executable"
else
    print_status "FAIL" "Dart executable not found or not executable at $DART_SERVER_DIR/$DART_EXECUTABLE"
    exit 1
fi

# Test 2: Check service file exists
echo "2. Checking systemd service file..."
if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
    print_status "OK" "Service file exists"
else
    print_status "FAIL" "Service file not found at /etc/systemd/system/$SERVICE_NAME.service"
    exit 1
fi

# Test 3: Check service status
echo "3. Checking service status..."
if systemctl is-active --quiet $SERVICE_NAME; then
    print_status "OK" "Service is running"
    SERVICE_RUNNING=true
else
    print_status "WARN" "Service is not running"
    SERVICE_RUNNING=false
fi

# Test 4: Check if service is enabled
echo "4. Checking if service is enabled..."
if systemctl is-enabled --quiet $SERVICE_NAME; then
    print_status "OK" "Service is enabled (will start on boot)"
else
    print_status "WARN" "Service is not enabled"
fi

# Test 5: Check port availability
echo "5. Checking TCP port $TCP_PORT..."
if netstat -tlnp 2>/dev/null | grep -q ":$TCP_PORT "; then
    print_status "OK" "Port $TCP_PORT is open and listening"
    PORT_OPEN=true
else
    print_status "WARN" "Port $TCP_PORT is not listening"
    PORT_OPEN=false
fi

# Test 6: Test TCP connectivity (if service is running)
if [ "$SERVICE_RUNNING" = true ] && [ "$PORT_OPEN" = true ]; then
    echo "6. Testing TCP connectivity..."
    
    # Test JSON request
    TEST_REQUEST='{"type":"stop"}'
    
    # Use timeout and nc to test connection
    if command -v nc >/dev/null 2>&1; then
        RESPONSE=$(echo "$TEST_REQUEST" | timeout 5 nc localhost $TCP_PORT 2>/dev/null || echo "")
        if [ -n "$RESPONSE" ]; then
            print_status "OK" "TCP server responds to requests"
            echo "   Response: $RESPONSE"
        else
            print_status "WARN" "TCP server not responding or connection timeout"
        fi
    else
        print_status "WARN" "nc (netcat) not available, skipping connectivity test"
    fi
else
    echo "6. Skipping TCP connectivity test (service not running or port not open)"
fi

# Test 7: Check logs for errors
echo "7. Checking recent service logs..."
if journalctl -u $SERVICE_NAME --since "1 minute ago" --no-pager -q 2>/dev/null | grep -i error >/dev/null; then
    print_status "WARN" "Found errors in recent logs"
    echo "   Recent errors:"
    journalctl -u $SERVICE_NAME --since "1 minute ago" --no-pager -q | grep -i error | tail -3
else
    print_status "OK" "No recent errors in logs"
fi

echo ""
echo "Summary:"
echo "========="

if [ "$SERVICE_RUNNING" = true ] && [ "$PORT_OPEN" = true ]; then
    print_status "OK" "Dart TCP Server is running and ready to accept connections"
    echo ""
    echo "You can now:"
    echo "  • Connect with the Flutter app"
    echo "  • Test with: telnet localhost $TCP_PORT"
    echo "  • Send JSON commands like: {\"type\":\"stop\"}"
else
    print_status "WARN" "Service setup may need attention"
    echo ""
    echo "Troubleshooting steps:"
    echo "  • Check logs: sudo journalctl -u $SERVICE_NAME -f"
    echo "  • Restart service: sudo systemctl restart $SERVICE_NAME"
    echo "  • Check service status: sudo systemctl status $SERVICE_NAME"
fi

echo ""
echo "Service management commands:"
echo "  • View status: sudo systemctl status $SERVICE_NAME"
echo "  • View logs: sudo journalctl -u $SERVICE_NAME -f"
echo "  • Restart: sudo systemctl restart $SERVICE_NAME"