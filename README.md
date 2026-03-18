# FairCom Edge Docker

Minimal Docker image for FairCom Edge database (~350MB) configured for easy deployment.

**Docker Hub**: [toddstoffel0810/faircom](https://hub.docker.com/r/toddstoffel0810/faircom)

## Features

- ✅ Multi-architecture support: `linux/amd64` and `linux/arm64`
- ✅ Minimal size: ~350MB
- ✅ Non-SSL configuration for simple deployments
- ✅ Pre-configured services: HTTP, REST API, SQL, MQTT
- ✅ Web-based management tools included

## Prerequisites

**Docker must be installed and running on your machine.**

- Install Docker Desktop: [docker.com/get-started](https://www.docker.com/get-started)
- Verify installation: `docker --version`
- Ensure Docker daemon is running before proceeding

### Platform-Specific Notes

**Windows Users**: You have several options:
- **Recommended**: Use **PowerShell** scripts (`.ps1` files provided alongside `.sh` scripts)
- Use **WSL2** (Windows Subsystem for Linux) to run bash scripts
- Use **Git Bash** to run bash scripts
- Use **Docker commands directly** (shown in Alternative Methods section)

**macOS/Linux Users**: Use the provided bash scripts (`.sh` files)

## Quick Start

### macOS/Linux

The easiest way to get started is with this one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/toddstoffel/faircom/main/faircom_quick_start.sh | bash
```

Or if you've cloned the repository, run the script directly:

```bash
./faircom_quick_start.sh
```

#### Available Commands (macOS/Linux)

```bash
./faircom_quick_start.sh start    # Start the container (default)
./faircom_quick_start.sh stop     # Stop and remove the container
./faircom_quick_start.sh restart  # Restart the container
./faircom_quick_start.sh logs     # View container logs
```

### Windows (PowerShell)

If you've cloned the repository, run the PowerShell script:

```powershell
.\faircom_quick_start.ps1
```

#### Available Commands (Windows PowerShell)

```powershell
.\faircom_quick_start.ps1 start    # Start the container (default)
.\faircom_quick_start.ps1 stop     # Stop and remove the container
.\faircom_quick_start.ps1 restart  # Restart the container
.\faircom_quick_start.ps1 logs     # View container logs
```

**Note**: You may need to enable script execution in PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### What the Quick Start Does

- Pull the latest image from Docker Hub
- Start the container with all required ports
- Display access information

## Alternative Methods

### Using Docker Compose

Create a `docker-compose.yml`:

```yaml
services:
  faircom-edge:
    image: toddstoffel0810/faircom:latest
    container_name: faircom-edge
    restart: unless-stopped
    ports:
      - "8080:8080"   # HTTP (web apps and REST API)
      - "9001:9001"   # MQTT over WebSocket
      - "1883:1883"   # MQTT
      - "6597:6597"   # FairCom database
```

Then run:

```bash
docker compose up -d
```

### Using Docker CLI

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 \
  -p 9001:9001 \
  -p 1883:1883 \
  -p 6597:6597 \
  toddstoffel0810/faircom:latest
```

## Access Points

Once running, access FairCom Edge at:

- **Web Interface**: <http://localhost:8080>
- **REST API**: <http://localhost:8080/api>
- **SQL Connection**: localhost:6597

**Default credentials**: `ADMIN` / `ADMIN`

## Web Applications

The web interface includes several management tools:

- **MQExplorer** - MQTT broker management
- **AceMonitor** - Server monitoring and metrics
- **SQLExplorer** - SQL query interface
- **ISAMExplorer** - Low-level database explorer

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 8080 | HTTP | Web apps and REST API |
| 9001 | MQTT/WS | MQTT over WebSocket (non-SSL) |
| 1883 | MQTT | MQTT broker (non-SSL) |
| 6597 | Database | FairCom database port |

## Data Persistence

To persist data between container restarts, mount a volume:

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 -p 9001:9001 -p 1883:1883 -p 6597:6597 \
  -v faircom-data:/opt/faircom/data \
  toddstoffel0810/faircom:latest
```

Or with Docker Compose, uncomment the volumes section in `docker-compose.yml`.

## Configuration

This image is pre-configured with:

- Non-SSL services enabled (HTTP, MQTT, MQTT/WebSocket)
- SSL services disabled (no certificate required)
- Integration services disabled for minimal footprint

## Support

For issues or questions:

- Docker Hub: <https://hub.docker.com/r/toddstoffel0810/faircom>
- FairCom Documentation: <https://docs.faircom.com>

## License

FairCom Edge is commercial software. This Docker image uses FairCom Edge v5.1.0.84.
