# Launch FairCom Edge Docker container
# Usage: .\faircom_quick_start.ps1 [start|stop|restart|logs]

param(
    [Parameter(Position=0)]
    [ValidateSet('start', 'stop', 'restart', 'logs', 'help')]
    [string]$Command = 'start'
)

$ErrorActionPreference = 'Stop'

$CONTAINER_NAME = "faircom-edge"
$IMAGE = "faircomteam/edge:latest"

# Ports
$PORT_HTTP = "8080"
$PORT_MQTT_WS = "9001"
$PORT_MQTT = "1883"
$PORT_DB = "6597"

# Terminal formatting (ANSI — supported by Windows Terminal)
$ESC = [char]27
$RESET    = "$ESC[0m"
$BOLD     = "$ESC[1m"
$BWHITE   = "$ESC[1;37m"
$BYELLOW  = "$ESC[1;33m"
$BCYAN    = "$ESC[1;36m"
$BGREEN   = "$ESC[1;32m"

function Start-Container {
    # If container already exists, handle gracefully based on its state
    $existingContainer = docker ps -a --format '{{.Names}}' | Where-Object { $_ -eq $CONTAINER_NAME }
    if ($existingContainer) {
        $runningContainer = docker ps --format '{{.Names}}' | Where-Object { $_ -eq $CONTAINER_NAME }
        if ($runningContainer) {
            Write-Host "${BGREEN}[ok]${RESET} FairCom Edge is already running."
            Write-Host ""
            Write-Host "Web Interface:     http://localhost:$PORT_HTTP"
            Write-Host "REST API:          http://localhost:$PORT_HTTP/api"
            Write-Host "SQL Connection:    localhost:$PORT_DB"
            Write-Host ""
            Write-Host "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}"
            Write-Host ""
        } else {
            Write-Host "${BYELLOW}[warn]${RESET} Container exists but is stopped. Starting it..."
            docker start $CONTAINER_NAME | Out-Null
            Write-Host "${BGREEN}[ok]${RESET} FairCom Edge started."
            Write-Host ""
            Write-Host "Web Interface:     http://localhost:$PORT_HTTP"
            Write-Host "REST API:          http://localhost:$PORT_HTTP/api"
            Write-Host "SQL Connection:    localhost:$PORT_DB"
            Write-Host ""
            Write-Host "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}"
            Write-Host ""
        }
        return
    }

    Write-Host ""
    Write-Host "Pulling FairCom Edge image..."
    docker pull $IMAGE

    $LICENSE_URL = "https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"
    $WEB_URL     = "http://localhost:$PORT_HTTP"
    $API_URL     = "http://localhost:$PORT_HTTP/api"

    Write-Host ""
    Write-Host "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    Write-Host "${BWHITE} FairCom Edge${RESET}"
    Write-Host "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    Write-Host ""
    Write-Host " ${BCYAN}[info]${RESET} This image ships with an evaluation license (3-hour runtime limit)."
    Write-Host "    Restart the container to resume. To remove this limit, bind-mount a"
    Write-Host "    production license file to /opt/faircom/server/ctsrvr.lic"
    Write-Host ""
    Write-Host " ${BCYAN}[info]${RESET} License agreement:"
    Write-Host "    $LICENSE_URL"
    Write-Host ""
    Write-Host "    By starting this container you agree to the terms of that license."
    Write-Host ""
    Write-Host "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    Write-Host ""

    docker run -d `
        --name $CONTAINER_NAME `
        -p "${PORT_HTTP}:8080" `
        -p "${PORT_MQTT_WS}:9001" `
        -p "${PORT_MQTT}:1883" `
        -p "${PORT_DB}:6597" `
        --restart unless-stopped `
        $IMAGE | Out-Null

    Write-Host "${BGREEN}[ok]${RESET} FairCom Edge started successfully!"
    Write-Host ""
    Write-Host "Web Interface:     $WEB_URL"
    Write-Host "REST API:          $API_URL"    Write-Host "SQL Connection:    localhost:$PORT_DB"
    Write-Host ""
    Write-Host "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}"
    Write-Host ""
}

function Stop-Container {
    Write-Host "Stopping FairCom Edge container..." -ForegroundColor Cyan
    
    try {
        docker stop $CONTAINER_NAME 2>$null
        docker rm $CONTAINER_NAME 2>$null
        Write-Host "${BGREEN}[ok]${RESET} Container stopped and removed."
    }
    catch {
        Write-Host "Container '$CONTAINER_NAME' is not running." -ForegroundColor Yellow
        exit 1
    }
}

function Restart-Container {
    Write-Host "Restarting FairCom Edge container..." -ForegroundColor Cyan
    Stop-Container
    Start-Container
}

function Show-Logs {
    docker logs -f $CONTAINER_NAME
}

function Show-Usage {
    Write-Host "Usage: .\faircom_quick_start.ps1 [start|stop|restart|logs]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  start    - Start the FairCom Edge container"
    Write-Host "  stop     - Stop and remove the container"
    Write-Host "  restart  - Restart the container"
    Write-Host "  logs     - Show container logs (follow mode)"
    Write-Host ""
    Write-Host "If no command is provided, 'start' is assumed."
}

# Main execution
switch ($Command) {
    'start' {
        Start-Container
    }
    'stop' {
        Stop-Container
    }
    'restart' {
        Restart-Container
    }
    'logs' {
        Show-Logs
    }
    'help' {
        Show-Usage
    }
    default {
        Write-Host "Error: Unknown command '$Command'" -ForegroundColor Red
        Write-Host ""
        Show-Usage
        exit 1
    }
}
