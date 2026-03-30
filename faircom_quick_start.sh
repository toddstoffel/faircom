#!/bin/bash

# Launch FairCom Edge Docker container
# Usage: ./faircom_quick_start.sh [start|stop|restart|logs]

set -e

CONTAINER_NAME="faircom-edge"
IMAGE="faircomteam/edge:latest"

# Ports
PORT_HTTP="8080"
PORT_MQTT_WS="9001"
PORT_MQTT="1883"
PORT_DB="6597"

start_container() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " FairCom Edge — Evaluation Build"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo " ⚠  EVALUATION LICENSE — 3-HOUR RUNTIME LIMIT"
    echo "    This build will automatically stop after 3 hours. Restart the container"
    echo "    to resume. For production use, contact FairCom for a full license."
    echo ""
    echo " 📄 License agreement:"
    echo "    https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"
    echo ""
    echo "    By starting this container you agree to the terms of that license."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Starting FairCom Edge container..."
    
    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container '${CONTAINER_NAME}' already exists. Use 'restart' to restart it."
        exit 1
    fi
    
    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${PORT_HTTP}:8080" \
        -p "${PORT_MQTT_WS}:9001" \
        -p "${PORT_MQTT}:1883" \
        -p "${PORT_DB}:6597" \
        --restart unless-stopped \
        "${IMAGE}"
    
    echo ""
    echo "✅ FairCom Edge started successfully!"
    echo ""
    echo "Web Interface:     http://localhost:${PORT_HTTP}"
    echo "REST API:          http://localhost:${PORT_HTTP}/api"
    echo "SQL Connection:    localhost:${PORT_DB}"
    echo ""
    echo "Default credentials: ADMIN/ADMIN"
    echo ""
}

stop_container() {
    echo "Stopping FairCom Edge container..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || {
        echo "Container '${CONTAINER_NAME}' is not running."
        exit 1
    }
    docker rm "${CONTAINER_NAME}" 2>/dev/null
    echo "✅ Container stopped and removed."
}

restart_container() {
    echo "Restarting FairCom Edge container..."
    stop_container
    start_container
}

show_logs() {
    docker logs -f "${CONTAINER_NAME}"
}


show_usage() {
    echo "Usage: $0 [start|stop|restart|logs]"
    echo ""
    echo "Commands:"
    echo "  start    - Start the FairCom Edge container"
    echo "  stop     - Stop and remove the container"
    echo "  restart  - Restart the container"
    echo "  logs     - Show container logs (follow mode)"
    echo ""
    echo "If no command is provided, 'start' is assumed."
}

# Main
CMD="${1:-start}"

case "$CMD" in
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo "Error: Unknown command '$CMD'"
        echo ""
        show_usage
        exit 1
        ;;
esac
