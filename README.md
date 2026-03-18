# FairCom Edge Docker

Official Docker image build repository for [FairCom Edge](https://www.faircom.com/products/faircom-edge) — a minimal, multi-architecture image (~350MB) for `linux/amd64` and `linux/arm64`.

**Docker Hub**: [toddstoffel0810/faircom](https://hub.docker.com/r/toddstoffel0810/faircom)

## Using the Image

### Quick Start (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/toddstoffel/faircom/main/faircom_quick_start.sh | bash
```

Or clone the repo and run directly:

```bash
./faircom_quick_start.sh
```

**Commands:**

```bash
./faircom_quick_start.sh start    # Start the container (default)
./faircom_quick_start.sh stop     # Stop and remove the container
./faircom_quick_start.sh restart  # Restart the container
./faircom_quick_start.sh logs     # View container logs
```

### Quick Start (Windows PowerShell)

```powershell
.\faircom_quick_start.ps1
```

**Note**: You may need to enable script execution first:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Commands:**

```powershell
.\faircom_quick_start.ps1 start    # Start the container (default)
.\faircom_quick_start.ps1 stop     # Stop and remove the container
.\faircom_quick_start.ps1 restart  # Restart the container
.\faircom_quick_start.ps1 logs     # View container logs
```

### Docker Compose

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

### Docker CLI

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 \
  -p 9001:9001 \
  -p 1883:1883 \
  -p 6597:6597 \
  toddstoffel0810/faircom:latest
```

### Data Persistence

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 -p 9001:9001 -p 1883:1883 -p 6597:6597 \
  -v faircom-data:/opt/faircom/data \
  toddstoffel0810/faircom:latest
```

## Access Points

| URL | Description |
|-----|-------------|
| <http://localhost:8080> | Web Interface |
| <http://localhost:8080/api> | REST API |
| localhost:6597 | SQL Connection |

**Default credentials**: `ADMIN` / `ADMIN`

## Web Applications

- **MQExplorer** — MQTT broker management
- **AceMonitor** — Server monitoring and metrics
- **SQLExplorer** — SQL query interface
- **ISAMExplorer** — Low-level database explorer

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 8080 | HTTP | Web apps and REST API |
| 9001 | MQTT/WS | MQTT over WebSocket (non-SSL) |
| 1883 | MQTT | MQTT broker (non-SSL) |
| 6597 | Database | FairCom database port |

---

## Building the Image

### Prerequisites

1. **Docker Desktop** with `buildx` support
2. **FairCom Edge binary tarballs** — download from [faircom.com/products/download-edge](https://www.faircom.com/products/download-edge):
   - `FairCom-Edge.linux.el8.x64.64bit.<version>.tar` — for `linux/amd64`
   - `FairCom-Edge.linux.arm_generic.64bit.<version>.tar` — for `linux/arm64`

   Place both files in `build/source/`.

### Build and Push (multi-architecture)

```bash
cd build/docker
./build-and-push.sh toddstoffel0810/faircom latest
```

Builds for both `linux/amd64` and `linux/arm64`, pushes the image to Docker Hub, and updates the Docker Hub README — all in one step.

### Local Build

```bash
cd build/docker
./build-local.sh toddstoffel0810/faircom latest
```

### Update Docker Hub README Only

```bash
cd build/docker
./build-and-push.sh toddstoffel0810/faircom --readme-only
```

---

## Support

- Docker Hub: <https://hub.docker.com/r/toddstoffel0810/faircom>
- FairCom Documentation: <https://docs.faircom.com>

## License

FairCom Edge is commercial software. This Docker image uses FairCom Edge v5.1.0.84.

> **Demo Limitation**: The FairCom Edge evaluation build has a **3-hour runtime limit** and must be restarted after that period.

By using this image, you agree to the [FairCom Edge Developer License Agreement](https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf).

