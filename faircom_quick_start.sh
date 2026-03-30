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

# Terminal formatting
RESET='\033[0m'
BOLD='\033[1m'
BWHITE='\033[1;37m'
BYELLOW='\033[1;33m'
BCYAN='\033[1;36m'
BGREEN='\033[1;32m'
DIM='\033[2m'
# OSC 8 hyperlink: link <url> <display text>
link() { printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$1" "$2"; }

start_container() {
    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container '${CONTAINER_NAME}' already exists. Use 'restart' to restart it."
        exit 1
    fi

    printf "\n"
    printf "Pulling FairCom Edge image...\n"
    docker pull "${IMAGE}"

    local LICENSE_URL="https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"
    local WEB_URL="http://localhost:${PORT_HTTP}"
    local API_URL="http://localhost:${PORT_HTTP}/api"

    printf "\n"
    printf "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${BWHITE} FairCom Edge — Evaluation Build${RESET}\n"
    printf "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "\n"
    printf " ${BYELLOW}[warn]${RESET} Evaluation license — 3-hour runtime limit\n"
    printf "    This build will automatically stop after 3 hours. Restart the container\n"
    printf "    to resume. For production use, contact FairCom for a full license.\n"
    printf "\n"
    printf " ${BCYAN}[info]${RESET} License agreement:\n"
    printf "    %s\n" "$(link "${LICENSE_URL}" "${LICENSE_URL}")"
    printf "\n"
    printf "    By starting this container you agree to the terms of that license.\n"
    printf "\n"
    printf "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "\n"

    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${PORT_HTTP}:8080" \
        -p "${PORT_MQTT_WS}:9001" \
        -p "${PORT_MQTT}:1883" \
        -p "${PORT_DB}:6597" \
        --restart unless-stopped \
        "${IMAGE}" > /dev/null

    printf "${BGREEN}[ok]${RESET} FairCom Edge started successfully!\n"
    printf "\n"
    printf "Web Interface:     %s\n" "$(link "${WEB_URL}" "${WEB_URL}")"
    printf "REST API:          %s\n" "$(link "${API_URL}" "${API_URL}")"
    printf "SQL Connection:    localhost:${PORT_DB}\n"
    printf "\n"
    printf "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}\n"
    printf "\n"
}

stop_container() {
    echo "Stopping FairCom Edge container..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || {
        echo "Container '${CONTAINER_NAME}' is not running."
        exit 1
    }
    docker rm "${CONTAINER_NAME}" 2>/dev/null
    printf "${BGREEN}[ok]${RESET} Container stopped and removed.\n"
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
