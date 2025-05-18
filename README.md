# Plex Inhibit

A systemd service that prevents system idle/sleep when Plex Media Server is actively streaming content.

## Overview

Plex Inhibit monitors network traffic (simplisticly)  on Plex's default port (32400) and uses `systemd-inhibit` to prevent the system from going into idle/sleep mode when activity is detected. 

Yes most people just keep servers on all the time so this
will have a limited audience. 

## Features

- Monitors Plex network traffic on port 32400 using netstat
- Prevents system sleep when activit is detected
- Releases system sleep prevention when activity stops.
- Runs as a systemd service

## Installation

### Install Script

Run the install script with sudo:
```bash
sudo ./install.sh
```

The script will:
- Install and configure the systemd service
- Start the service automatically

### Manual Installation

If you prefer to install manually, follow these steps:

1. Copy the service files to their respective locations:
   ```bash
   sudo cp plex_inhibit.sh /usr/local/bin/
   sudo cp plex_inhibit.service /etc/systemd/system/
   ```

2. Make the script executable:
   ```bash
   sudo chmod +x /usr/local/bin/plex_inhibit.sh
   ```

3. Reload systemd daemon:
   ```bash
   sudo systemctl daemon-reload
   ```

4. Enable and start the service:
   ```bash
   sudo systemctl enable plex_inhibit
   sudo systemctl start plex_inhibit
   ```

## Configuration

The script checks for Plex traffic every 30 seconds by default. You can modify this interval by changing the `CHECK_INTERVAL` variable in the script.

## Dependencies

- systemd
- netstat (net-tools)
- Plex Media Server

## Service Status

You can check the status of the service using:
```bash
sudo systemctl status plex_inhibit
```

View the logs using:
```bash
journalctl -u plex_inhibit
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
