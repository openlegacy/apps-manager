# OpenLegacy Tools - Docker Compose

A Docker Compose setup for running OpenLegacy development tools locally.

## 📦 What's Included

This setup runs four services:

- **Homepage** (port 8080) - Landing page with links to all tools
- **OL Terminal** (port 8081) - Terminal-based OpenLegacy development environment
- **OL Code** (port 8082) - Code editor and development tools
- **SQOL** (port 8083) - SQL and data management interface

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

Once you've configured your license, start all services:

```bash
./apps.sh start
```

Or using docker-compose directly:

```bash
docker-compose up -d
```

### Accessing the Applications

Open your browser and visit:

- **🏠 Homepage:** http://localhost:8080
- **💻 OL Terminal:** http://localhost:8081
- **⚡ OL Code:** http://localhost:8082
- **🗄️ SQOL:** http://localhost:8083

## 🛠️ Managing Services

### Using the Helper Script

The `apps.sh` script provides convenient commands:

```bash
./apps.sh start    # Start all services
./apps.sh stop     # Stop all services
./apps.sh restart  # Restart all services
./apps.sh logs     # View logs (follow mode)
./apps.sh status   # Show service status
./apps.sh pull     # Pull latest images
```

### Using Docker Compose Directly

```bash
docker-compose up -d        # Start services in background
docker-compose down         # Stop and remove containers
docker-compose ps           # List running services
docker-compose logs -f      # View logs
docker-compose restart      # Restart services
```

## 💾 Data Persistence

All application data is stored in named Docker volumes:
- `apps_ol-terminal-data`
- `apps_ol-code-data`
- `apps_sqol-data`

Your data persists across container restarts and system reboots. Data is only deleted if you explicitly run:

```bash
docker-compose down -v  # ⚠️ This deletes all volumes!
```

## 🔧 Troubleshooting

### License Error

If you see license-related errors, make sure you:
1. Copied the correct license from your [Community Profile](https://community.openlegacy.com/)
2. Updated `config.env` with your license
3. Restarted the services after updating the license

### Permission Errors

All services run as root (user 0:0) to avoid permission issues with volumes. If you still encounter permission errors, try:

```bash
docker-compose down
docker volume rm apps_ol-terminal-data apps_ol-code-data apps_sqol-data
docker-compose up -d
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
docker rm -f ol-terminal ol-code sqol ol-homepage
```

Then start with docker-compose:

```bash
./apps.sh start
```

## 📝 Configuration Files

- **`docker-compose.yml`** - Service definitions and configuration
- **`config.env`** - Environment variables (license, credentials)
- **`apps.sh`** - Helper script for managing services
- **`index.html`** - Homepage template

## 🔄 Updating Images

To pull the latest versions of the OpenLegacy tools:

```bash
./apps.sh pull
docker-compose up -d
```

## 🔐 Security Notes

- The `config.env` file contains sensitive information (license and passwords)
- **Do not commit `config.env` to version control**
- Consider adding `config.env` to your `.gitignore` file
- Change default passwords for production use

## 📚 Additional Resources

- [OpenLegacy Community](https://community.openlegacy.com/)
- [OpenLegacy Documentation](https://docs.openlegacy.com/)

## ❓ Need Help?

If you encounter issues:
1. Check the logs: `./apps.sh logs`
2. Verify your license is correctly configured in `config.env`
3. Ensure Docker is running and up to date
4. Visit the [OpenLegacy Community](https://community.openlegacy.com/) for support

