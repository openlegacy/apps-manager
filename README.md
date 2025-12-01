# OpenLegacy Apps - Docker Compose

A Docker Compose setup for running OpenLegacy development tools locally.

## 📦 What's Included

This setup includes:

### Community Apps (Always Available)
- **Homepage** (port 80) - Landing page with links to all tools
- **OL Terminal** (port 8081) - Web-based terminal for mainframe and AS/400 systems
- **OL Code** (port 8082) - Web-based IDE for legacy code development
- **SQOL** (port 8083) - Universal SQL console for databases

### Enterprise Apps (Optional - requires `--all` or `--all-ai` flag)
- **Hub Integration** (port 8080) - Enterprise platform for API management and legacy system integration
- **Hub Planner** (port 8080) - Strategic modernization planning tool (accessible via `/mpt/baselines`)
- **AppIQ** (port 8084) - No-code application builder that converts terminal screens into modern applications
- **OL TermIQ** (port 8085) - Terminal Intelligence for mainframe session recording, analysis, and automation
- **PostgreSQL** (port 5432) - Database for Hub Enterprise, AppIQ, and TermIQ data persistence

## 🚀 Quick Start

### Prerequisites

- Docker installed and running
- Docker Compose installed

### ⚠️ Important: License Configuration

Before starting the services, you **must** configure your OpenLegacy licenses:

#### Community Tools License (Required for all services)

1. **Go to the [OpenLegacy Community Site](https://community.openlegacy.com/)**
2. **Log in to your account**
3. **Navigate to your User Profile**
4. **Copy your community license token**
5. **Open `config.env` in this directory**
6. **Set `OL_TOOL_LICENSE` with your actual license token:**

```env
OL_TOOL_LICENSE=your-actual-community-license-token-goes-here
OL_ADMIN=openlegacy
OL_PASSWORD=olpassword

OLCODE_ADMIN=openlegacy
OLCODE_PASSWORD=olpassword
```

#### Enterprise License (Required when using `--all` or `--all-ai`)

When starting with `--all` or `--all-ai`, you'll also need to configure:

- **`OL_LICENSE`** - Your OpenLegacy Enterprise license (required for Hub Integration)
- **`OL_HUB_API_KEY`** - Hub API key (can be obtained from Hub UI at http://localhost:8080 after first start)

#### AI Configuration (Optional, for `--all-ai`)

When using `--all-ai`, configure AI settings:

```env
OL_AI_ENABLED_KEY=true
OL_AI_VENDOR=openai
OL_AI_MODEL_NAME=gpt-4.1
OL_AI_API_KEY=your-openai-api-key
```

> 💡 **Tip:** The `apps.sh` script will prompt you for missing licenses and API keys when starting services. You can also customize admin usernames and passwords in `config.env`.

### Starting the Services

Once you've configured your license, you can start services in three ways:

#### Option 1: Community Apps Only (Default)

Start the core free tools without Hub Enterprise:

```bash
./apps.sh start
```

Or using docker-compose directly:

```bash
docker-compose up -d
```

#### Option 2: All Apps Including Hub Enterprise

Start all services including Hub Integration, AppIQ, TermIQ, and PostgreSQL:

```bash
./apps.sh start --all
```

Or using docker-compose directly:

```bash
docker-compose --profile all up -d
```

#### Option 3: All Apps with AI Features

Start all services including Hub Enterprise with AI capabilities:

```bash
./apps.sh start --all-ai
```

Or using docker-compose directly:

```bash
docker-compose --profile all-ai up -d
```

> 💡 **Note:** Hub Enterprise requires additional resources. Use `--all` or `--all-ai` only if you need enterprise features. The `--all-ai` option enables AI-powered features in Hub Integration.

### Accessing the Applications

Open your browser and visit:

- **🏠 Homepage:** http://localhost (or http://localhost:80)
- **💻 OL Terminal:** http://localhost:8081
- **⚡ OL Code:** http://localhost:8082
- **🗄️ SQOL:** http://localhost:8083

If you started with `--all` or `--all-ai`:
- **🏢 Hub Integration:** http://localhost:8080
- **📋 Hub Planner:** http://localhost:8080/mpt/baselines
- **📱 AppIQ:** http://localhost:8084
- **🎯 OL TermIQ:** http://localhost:8085
- **🗄️ PostgreSQL:** localhost:5432 (user: postgres, password: olhubpassword)
- **🤖 Python AI Service** (with `--all-ai`): http://localhost:8090 (internal debugging)

## 🛠️ Managing Services

### Using the Helper Script

The `apps.sh` script provides convenient commands:

```bash
./apps.sh start              # Start community apps only
./apps.sh start --all        # Start all apps including Hub Enterprise
./apps.sh start --all-ai     # Start all apps including Hub Enterprise with AI
./apps.sh stop               # Stop all running services
./apps.sh stop --all         # Stop all services including Hub
./apps.sh stop --all-ai      # Stop all services including Hub with AI
./apps.sh restart            # Restart services
./apps.sh restart --all      # Restart all services including Hub
./apps.sh restart --all-ai   # Restart all services including Hub with AI
./apps.sh logs                # View logs (follow mode)
./apps.sh logs --all          # View logs including Hub
./apps.sh logs --all-ai       # View logs including Hub with AI
./apps.sh status              # Show service status
./apps.sh status --all        # Show all services including Hub
./apps.sh status --all-ai     # Show all services including Hub with AI
./apps.sh pull                # Pull latest images
./apps.sh pull --all          # Pull all images including Hub
./apps.sh pull --all-ai       # Pull all images including Hub with AI
```

> 💡 **Tip:** Add `--all` or `--all-ai` to any command to include Hub Enterprise and PostgreSQL services.

### Using Docker Compose Directly

```bash
# Community apps only
docker-compose up -d                    # Start services in background
docker-compose down                     # Stop and remove containers
docker-compose ps                       # List running services
docker-compose logs -f                  # View logs
docker-compose restart                  # Restart services

# All apps including Hub Enterprise
docker-compose --profile all up -d      # Start all services
docker-compose --profile all down       # Stop all services
docker-compose --profile all ps         # List all services
docker-compose --profile all logs -f    # View all logs

# All apps including Hub Enterprise with AI
docker-compose --profile all-ai up -d   # Start all services with AI
docker-compose --profile all-ai down    # Stop all services with AI
docker-compose --profile all-ai ps      # List all services with AI
docker-compose --profile all-ai logs -f # View all logs with AI
```

## 💾 Data Persistence

Application data is stored in two ways:

### Community Apps - Local Directories (Version-Controllable)
Configuration files are stored in local directories that you can edit directly:
- `./.ol-terminal/` - OL Terminal configurations and data
- `./.olcode/` - OL Code projects and settings
- `./.sqol/` - SQOL connections and queries

### Enterprise Apps - Local Directories (when using `--all` or `--all-ai`)
- `./.termiq/` - TermIQ session recordings, configurations, and analysis data
- `./.appiq/` - AppIQ application configurations and project data

These directories are bind-mounted from your project folder, allowing you to:
- Edit configuration files directly in your IDE
- Version control your app configurations
- Share configurations across team members
- Backup configurations easily

### Enterprise Apps - Docker Volumes (when using `--all`)
- `apps_hub-postgres-data` - PostgreSQL database for Hub Enterprise

Your data persists across container restarts and system reboots. 

**To reset configuration:**
```bash
# Stop services
./apps.sh stop

# Remove configuration directories
rm -rf .ol-terminal .olcode .sqol

# Restart - apps will create fresh configurations
./apps.sh start
```

**To delete all data including Hub, AppIQ, and TermIQ:**
```bash
docker-compose --profile all down -v  # ⚠️ This deletes PostgreSQL data!
rm -rf .ol-terminal .olcode .sqol .termiq .appiq  # Remove local configurations
```

**To reset PostgreSQL database data:**
```bash
# Stop the containers
docker-compose down

# Remove the specific volume
docker volume rm apps-manager_hub-postgres-data

# Start again (volume will be recreated automatically)
docker-compose up -d
```

> 💡 **Note:** The volume name will be prefixed with your project directory name (e.g., `apps-manager_hub-postgres-data`). To see all volumes, use `docker volume ls`. To see the exact volume name for your project, use `docker-compose config --volumes`.

## 🔧 Troubleshooting

### License Error

If you see license-related errors, make sure you:
1. Copied the correct license from your [Community Profile](https://community.openlegacy.com/)
2. Updated `config.env` with your license
3. Restarted the services after updating the license

### Permission Errors

All services run as root (user 0:0) to avoid permission issues with volumes. The configuration directories are automatically created with proper permissions when you first start the services.

If you still encounter permission errors:

```bash
./apps.sh stop
rm -rf .ol-terminal .olcode .sqol
./apps.sh start
```

### Port Conflicts

If ports 80, 8080-8085, or 5432 are already in use, you can modify the ports in `docker-compose.yml`:

```yaml
ports:
  - "NEW_PORT:80"    # Change NEW_PORT to your desired port for homepage
  - "NEW_PORT:8080"  # Change NEW_PORT to your desired port for Hub
```

**Common port mappings:**
- Port 80: Homepage
- Port 8080: Hub Integration
- Port 8081: OL Terminal
- Port 8082: OL Code
- Port 8083: SQOL
- Port 8084: AppIQ
- Port 8085: OL TermIQ
- Port 5432: PostgreSQL

### Container Already Exists

If you previously ran the services with `docker run`, remove the old containers:

```bash
docker rm -f ol-terminal ol-code sqol ol-homepage ol-hub ol-termiq appiq hub-postgres
```

Then start with docker-compose:

```bash
./apps.sh start --all
```

### Hub Enterprise and TermIQ Connection Issues

If Hub Enterprise or TermIQ fail to start or connect to the database:

1. Check if PostgreSQL is running:
```bash
docker ps | grep hub-postgres
```

2. Check the database initialization:
```bash
docker logs hub-postgres
```

3. Verify databases were created:
```bash
docker exec -it hub-postgres psql -U postgres -c "\l"
# Should show: olhub and termiq databases
```

4. Check Hub logs for errors:
```bash
docker logs ol-hub
```

5. Check TermIQ logs for errors:
```bash
docker logs ol-termiq
```

6. Restart Hub and TermIQ services:
```bash
./apps.sh restart --all
```

## 📝 Configuration Files

- **`docker-compose.yml`** - Service definitions and configuration
- **`config.env`** - Environment variables (license, credentials)
- **`apps.sh`** - Helper script for managing services
- **`index.html`** - Homepage template
- **`init-db.sql`** - PostgreSQL initialization script (creates olhub and termiq databases)
- **`.ol-terminal/`** - OL Terminal configuration directory (created on first run)
- **`.olcode/`** - OL Code configuration directory (created on first run)
- **`.sqol/`** - SQOL configuration directory (created on first run)
- **`.termiq/`** - TermIQ configuration directory (created on first run with `--all` or `--all-ai`)
- **`.appiq/`** - AppIQ configuration directory (created on first run with `--all` or `--all-ai`)

### Pre-configuring Apps

You can pre-configure apps by creating these directories before first run. For example, to pre-configure SQOL with database connections:

1. Create `.sqol` directory
2. Add `connections.json` with your database connections
3. Add `application.yaml` with your settings
4. Start the services with `./apps.sh start`

SQOL will use your pre-configured connections immediately!

### Automatic API Key Replacement

The `apps.sh` script automatically replaces Hub API keys in configuration files:

- **`${OL_HUB_API_KEY:}`** placeholders in `application.yaml` files are replaced with your actual API key
- **`hubApiKey`** or **`hub-api-key`** values in YAML files are updated
- **`apiKey`** values in JSON configuration files are updated

This happens automatically when you start services with `--all` or `--all-ai`. The script searches for configuration files in subdirectories (e.g., `.sqol/application.yaml`, `.olcode/application.yaml`) and updates them with your Hub API key from `config.env`.

### DB2 Database Connections

For DB2 database connections in SQOL, ensure the DB2 JDBC driver license file is available:

```bash
# Place db2jcc_license_cisuz.jar in .sqol/jars directory
mkdir -p .sqol/jars
# Copy your db2jcc_license_cisuz.jar file to .sqol/jars/
```

### Connecting to PostgreSQL

When running with `--all` or `--all-ai`, PostgreSQL is available for direct connections:

**Connection Details:**
- **Host:** `localhost` (from host machine) or `hub-postgres` (from containers)
- **Port:** `5432`
- **Username:** `postgres`
- **Password:** `olhubpassword`
- **Databases:** `olhub`, `termiq`

**Example connection strings:**
```bash
# Using psql from host machine
psql -h localhost -p 5432 -U postgres -d olhub

# From within containers
psql -h hub-postgres -p 5432 -U postgres -d termiq

# JDBC URL
jdbc:postgresql://localhost:5432/olhub?user=postgres&password=olhubpassword
```

### Inter-Container Communication

Containers in Docker Compose can communicate with each other using **service names** as hostnames. This is important when apps need to connect to each other.

**Important:** When referencing other containers from within a container, use:
- **Service name**: Use the exact name from `docker-compose.yml` (e.g., `ol-hub`)
- **Internal port**: `8080` (not the host-exposed ports like 8084, 8085)

For example, in `.sqol/application.yaml`:
```yaml
generalSettings:
  hubUrl: http://ol-hub:8080   # ✅ Correct - uses service name and internal port
  # NOT: http://localhost:8084  # ❌ Wrong - localhost refers to the container itself
```

**Port Mapping Summary:**
| From | To | URL |
|------|-----|-----|
| Your browser | Homepage | `http://localhost` or `http://localhost:80` |
| Your browser | Hub Integration | `http://localhost:8080` |
| Your browser | OL Terminal | `http://localhost:8081` |
| Your browser | OL Code | `http://localhost:8082` |
| Your browser | SQOL | `http://localhost:8083` |
| Your browser | AppIQ | `http://localhost:8084` |
| Your browser | OL TermIQ | `http://localhost:8085` |
| Your browser | PostgreSQL | `postgresql://localhost:5432` |
| SQOL container | Hub container | `http://ol-hub:8080` |
| OL Code container | Hub container | `http://ol-hub:8080` |
| OL Terminal container | Hub container | `http://ol-hub:8080` |
| AppIQ container | Hub container | `http://ol-hub:8080` |
| TermIQ container | Hub container | `http://ol-hub:8080` |
| Hub container | PostgreSQL | `postgresql://hub-postgres:5432/olhub` |
| AppIQ container | PostgreSQL | `postgresql://hub-postgres:5432/olhub` |
| TermIQ container | PostgreSQL | `postgresql://hub-postgres:5432/termiq` |

**Other service names you can use:**
- `ol-terminal` or `http://ol-terminal:8080`
- `ol-code` or `http://ol-code:8080`
- `sqol` or `http://sqol:8080`
- `ol-hub` or `http://ol-hub:8080`
- `appiq` or `http://appiq:8080`
- `ol-termiq` or `http://ol-termiq:8080`
- `hub-postgres` or `postgresql://hub-postgres:5432`

**Troubleshooting DNS issues:**
If you get "UnknownHostException" or DNS resolution errors:
1. Verify all containers are running: `docker ps`
2. Check they're on the same network: `docker network inspect apps_app-network`
3. Restart the container having issues: `docker restart <container-name>`
4. If still failing, restart all services: `./apps.sh restart --all`

## 🔄 Updating Images

To pull the latest versions of the OpenLegacy tools:

```bash
# Update community apps only
./apps.sh pull
docker-compose up -d

# Update all apps including Hub
./apps.sh pull --all
docker-compose --profile all up -d

# Update all apps including Hub with AI
./apps.sh pull --all-ai
docker-compose --profile all-ai up -d
```

## 🔐 Security Notes

- The `config.env` file contains sensitive information (license and passwords)
- Configuration directories (`.ol-terminal/`, `.olcode/`, `.sqol/`) may contain connection strings and credentials
- **Do not commit `config.env` to version control**
- **Consider adding configuration directories to `.gitignore` if they contain sensitive data**
- Change default passwords for production use
- Review configuration files before committing to ensure no secrets are exposed

## 📚 Additional Resources

- [OpenLegacy Community](https://community.openlegacy.com/)
- [Community Forum](https://forum.community.openlegacy.com/)
- [Hub Integration Documentation](https://docs.ol-hub.com/docs/getting-started-with-openlegacy-hub)
- [Hub Planner Documentation](https://docs.planner.ol-hub.com/docs/getting-started-with-planner)

## 🏢 Hub Enterprise Features

When running with `--all` or `--all-ai`, you get access to enterprise features:

### Hub Integration
- **Automatic API Generation** - Transform legacy systems into modern REST APIs
- **Legacy System Analysis** - Analyze and optimize mainframe processes
- **Modernization Planning** - Create strategic modernization roadmaps with Hub Planner
- **Centralized Security** - Enterprise-grade security and access control
- **ETL & CDC** - Extract, Transform, Load and Change Data Capture workflows
- **AI-Powered Features** (with `--all-ai`) - AI-assisted API generation, code analysis, and modernization planning

### Hub Planner
- **Strategic Planning** - Analyze dependencies and create phased modernization plans
- **Risk Assessment** - De-risk your legacy transformation journey
- **Dependency Mapping** - Visualize system dependencies and relationships
- **Roadmap Creation** - Build comprehensive modernization roadmaps

### AppIQ
- **No-Code Application Builder** - Convert terminal screens into modern applications
- **Screen Capture Integration** - Use screens captured by OL Terminal
- **API Integration** - Consume backend APIs from Hub Integration
- **Domain Model Support** - Build apps from domain models and other sources

### OL TermIQ (Terminal Intelligence)
- **Session Recording** - Capture and replay mainframe terminal sessions
- **Transaction Analysis** - Analyze terminal workflows and identify optimization opportunities
- **Automated Testing** - Create test scenarios from recorded sessions
- **Process Mining** - Extract business process insights from terminal interactions
- **Integration Testing** - Test API integrations against real terminal workflows

### PostgreSQL Database
- **olhub database** - Stores Hub Enterprise configuration, projects, AppIQ apps, and metadata
- **termiq database** - Stores TermIQ session recordings, analysis data, and test scenarios
- **External Access** - Available on port 5432 for direct database connections and backup/restore

Learn more at: https://community.openlegacy.com/hub

## ❓ Need Help?

If you encounter issues:
1. Check the logs: `./apps.sh logs`
2. Verify your license is correctly configured in `config.env`
3. Ensure Docker is running and up to date
4. Visit the [OpenLegacy Community](https://community.openlegacy.com/) for support

