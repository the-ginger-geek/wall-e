#!/bin/bash

# Script to recompile and update the Wall-E TCP service
set -e

echo "=== Wall-E TCP Service Update Script ==="

# Navigate to the TCP server directory
cd /home/admin/wall-e/wall-e_tcp_server

echo "1. Stopping current service..."
sudo systemctl stop walle-tcp.service

echo "2. Compiling Dart TCP server..."
dart compile exe bin/wall_e_tcp_server.dart -o wall_e_tcp_server

echo "3. Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "4. Starting updated service..."
sudo systemctl start walle-tcp.service

echo "5. Checking service status..."
sudo systemctl status walle-tcp.service --no-pager

echo "=== Update complete! ==="
