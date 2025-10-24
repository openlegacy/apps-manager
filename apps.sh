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

# Check if --all flag is present
WITH_HUB=false
PROFILE_ARG=""
for arg in "$@"; do
  if [ "$arg" = "--all" ]; then
    WITH_HUB=true
    PROFILE_ARG="--profile all"
    break
  fi
done

case "$1" in
  start)
    echo "Starting OpenLegacy services..."
    if [ "$WITH_HUB" = true ]; then
      docker-compose $PROFILE_ARG up -d
    else
      docker-compose up -d
    fi
    echo "Services started!"
    echo ""
    echo "🏠 Homepage: http://localhost:8080"
    echo ""
    echo "ol-terminal: http://localhost:8081"
    echo "ol-code: http://localhost:8082"
    echo "sqol: http://localhost:8083"
    if [ "$WITH_HUB" = true ]; then
      echo "hub-enterprise: http://localhost:8084"
      echo "ol-termiq: http://localhost:8085"
    fi
    ;;
  stop)
    echo "Stopping OpenLegacy services..."
    docker-compose $PROFILE_ARG down
    echo "Services stopped!"
    ;;
  restart)
    echo "Restarting OpenLegacy services..."
    docker-compose $PROFILE_ARG restart
    echo "Services restarted!"
    ;;
  logs)
    docker-compose $PROFILE_ARG logs -f
    ;;
  status)
    docker-compose $PROFILE_ARG ps
    ;;
  pull)
    echo "Pulling latest images..."
    docker-compose $PROFILE_ARG pull
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|logs|status|pull} [--all]"
    echo ""
    echo "Commands:"
    echo "  start   - Start all services"
    echo "  stop    - Stop all services"
    echo "  restart - Restart all services"
    echo "  logs    - View logs (follow mode)"
    echo "  status  - Show service status"
    echo "  pull    - Pull latest images"
    echo ""
    echo "Options:"
    echo "  --all  - Include Hub Enterprise service (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 start        # Start core services"
    echo "  $0 start --all  # Start all services including Hub Enterprise"
    exit 1
    ;;
esac

