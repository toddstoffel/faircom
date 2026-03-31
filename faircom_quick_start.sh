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

start_container() {
    # If container already exists, handle gracefully based on its state
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            printf "${BGREEN}[ok]${RESET} FairCom Edge is already running.\n"
            printf "\n"
            printf "Web Interface:     http://localhost:${PORT_HTTP}\n"
            printf "REST API:          http://localhost:${PORT_HTTP}/api\n"
            printf "SQL Connection:    localhost:${PORT_DB}\n"
            printf "\n"
            printf "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}\n"
            printf "\n"
        else
            printf "${BYELLOW}[warn]${RESET} Container exists but is stopped. Starting it...\n"
            docker start "${CONTAINER_NAME}" > /dev/null
            printf "${BGREEN}[ok]${RESET} FairCom Edge started.\n"
            printf "\n"
            printf "Web Interface:     http://localhost:${PORT_HTTP}\n"
            printf "REST API:          http://localhost:${PORT_HTTP}/api\n"
            printf "SQL Connection:    localhost:${PORT_DB}\n"
            printf "\n"
            printf "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}\n"
            printf "\n"
        fi
        return
    fi

    printf "\n"
    printf "Pulling FairCom Edge image...\n"
    docker pull "${IMAGE}"

    local LICENSE_URL="https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"
    local WEB_URL="http://localhost:${PORT_HTTP}"
    local API_URL="http://localhost:${PORT_HTTP}/api"
    printf "\n"
    printf "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${BWHITE} FairCom Edge${RESET}\n"
    printf "${BWHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "\n"
    printf " ${BCYAN}[info]${RESET} This image ships with an evaluation license (3-hour runtime limit).\n"
    printf "    Restart the container to resume. To remove this limit, bind-mount a\n"
    printf "    production license file to /opt/faircom/server/ctsrvr.lic\n"
    printf "\n"
    printf " ${BCYAN}[info]${RESET} License agreement:\n"
    printf "    %s\n" "${LICENSE_URL}"
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
    printf "Web Interface:     %s\n" "${WEB_URL}"
    printf "REST API:          %s\n" "${API_URL}"
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
