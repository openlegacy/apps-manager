# OpenLegacy Apps - Docker Compose

A Docker Compose setup for running OpenLegacy development tools locally.

## 📦 What's Included

This setup includes:

### Community Apps (Always Available)
- **Homepage** (port 8080) - Landing page with links to all tools
- **OL Terminal** (port 8081) - Web-based terminal for mainframe and AS/400 systems
- **OL Code** (port 8082) - Web-based IDE for legacy code development
- **SQOL** (port 8083) - Universal SQL console for databases

### Enterprise Apps (Optional - requires `--all` flag)
- **Hub Integration** (port 8084) - Enterprise platform for API management and legacy system integration
- **PostgreSQL** (internal) - Database for Hub Enterprise data persistence

## 🚀 Quick Start

### Prerequisites

- Docker installed and running
- Docker Compose installed

### ⚠️ Important: License Configuration

Before starting the services, you **must** configure your OpenLegacy license:

1. **Go to the [OpenLegacy Community Site](https://community.openlegacy.com/)**
2. **Log in to your account**
3. **Navigate to your User Profile**
4. **Copy your license token**
5. **Open `config.env` in this directory**
6. **Replace `your-license-token-here` with your actual license token:**

```env
OL_TOOL_LICENSE=your-actual-license-token-goes-here
OL_ADMIN=openlegacy
OL_PASSWORD=olpassword

OLCODE_ADMIN=openlegacy
OLCODE_PASSWORD=olpassword
```

> 💡 **Tip:** You can also customize the admin username and password in the same file.

### Starting the Services

Once you've configured your license, you can start services in two ways:

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

Start all services including Hub Integration and PostgreSQL:

```bash
./apps.sh start --all
```

Or using docker-compose directly:

```bash
docker-compose --profile all up -d
```

> 💡 **Note:** Hub Enterprise requires additional resources. Use `--all` only if you need enterprise features.

### Accessing the Applications

Open your browser and visit:

- **🏠 Homepage:** http://localhost:8080
- **💻 OL Terminal:** http://localhost:8081
- **⚡ OL Code:** http://localhost:8082
- **🗄️ SQOL:** http://localhost:8083

If you started with `--all`:
- **🏢 Hub Integration:** http://localhost:8084

## 🛠️ Managing Services

### Using the Helper Script

The `apps.sh` script provides convenient commands:

```bash
./apps.sh start           # Start community apps only
./apps.sh start --all     # Start all apps including Hub Enterprise
./apps.sh stop            # Stop all running services
./apps.sh stop --all      # Stop all services including Hub
./apps.sh restart         # Restart services
./apps.sh restart --all   # Restart all services including Hub
./apps.sh logs            # View logs (follow mode)
./apps.sh logs --all      # View logs including Hub
./apps.sh status          # Show service status
./apps.sh status --all    # Show all services including Hub
./apps.sh pull            # Pull latest images
./apps.sh pull --all      # Pull all images including Hub
```

> 💡 **Tip:** Add `--all` to any command to include Hub Enterprise and PostgreSQL services.

### Using Docker Compose Directly

```bash
# Community apps only
docker-compose up -d              # Start services in background
docker-compose down               # Stop and remove containers
docker-compose ps                 # List running services
docker-compose logs -f            # View logs
docker-compose restart            # Restart services

# All apps including Hub Enterprise
docker-compose --profile all up -d       # Start all services
docker-compose --profile all down        # Stop all services
docker-compose --profile all ps          # List all services
docker-compose --profile all logs -f     # View all logs
```

## 💾 Data Persistence

Application data is stored in two ways:

### Community Apps - Local Directories (Version-Controllable)
Configuration files are stored in local directories that you can edit directly:
- `./.ol-terminal/` - OL Terminal configurations and data
- `./.olcode/` - OL Code projects and settings
- `./.sqol/` - SQOL connections and queries

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

**To delete all data including Hub:**
```bash
docker-compose --profile all down -v  # ⚠️ This deletes PostgreSQL data!
rm -rf .ol-terminal .olcode .sqol     # Remove local configurations
```

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

If ports 8080-8083 are already in use, you can modify the ports in `docker-compose.yml`:

```yaml
ports:
  - "NEW_PORT:8080"  # Change NEW_PORT to your desired port
```

### Container Already Exists

If you previously ran the services with `docker run`, remove the old containers:

```bash
docker rm -f ol-terminal ol-code sqol ol-homepage ol-hub-light hub-postgres
```

Then start with docker-compose:

```bash
./apps.sh start --all
```

### Hub Enterprise Connection Issues

If Hub Enterprise fails to start or connect to the database:

1. Check if PostgreSQL is running:
```bash
docker ps | grep hub-postgres
```

2. Check Hub logs for errors:
```bash
docker logs ol-hub-light
```

3. Restart Hub services:
```bash
./apps.sh restart --all
```

## 📝 Configuration Files

- **`docker-compose.yml`** - Service definitions and configuration
- **`config.env`** - Environment variables (license, credentials)
- **`apps.sh`** - Helper script for managing services
- **`index.html`** - Homepage template
- **`.ol-terminal/`** - OL Terminal configuration directory (created on first run)
- **`.olcode/`** - OL Code configuration directory (created on first run)
- **`.sqol/`** - SQOL configuration directory (created on first run)

### Pre-configuring Apps

You can pre-configure apps by creating these directories before first run. For example, to pre-configure SQOL with database connections:

1. Create `.sqol` directory
2. Add `connections.json` with your database connections
3. Add `application.yaml` with your settings
4. Start the services with `./apps.sh start`

SQOL will use your pre-configured connections immediately!

### Inter-Container Communication

Containers in Docker Compose can communicate with each other using **service names** as hostnames. This is important when apps need to connect to each other.

**Important:** When referencing other containers from within a container, use:
- **Service name**: Use the exact name from `docker-compose.yml` (e.g., `ol-hub-light`)
- **Internal port**: `8080` (not the host-exposed ports like 8084)

For example, in `.sqol/application.yaml`:
```yaml
generalSettings:
  hubUrl: http://ol-hub-light:8080   # ✅ Correct - uses service name and internal port
  # NOT: http://localhost:8084        # ❌ Wrong - localhost refers to the container itself
```

**Port Mapping Summary:**
| From | To | URL |
|------|-----|-----|
| Your browser | OL Terminal | `http://localhost:8081` |
| Your browser | OL Code | `http://localhost:8082` |
| Your browser | SQOL | `http://localhost:8083` |
| Your browser | Hub Integration | `http://localhost:8084` |
| SQOL container | Hub container | `http://ol-hub-light:8080` |
| OL Code container | Hub container | `http://ol-hub-light:8080` |
| OL Terminal container | Hub container | `http://ol-hub-light:8080` |

**Other service names you can use:**
- `ol-terminal` or `http://ol-terminal:8080`
- `ol-code` or `http://ol-code:8080`
- `sqol` or `http://sqol:8080`
- `ol-hub-light` or `http://ol-hub-light:8080`
- `hub-postgres` or `postgresql://hub-postgres:5432`

**Troubleshooting DNS issues:**
If you get "UnknownHostException" or DNS resolution errors:
1. Verify all containers are running: `docker ps`
2. Check they're on the same network: `docker network inspect apps_default`
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

When running with `--all`, Hub Integration provides:
- **Automatic API Generation** - Transform legacy systems into modern REST APIs
- **Legacy System Analysis** - Analyze and optimize mainframe processes
- **Modernization Planning** - Create strategic modernization roadmaps with Hub Planner
- **Centralized Security** - Enterprise-grade security and access control
- **ETL & CDC** - Extract, Transform, Load and Change Data Capture workflows

Learn more at: https://community.openlegacy.com/hub

## ❓ Need Help?

If you encounter issues:
1. Check the logs: `./apps.sh logs`
2. Verify your license is correctly configured in `config.env`
3. Ensure Docker is running and up to date
4. Visit the [OpenLegacy Community](https://community.openlegacy.com/) for support

