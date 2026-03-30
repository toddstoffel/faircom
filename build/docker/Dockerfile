# Multi-architecture builder stage
FROM --platform=$BUILDPLATFORM debian:12-slim AS builder

WORKDIR /tmp/faircom

# Copy tar files from source directory
COPY source/FairCom-Edge.linux.*.tar ./

# Extract based on target architecture
ARG TARGETARCH
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) tar -xf FairCom-Edge.linux.el8.x64.64bit.*.tar --strip-components=1 ;; \
        arm64) tar -xf FairCom-Edge.linux.arm_generic.64bit.*.tar --strip-components=1 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    # Remove tar files immediately after extraction to save space during build \
    rm -f FairCom-Edge.linux.*.tar

# Final minimal image
FROM debian:12-slim

# OCI image specification labels for traceability, SBOM, and vulnerability scanning
ARG VERSION=latest
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="FairCom Edge" \
      org.opencontainers.image.description="FairCom Edge database server (multi-arch: amd64, arm64)" \
      org.opencontainers.image.vendor="FairCom" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Proprietary" \
      org.opencontainers.image.base.name="debian:12-slim"

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc6 \
    libstdc++6 \
    libgcc-s1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -g 1000 faircom && \
    useradd -m -u 1000 -g faircom faircom

# Set working directory
WORKDIR /opt/faircom

# Copy extracted files from builder stage
COPY --from=builder --chown=faircom:faircom /tmp/faircom/ ./

# Copy SQL utilities to /usr/local/bin for easy access
COPY --from=builder /tmp/faircom/tools/ctsqlcdb /usr/local/bin/ctsqlcdb
COPY --from=builder /tmp/faircom/tools/ctsqlimp /usr/local/bin/ctsqlimp
COPY --from=builder /tmp/faircom/tools/ctsqlutl /usr/local/bin/ctsqlutl
COPY --from=builder /tmp/faircom/drivers/ctree.drivers/bin/isql /usr/local/bin/isql
RUN chmod +x /usr/local/bin/ctsql* /usr/local/bin/isql

# Remove unnecessary components to reduce image size
RUN rm -rf tools drivers \
    server/agent server/dbnotify server/integration server/modbus \
    server/opc server/thingworx server/aggregation server/classes \
    tutorials

# Copy custom non-SSL configuration from config directory
COPY --chown=faircom:faircom config/services.json /opt/faircom/config/services.json

# Force MQExplorer to use non-SSL WebSocket (ws:// instead of wss://)
RUN find /opt/faircom/server/web/apps/MQExplorer -type f \( -name "*.js" -o -name "*.html" \) \
    -exec sed -i -e "s/a\.protocol==='mqttwss'/a.protocol==='mqttws'/g" \
                 -e "s/connectionCfg\.mqttWsPort=9002/connectionCfg.mqttWsPort=9001/g" \
                 -e 's/"wss"/"ws"/g' \
                 -e "s/'wss'/'ws'/g" \
                 -e 's/wss:\/\//ws:\/\//g' {} +

# Copy entrypoint script
COPY --chown=faircom:faircom docker/entrypoint.sh /opt/faircom/entrypoint.sh
RUN chmod +x /opt/faircom/entrypoint.sh

# Set library path for FairCom libraries
ENV LD_LIBRARY_PATH=/opt/faircom/server

# Graceful shutdown — lets the server flush in-flight connections before exit
STOPSIGNAL SIGTERM

# Switch to non-root user
USER faircom

# Expose ports
EXPOSE 6597 8080 8443 1883 8883 9001 9002

# Health check — confirms the HTTP listener is accepting requests
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -fsS http://localhost:8080/ > /dev/null || exit 1

# Start the server
WORKDIR /opt/faircom/server
ENTRYPOINT ["/opt/faircom/entrypoint.sh"]
CMD ["./faircom"]
