#!/bin/sh
# entrypoint.sh — Docker entrypoint for FairCom Edge
#
# Default: prints the evaluation banner, starts the server, and streams
# the server log (CTSTATUS.FCS) to stdout so it appears in `docker logs`.
#
# Override: docker run faircomteam/edge <command>
#   e.g.    docker run -it faircomteam/edge bash

LOG_FILE="/opt/faircom/data/CTSTATUS.FCS"
LICENSE_URL="https://552967.fs1.hubspotusercontent-na1.net/hubfs/552967/V5_FairCom_Edge_Dev_260212.pdf"

# ANSI formatting
RESET='\033[0m'
BOLD='\033[1m'
BWHITE='\033[1;37m'
BCYAN='\033[1;36m'
BGREEN='\033[1;32m'

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

# ── User-supplied command override ──────────────────────────────────────────
# Anything other than the default server binary gets exec'd directly.
case "$1" in
    ./faircom) ;;
    *)         exec "$@" ;;
esac

# ── Start FairCom Edge ──────────────────────────────────────────────────────
"$@" &
SERVER_PID=$!

# Forward SIGTERM / SIGINT to the server for graceful shutdown
trap "kill -TERM $SERVER_PID 2>/dev/null" TERM INT

# Stream server log to stdout (wait up to 10 s for the file to appear)
_n=0
while [ ! -f "$LOG_FILE" ] && [ "$_n" -lt 10 ]; do
    sleep 1
    _n=$((_n + 1))
done
if [ -f "$LOG_FILE" ]; then
    tail -f "$LOG_FILE" &
    TAIL_PID=$!
fi

printf "\n"
printf "${BGREEN}[ok]${RESET} FairCom Edge started successfully!\n"
printf "\n"
printf "Web Interface:     http://localhost:8080\n"
printf "REST API:          http://localhost:8080/api\n"
printf "SQL Connection:    localhost:6597\n"
printf "\n"
printf "Default credentials: ${BOLD}ADMIN/ADMIN${RESET}\n"
printf "\n"

# Block until the server exits (crash, shutdown, or 3-hour eval timeout).
# If a trapped signal interrupts wait, re-wait so we get the real exit code.
wait "$SERVER_PID" 2>/dev/null || true
wait "$SERVER_PID" 2>/dev/null
EXIT_CODE=$?

# Clean up the log tail
[ -n "$TAIL_PID" ] && kill "$TAIL_PID" 2>/dev/null || true

exit "$EXIT_CODE"
