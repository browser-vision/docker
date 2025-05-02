# browser.vision - Docker

A containerized environment for running [Vision](https://browser.vision/) antidetect browser with VNC remote desktop access. 
This setup provides a complete Ubuntu desktop environment (XFCE4) accessible through your web browser via noVNC.

## Overview

This project packages Vision in a Docker container with:
- **Ubuntu 24.10** base image
- **XFCE4** desktop environment
- **VNC server** (TightVNC) for remote desktop access
- **noVNC** web interface for browser-based VNC access
- **Chromium** browser pre-installed to ensure that required browser packages are installed
- **Vision** automation tool

## Features

- 🖥️ **Browser-based access**: Connect to the desktop environment directly from your web browser
- 🔒 **Sandboxed environment**: Runs as non-root user (`sandbox`) for security
- 🚀 **Easy deployment**: Simple Docker Compose setup
- 🔄 **Auto-restart**: Container automatically restarts unless explicitly stopped
- 📦 **Pre-configured**: All dependencies and tools ready to use

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 1.29 or higher)
- At least 4GB of available RAM
- Modern web browser (Chrome, Firefox, Safari, or Edge)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd vision-docker
```

### 2. Build and Run

```bash
docker-compose up -d
```

This will:
- Build the Docker image (first time only, may take 5-10 minutes)
- Start the container in detached mode
- Expose ports 6080 (noVNC) and 3030 (Vision HTTP server)

### 3. Access the Desktop

Open your web browser and navigate to:

```
http://localhost:6080
```

**VNC Password**: `password`

### 4. Access Vision API

Vision API server is available at:

```
http://localhost:3030
```

## Usage

### Starting the Container

```bash
docker-compose up -d
```

### Stopping the Container

```bash
docker-compose down
```

### Viewing Logs

```bash
docker-compose logs -f
```

### Rebuilding the Image

If you make changes to the Dockerfile:

```bash
docker-compose up -d --build
```

### Accessing the Container Shell

```bash
docker-compose exec vision bash
```

## Architecture

### Dockerfile

The `Dockerfile` creates a multi-layered Ubuntu environment:

1. **Base System**: Ubuntu 24.10 with locale and core utilities
2. **Desktop Environment**: XFCE4 with X.org server
3. **VNC Stack**: TightVNC server + noVNC + websockify
4. **Browser**: Chromium with dependencies
5. **Vision**: Latest version from official source
6. **User Setup**: Non-root `sandbox` user with sudo privileges

### Entrypoint Script

The `entrypoint.sh` script handles container initialization:

1. Sets up environment variables
2. Starts D-Bus daemon
3. Configures VNC server with XFCE4 session
4. Launches noVNC web interface
5. Starts Vision API server
6. Maintains container with log tailing

### Docker Compose

The `docker-compose.yml` provides:

- **Shared memory**: 4GB allocated for browser operations
- **Port mapping**: 6080 (noVNC) and 3030 (Vision)
- **Restart policy**: Automatic restart unless stopped

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 6080 | noVNC | Web-based VNC client interface |
| 3030 | Vision | Vision API server |
| 5901 | VNC | VNC server (internal, not exposed) |

## Configuration

### Changing VNC Password

Edit `entrypoint.sh` line 46:

```bash
echo "your-new-password" | vncpasswd -f > $HOME/.vnc/passwd
```

### Changing Screen Resolution

Edit `entrypoint.sh` line 54:

```bash
vncserver :1 -geometry 1920x1080 -depth 24 -rfbport 5901
```

### Changing User Credentials

Edit `Dockerfile` line 52:

```bash
echo "sandbox:your-new-password" | chpasswd && \
```

## Troubleshooting

### Container won't start

Check logs:
```bash
docker-compose logs
```

### Can't connect to noVNC

1. Verify container is running: `docker-compose ps`
2. Check port isn't already in use: `lsof -i :6080`
3. Try accessing via container IP directly

### Black screen in VNC

1. Check VNC logs: `docker-compose exec vision cat ~/.vnc/*.log`
2. Restart the container: `docker-compose restart`

### Vision not starting

1. Check if Vision process is running: `docker-compose exec vision ps aux | grep Vision`
2. Verify Vision installation: `docker-compose exec vision which Vision`
3. Check Vision logs in container output

### Performance issues

- Increase shared memory in `docker-compose.yml` (currently 4GB)
- Allocate more CPU/RAM to Docker
- Reduce VNC screen resolution

## Security Notes

⚠️ **Important Security Considerations**:

1. **Default passwords**: Change the default VNC password (`password`) and user password before deploying in production
2. **Network exposure**: By default, ports are exposed on all interfaces (`0.0.0.0`). Consider restricting to localhost or using a reverse proxy
3. **Sudo access**: The `sandbox` user has sudo privileges. Remove if not needed
4. **No authentication**: noVNC has no additional authentication beyond VNC password
5. **Production use**: This setup is designed for development/testing. For production, add:
   - SSL/TLS encryption
   - Proper authentication
   - Network isolation
   - Regular security updates

## System Requirements

- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Disk**: 5GB for image + additional space for usage
- **Network**: Internet connection for building image

## License

This project configuration is provided as-is. Please refer to individual component licenses:
- [Ubuntu](https://ubuntu.com/licensing)
- [XFCE](https://www.xfce.org/)
- [TightVNC](https://www.tightvnc.com/)
- [noVNC](https://github.com/novnc/noVNC)
- [Vision](https://browser.vision/)

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

- Vision team for the automation tool
- noVNC project for browser-based VNC access
- XFCE team for the lightweight desktop environment
