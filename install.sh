#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (with sudo)"
    exit 1
fi

echo "Installing plex-inhibit..."

# Copy the script to /usr/local/bin
echo "Installing script..."
cp plex_inhibit.sh /usr/local/bin/
chmod +x /usr/local/bin/plex_inhibit.sh

# Copy the service file
echo "Installing systemd service..."
cp plex_inhibit.service /etc/systemd/system/

# Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting service..."
systemctl enable plex_inhibit
systemctl start plex_inhibit

echo "Installation complete!"
echo "Check service status with: systemctl status plex_inhibit" 