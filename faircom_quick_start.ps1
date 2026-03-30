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
    # Check if container already exists
    $existingContainer = docker ps -a --format '{{.Names}}' | Where-Object { $_ -eq $CONTAINER_NAME }
    if ($existingContainer) {
        Write-Host "Container '$CONTAINER_NAME' already exists. Use 'restart' to restart it."
        exit 1
    }

    Write-Host ""
    Write-Host "Pulling FairCom Edge image..."
    docker pull $IMAGE

    $LICENSE_URL = "https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"
    $WEB_URL     = "http://localhost:$PORT_HTTP"
    $API_URL     = "http://localhost:$PORT_HTTP/api"

    Write-Host ""
    Write-Host "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    Write-Host "${BWHITE} FairCom Edge — Evaluation Build${RESET}"
    Write-Host "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    Write-Host ""
    Write-Host " ${BYELLOW}[warn]${RESET} Evaluation license — 3-hour runtime limit"
    Write-Host "    This build will automatically stop after 3 hours. Restart the container"
    Write-Host "    to resume. For production use, contact FairCom for a full license."
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
