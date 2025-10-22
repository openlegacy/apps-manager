#!/bin/bash

# OpenLegacy Docker Compose Management Script

# Load and export environment variables from config.env
if [ -f config.env ]; then
  echo "Loading environment variables from config.env..."
  set -a
  source config.env
  set +a
else
  echo "Warning: config.env not found!"
fi

case "$1" in
  start)
    echo "Starting OpenLegacy services..."
    docker-compose up -d
    echo "Services started!"
    echo ""
    echo "🏠 Homepage: http://localhost:8080"
    echo ""
    echo "ol-terminal: http://localhost:8081"
    echo "ol-code: http://localhost:8082"
    echo "sqol: http://localhost:8083"
    ;;
  stop)
    echo "Stopping OpenLegacy services..."
    docker-compose down
    echo "Services stopped!"
    ;;
  restart)
    echo "Restarting OpenLegacy services..."
    docker-compose restart
    echo "Services restarted!"
    ;;
  logs)
    docker-compose logs -f
    ;;
  status)
    docker-compose ps
    ;;
  pull)
    echo "Pulling latest images..."
    docker-compose pull
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|logs|status|pull}"
    echo ""
    echo "Commands:"
    echo "  start   - Start all services"
    echo "  stop    - Stop all services"
    echo "  restart - Restart all services"
    echo "  logs    - View logs (follow mode)"
    echo "  status  - Show service status"
    echo "  pull    - Pull latest images"
    exit 1
    ;;
esac

