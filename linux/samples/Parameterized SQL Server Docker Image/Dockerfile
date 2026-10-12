# -----------------------------------------------------------------------------
# Parameterized SQL Server image with optional HA/FTS packages
# -----------------------------------------------------------------------------

# Pick your base OS at build time
ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION}

# ---------------------------
# Build-time parameters
# ---------------------------
# Option A: pass an explicit repo config URL:
#   REPO_CONFIG_URL=https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list
ARG REPO_CONFIG_URL=""

# Option B: construct repo config URL from these args (used if REPO_CONFIG_URL is empty)
ARG REPO_DISTRO=ubuntu
ARG REPO_DISTRO_VERSION=22.04
ARG MSSQL_REPO_FLAVOR=mssql-server-2022  # e.g., mssql-server-2017 | mssql-server-2019 | mssql-server-2022

# Optional components
ARG INSTALL_HA=true
ARG INSTALL_FTS=true

# SQL Server package name (generally mssql-server)
ARG MSSQL_PACKAGE=mssql-server

# ---------------------------
# Install SQL Server + optional packages
# ---------------------------

# Accept Microsoft EULA
ENV ACCEPT_EULA=Y

## tracing each step and ensuring parameters are used correctly.
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      gnupg \
      apt-transport-https; \
    \
    # Add Microsoft signing key (modern replacement for apt-key)
    mkdir -p /usr/share/keyrings; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg; \
    chmod 644 /usr/share/keyrings/microsoft.gpg; \
    \
    # Determine repo config URL (explicit override or constructed)
    if [ -z "${REPO_CONFIG_URL}" ]; then \
      REPO_CONFIG_URL="https://packages.microsoft.com/config/${REPO_DISTRO}/${REPO_DISTRO_VERSION}/${MSSQL_REPO_FLAVOR}.list"; \
    fi; \
    echo "Using repo config: ${REPO_CONFIG_URL}"; \
    \
    # Fetch repo list, attach signed-by if needed
    curl -fsSL "${REPO_CONFIG_URL}" -o /etc/apt/sources.list.d/mssql-server.list; \
    \
    # Debug: show what was downloaded
    echo "Downloaded repository configuration:"; \
    cat /etc/apt/sources.list.d/mssql-server.list; \
    \
    # Ensure "signed-by" is present in the repo line(s)
    # If the downloaded list already has signed-by, this is harmless.
    sed -i 's|^deb \[|deb [signed-by=/usr/share/keyrings/microsoft.gpg |' /etc/apt/sources.list.d/mssql-server.list || true; \
    \
    # Debug: show modified configuration
    echo "Modified repository configuration:"; \
    cat /etc/apt/sources.list.d/mssql-server.list; \
    \
    apt-get update; \
    \
    # Accept Microsoft license agreement automatically
    export ACCEPT_EULA=Y; \
    \
    # Install SQL Server
    echo "Installing ${MSSQL_PACKAGE}..."; \
    apt-get install -y --no-install-recommends ${MSSQL_PACKAGE}; \
    \
    # Optional packages
    if [ "${INSTALL_HA}" = "true" ]; then apt-get install -y --no-install-recommends mssql-server-ha; fi; \
    if [ "${INSTALL_FTS}" = "true" ]; then apt-get install -y --no-install-recommends mssql-server-fts; fi; \
    \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# SQL Server listens on 1433 by default
EXPOSE 1433

# Default command
CMD ["/opt/mssql/bin/sqlservr"]
