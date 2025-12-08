# FairCom Edge Sample Data Creation Script
# This script runs the Python data generator inside the Docker container

param()

$ErrorActionPreference = 'Stop'

$CONTAINER_NAME = "faircom-edge"

Write-Host "========================================"
Write-Host "FairCom Edge Sample Data Creator"
Write-Host "========================================"
Write-Host ""

# Check if container is running
$runningContainer = docker ps --format '{{.Names}}' | Where-Object { $_ -eq $CONTAINER_NAME }
if (-not $runningContainer) {
    Write-Host "❌ Error: Container '$CONTAINER_NAME' is not running" -ForegroundColor Red
    Write-Host "Please start the container first with:"
    Write-Host "  .\faircom_quick_start.ps1 start"
    exit 1
}

Write-Host "✓ Container '$CONTAINER_NAME' is running" -ForegroundColor Green
Write-Host ""

# Run the Python script inside the container
docker exec -w /opt/faircom/server $CONTAINER_NAME python3 /usr/local/bin/create_sample_data.py

exit $LASTEXITCODE
