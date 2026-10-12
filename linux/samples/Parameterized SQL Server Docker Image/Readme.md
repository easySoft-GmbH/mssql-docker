# Parameterized SQL Server Docker Image

A flexible Docker setup for Microsoft SQL Server with configurable components including High Availability (HA) and Full-Text Search (FTS) packages. This is provided AS-IS for reference only.

## Features

- **Parameterized Build**: Customize Ubuntu version, SQL Server version, and optional components
- **Optional Components**: Enable/disable HA and FTS packages as needed
- **Flexible Repository Configuration**: Auto-construct or provide custom Microsoft repository URLs
- **Docker Compose Ready**: Easy deployment with environment variable configuration

## Prerequisites

- Docker and Docker Compose installed
- At least 2GB of available RAM (SQL Server requirement)
- Internet connection for downloading packages

## Quick Start

1. **Clone the repository**

2. **Configure environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env with your preferences
   ```

3. **Build**:
   ```bash
   docker-compose build --no-cache
   ```

4. ** Deploy and Run **
   ```bash
   docker run -d --name sqlfts -p 14305:1433 -h sqlfts -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<yourPassword> sqlserver-fts:latest
   ``` 

## Configuration

### Environment Variables (.env file)

#### Build-time Parameters
| Variable | Default | Description |
|----------|---------|-------------|
| `UBUNTU_VERSION` | `22.04` | Base Ubuntu version |
| `REPO_DISTRO` | `ubuntu` | Repository distribution |
| `REPO_DISTRO_VERSION` | `22.04` | Distribution version for repository |
| `MSSQL_REPO_FLAVOR` | `mssql-server-2025` | SQL Server version (2017/2019/2022/2025) |
| `INSTALL_HA` | `false` | Install High Availability components |
| `INSTALL_FTS` | `true` | Install Full-Text Search components |


### Example .env file

This creates a custom container image with SQL Server 2022 with database engine and Full text search for Ubuntu 22.04.

```env
# Build params
UBUNTU_VERSION=22.04
REPO_DISTRO=ubuntu
REPO_DISTRO_VERSION=22.04
MSSQL_REPO_FLAVOR=mssql-server-2022
INSTALL_HA=false
INSTALL_FTS=true
```

## Usage Examples

### Basic SQL Server 2022 (Default)
```bash
docker-compose up -d
```

### SQL Server 2019 with HA
```bash
# Update .env:
# MSSQL_REPO_FLAVOR=mssql-server-2019
# INSTALL_HA=true

docker-compose build --no-cache
docker-compose up -d
```

### Custom Repository URL
You can override the automatic repository URL construction:
```bash
docker build --build-arg REPO_CONFIG_URL=https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list -t custom-sqlserver .
```

### Direct Docker Commands

**Build the image**:
```bash
docker build -t sqlserver-custom .
```

**Run with custom settings**:
```bash
docker run -d \
  --name sqlserver-container \
  -p 1433:1433 \
  -e ACCEPT_EULA=Y \
  -e SA_PASSWORD=<YourPassword> \
  -e MSSQL_PID=Developer \
  sqlserver-custom
```

## Supported SQL Server Versions

| Version | MSSQL_REPO_FLAVOR |
|---------|-------------------|
| SQL Server 2017 | `mssql-server-2017` |
| SQL Server 2019 | `mssql-server-2019` |
| SQL Server 2022 | `mssql-server-2022` |
| SQL Server 2025 | `mssql-server-2025` |


## File Structure

```
.
├── Dockerfile              # Main Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── .env                   # Environment variables
└── README.md              # This file
```


