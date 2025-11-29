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

# Check if --all or --all-ai flag is present
WITH_HUB=false
PROFILE_ARG=""
OL_HUB_IMAGE=""
for arg in "$@"; do
  if [ "$arg" = "--all" ]; then
    WITH_HUB=true
    PROFILE_ARG="--profile all"
    OL_HUB_IMAGE="openlegacy/hub-enterprise-light:latest"
    break
  elif [ "$arg" = "--all-ai" ]; then
    WITH_HUB=true
    PROFILE_ARG="--profile all-ai"
    OL_HUB_IMAGE="lighthub-ai:latest"
    break
  fi
done

# Export OL_HUB_IMAGE if set
if [ -n "$OL_HUB_IMAGE" ]; then
  export OL_HUB_IMAGE
fi

# Function to save OL_HUB_API_KEY to config.env
save_hub_api_key_to_config() {
  if [ -f config.env ] && [ -n "$OL_HUB_API_KEY" ]; then
    # Create a temporary file for the update
    local temp_file=$(mktemp 2>/dev/null || echo config.env.tmp)
    
    # Check if OL_HUB_API_KEY already exists in config.env
    if grep -q "^OL_HUB_API_KEY=" config.env; then
      # Update existing line - use awk for more reliable handling of special characters
      awk -v new_key="$OL_HUB_API_KEY" '/^OL_HUB_API_KEY=/ { print "OL_HUB_API_KEY=" new_key; next } { print }' config.env > "$temp_file"
    else
      # Add new line at the beginning of the file
      echo "OL_HUB_API_KEY=$OL_HUB_API_KEY" > "$temp_file"
      cat config.env >> "$temp_file"
    fi
    
    # Replace original file with updated version
    mv "$temp_file" config.env
    echo "Updated OL_HUB_API_KEY in config.env"
  fi
}

# Function to prompt for OL_HUB_API_KEY if needed
prompt_hub_api_key() {
  if [ "$WITH_HUB" = true ]; then
    # Show current API key
    if [ -n "$OL_HUB_API_KEY" ]; then
      echo "Current OL_HUB_API_KEY: $OL_HUB_API_KEY"
    else
      echo "Current OL_HUB_API_KEY: (not set)"
    fi
    
    echo -n "Please enter your Hub API Key (press Enter to keep current): "
    read -r new_api_key
    
    # Use new value if provided, otherwise keep current
    if [ -n "$new_api_key" ]; then
      OL_HUB_API_KEY="$new_api_key"
      export OL_HUB_API_KEY
    elif [ -z "$OL_HUB_API_KEY" ]; then
      echo "Error: OL_HUB_API_KEY cannot be empty when using --all or --all-ai"
      exit 1
    fi
    
    # Always save to config.env (whether new or existing value)
    save_hub_api_key_to_config
  fi
}

# Function to save OL_TOOL_LICENSE to config.env
save_tool_license_to_config() {
  if [ -f config.env ] && [ -n "$OL_TOOL_LICENSE" ]; then
    # Create a temporary file for the update
    local temp_file=$(mktemp 2>/dev/null || echo config.env.tmp)
    
    # Check if OL_TOOL_LICENSE already exists in config.env
    if grep -q "^OL_TOOL_LICENSE=" config.env; then
      # Update existing line - use awk for more reliable handling of special characters
      awk -v new_license="$OL_TOOL_LICENSE" '/^OL_TOOL_LICENSE=/ { print "OL_TOOL_LICENSE=" new_license; next } { print }' config.env > "$temp_file"
    else
      # Add new line after OL_HUB_API_KEY if it exists, otherwise at the beginning
      if grep -q "^OL_HUB_API_KEY=" config.env; then
        awk -v new_license="$OL_TOOL_LICENSE" '/^OL_HUB_API_KEY=/ { print; print "OL_TOOL_LICENSE=" new_license; next } { print }' config.env > "$temp_file"
      else
        echo "OL_TOOL_LICENSE=$OL_TOOL_LICENSE" > "$temp_file"
        cat config.env >> "$temp_file"
      fi
    fi
    
    # Replace original file with updated version
    mv "$temp_file" config.env
    echo "Updated OL_TOOL_LICENSE in config.env"
  fi
}

# Function to prompt for OL_TOOL_LICENSE if needed
prompt_tool_license() {
  if [ -z "$OL_TOOL_LICENSE" ]; then
    echo "OL_TOOL_LICENSE is not set."
    echo -n "Please enter your Tool License: "
    read -r new_license
    if [ -n "$new_license" ]; then
      OL_TOOL_LICENSE="$new_license"
      export OL_TOOL_LICENSE
      save_tool_license_to_config
    else
      echo "Warning: OL_TOOL_LICENSE is empty. Some features may not work."
    fi
  fi
}

# Function to replace hubApiKey and hub-api-key in application.yaml files
replace_hub_api_keys() {
  if [ -z "$OL_HUB_API_KEY" ]; then
    if [ "$WITH_HUB" = false ]; then
      echo "Note: OL_HUB_API_KEY is not set. Skipping hubApiKey replacement (not required for core services)."
    else
      echo "Warning: OL_HUB_API_KEY is not set. Skipping hubApiKey replacement."
    fi
    return
  fi
  
  echo "Replacing hubApiKey and hub-api-key in application.yaml files..."
  find . -mindepth 2 -name "application.yaml" -type f | while read -r yaml_file; do
    if [ -f "$yaml_file" ]; then
      local updated=false
      # Replace hubApiKey (camelCase)
      if grep -q "hubApiKey:" "$yaml_file"; then
        sed "s|hubApiKey:.*|hubApiKey: $OL_HUB_API_KEY|" "$yaml_file" > "${yaml_file}.tmp" && mv "${yaml_file}.tmp" "$yaml_file"
        updated=true
      fi
      # Replace hub-api-key (kebab-case)
      if grep -q "hub-api-key:" "$yaml_file"; then
        sed "s|hub-api-key:.*|hub-api-key: $OL_HUB_API_KEY|" "$yaml_file" > "${yaml_file}.tmp" && mv "${yaml_file}.tmp" "$yaml_file"
        updated=true
      fi
      if [ "$updated" = true ]; then
        echo "  Updated: $yaml_file"
      fi
    fi
  done
}

case "$1" in
  start)
    prompt_tool_license
    prompt_hub_api_key
    replace_hub_api_keys
    echo "Starting OpenLegacy services..."
    if [ "$WITH_HUB" = true ]; then
      docker-compose $PROFILE_ARG up -d
    else
      docker-compose up -d
    fi
    echo "Services started!"
    echo ""
    echo "🏠 Homepage: http://localhost:80"
    echo ""
    echo "ol-terminal: http://localhost:8081"
    echo "ol-code: http://localhost:8082"
    echo "sqol: http://localhost:8083"
    if [ "$WITH_HUB" = true ]; then
      echo "hub-enterprise: http://localhost:8080"
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
    echo "Usage: $0 {start|stop|restart|logs|status|pull} [--all|--all-ai]"
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
    echo "  --all     - Include Hub Enterprise service with openlegacy/hub-enterprise-light:latest"
    echo "  --all-ai  - Include Hub Enterprise service with lighthub-ai:latest"
    echo ""
    echo "Examples:"
    echo "  $0 start         # Start core services"
    echo "  $0 start --all   # Start all services including Hub Enterprise"
    echo "  $0 start --all-ai # Start all services including Hub Enterprise AI"
    exit 1
    ;;
esac

