<p align="center">
<a href="https://www.faircom.com"><img src="https://raw.githubusercontent.com/toddstoffel/faircom/main/assets/faircom-logo.svg" alt="FairCom" height="56"></a>
<br><br>
<strong>FairCom Edge Docker</strong><br>
Multi-architecture Docker image for <a href="https://www.faircom.com/products/faircom-edge">FairCom Edge</a> (~350MB) targeting <code>linux/amd64</code> and <code>linux/arm64</code>.
</p>

---

## What is FairCom Edge?

FairCom Edge is an IoT hub designed to run on the edge, from factory floors to warehouses to wind farms. It combines a database, MQTT broker, IoT connector, and transformation engine in a single platform so you can collect, process, and deliver machine data without stitching together separate tools.

<p align="center">
  <img src="https://raw.githubusercontent.com/toddstoffel/faircom/main/assets/edge-universal-translation.webp" alt="FairCom Edge connecting protocols, equipment, and external systems" width="80%">
</p>

- Full MQTT broker with store-and-forward messaging
- Embedded database with SQL and JSON APIs
- Protocol support for OPC-UA, Modbus, REST, and more
- JSON-based configuration, no specialized coding required
- Cloud publishing to analytics and ML platforms

## Using the Image

### Quick Start (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/toddstoffel/faircom/main/faircom_quick_start.sh | bash
```

Or clone the repo and run the script directly:

```bash
./faircom_quick_start.sh
```

Available commands:

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

If script execution is blocked, run this first:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Available commands:

```powershell
.\faircom_quick_start.ps1 start    # Start the container (default)
.\faircom_quick_start.ps1 stop     # Stop and remove the container
.\faircom_quick_start.ps1 restart  # Restart the container
.\faircom_quick_start.ps1 logs     # View container logs
```

### Docker Compose

The image includes a built-in `HEALTHCHECK` on port 8080. Use `condition: service_healthy` in dependent services to wait for FairCom Edge to be fully ready before starting:

```yaml
services:
  faircom-edge:
    image: faircomteam/edge:latest
    container_name: faircom-edge
    restart: unless-stopped
    ports:
      - "8080:8080"   # HTTP (web apps and REST API)
      - "9001:9001"   # MQTT over WebSocket
      - "1883:1883"   # MQTT
      - "6597:6597"   # FairCom database

  your-app:
    image: your-app:latest
    depends_on:
      faircom-edge:
        condition: service_healthy
```

Check health status at any time:

```bash
docker inspect --format='{{json .State.Health.Status}}' faircom-edge
```

### Docker CLI

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 \
  -p 9001:9001 \
  -p 1883:1883 \
  -p 6597:6597 \
  faircomteam/edge:latest
```

### Data Persistence

Mount a volume to retain data across container restarts:

```bash
docker run -d \
  --name faircom-edge \
  -p 8080:8080 -p 9001:9001 -p 1883:1883 -p 6597:6597 \
  -v faircom-data:/opt/faircom/data \
  faircomteam/edge:latest
```

## Access

Once running, the following are available:

| URL | Description |
|-----|-------------|
| <http://localhost:8080> | Web interface |
| <http://localhost:8080/api> | REST API |
| localhost:6597 | SQL connection |

Default credentials: `ADMIN` / `ADMIN`

### Web Applications

| App | Description |
|-----|-------------|
| MQExplorer | MQTT broker management |
| AceMonitor | Server monitoring and metrics |
| SQLExplorer | SQL query interface |
| ISAMExplorer | Low-level database explorer |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8080 | HTTP | Web apps and REST API |
| 9001 | MQTT/WS | MQTT over WebSocket |
| 1883 | MQTT | MQTT broker |
| 6597 | TCP | FairCom database |

---

## Image Details

| Property | Value |
|----------|-------|
| Base image | `debian:12-slim` |
| Architectures | `linux/amd64`, `linux/arm64` |
| Run as | Non-root (`faircom`, uid 1000) |
| Health check | HTTP GET `localhost:8080` every 30s |
| OCI labels | Full `org.opencontainers.image.*` set |

---

## Building the Image

### Prerequisites

1. Docker Desktop with `buildx` support
2. FairCom Edge binary tarballs downloaded from [faircom.com/products/download-edge](https://www.faircom.com/products/download-edge):
   - `FairCom-Edge.linux.el8.x64.64bit.<version>.tar` (for `linux/amd64`)
   - `FairCom-Edge.linux.arm_generic.64bit.<version>.tar` (for `linux/arm64`)

   Place both files in `build/source/` before building.

### Build and Push

Builds for `linux/amd64` and `linux/arm64`, pushes to Docker Hub, and updates the Docker Hub overview in one step:

```bash
cd build/docker
./build-and-push.sh faircomteam/edge latest
```

To also run Docker Scout vulnerability scan after push:

```bash
./build-and-push.sh faircomteam/edge latest --scout
```

### Local Build

```bash
cd build/docker
./build-local.sh faircomteam/edge latest
```

### Update Docker Hub Overview Only

```bash
cd build/docker
./build-and-push.sh faircomteam/edge --readme-only
```

---

## Support

- Docker Hub: <https://hub.docker.com/r/faircomteam/edge>
- FairCom Documentation: <https://docs.faircom.com>

## License

FairCom Edge is commercial software. This image packages FairCom Edge v5.1.0.84.

The evaluation build has a 3-hour runtime limit and needs to be restarted after that period.

By downloading or using this image you agree to the [FairCom Edge Developer License Agreement](https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf).

