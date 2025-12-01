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
WITH_AI=false
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
    WITH_AI=true
    PROFILE_ARG="--profile all-ai"
    OL_HUB_IMAGE="openlegacy/hub-enterprise-light:ai"
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
    # Skip prompting if API key is already set
    if [ -n "$OL_HUB_API_KEY" ]; then
      return
    fi
    
    # Show current API key (should be empty at this point)
    echo "Current OL_HUB_API_KEY: (not set)"
    echo ""
    echo "Note: If this is your first execution, you can skip this step by pressing Enter."
    echo "      After the services start, go to Hub URL at http://localhost:8080 to get an API key,"
    echo "      then stop and start the apps.sh script again."
    echo ""
    echo -n "Please enter your Hub API Key (press Enter to skip on first execution): "
    read -r new_api_key
    
    # Use new value if provided, otherwise keep current
    if [ -n "$new_api_key" ]; then
      OL_HUB_API_KEY="$new_api_key"
      export OL_HUB_API_KEY
      # Always save to config.env when a new value is provided
      save_hub_api_key_to_config
    else
      echo "Skipping Hub API Key setup. Remember to get your API key from http://localhost:8080 and restart the script."
    fi
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
    echo "Get your Community License from: http://community.openlegacy.com"
    echo -n "Please enter your Community License: "
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

# Function to save OL_LICENSE to config.env
save_license_to_config() {
  if [ -f config.env ] && [ -n "$OL_LICENSE" ]; then
    # Create a temporary file for the update
    local temp_file=$(mktemp 2>/dev/null || echo config.env.tmp)
    
    # Check if OL_LICENSE already exists in config.env
    if grep -q "^OL_LICENSE=" config.env; then
      # Update existing line - use awk for more reliable handling of special characters
      awk -v new_license="$OL_LICENSE" '/^OL_LICENSE=/ { print "OL_LICENSE=" new_license; next } { print }' config.env > "$temp_file"
    else
      # Add new line at the beginning of the file
      echo "OL_LICENSE=$OL_LICENSE" > "$temp_file"
      cat config.env >> "$temp_file"
    fi
    
    # Replace original file with updated version
    mv "$temp_file" config.env
    echo "Updated OL_LICENSE in config.env"
  fi
}

# Function to prompt for OL_LICENSE if needed
prompt_license() {
  if [ "$WITH_HUB" = true ]; then
    if [ -z "$OL_LICENSE" ]; then
      echo "OL_LICENSE is not set."
      echo -n "Please enter your OpenLegacy License: "
      read -r new_license
      if [ -n "$new_license" ]; then
        OL_LICENSE="$new_license"
        export OL_LICENSE
        save_license_to_config
      else
        echo "Error: OL_LICENSE cannot be empty when using --all or --all-ai"
        exit 1
      fi
    fi
  fi
}

# Function to save OL_AI_API_KEY to config.env
save_ai_api_key_to_config() {
  if [ -f config.env ] && [ -n "$OL_AI_API_KEY" ]; then
    # Create a temporary file for the update
    local temp_file=$(mktemp 2>/dev/null || echo config.env.tmp)
    
    # Check if OL_AI_API_KEY already exists in config.env
    if grep -q "^OL_AI_API_KEY=" config.env; then
      # Update existing line - use awk for more reliable handling of special characters
      awk -v new_key="$OL_AI_API_KEY" '/^OL_AI_API_KEY=/ { print "OL_AI_API_KEY=" new_key; next } { print }' config.env > "$temp_file"
    else
      # Try to place it in the AI Configuration section after OL_AI_MODEL_NAME
      if grep -q "^OL_AI_MODEL_NAME=" config.env; then
        awk -v new_key="$OL_AI_API_KEY" '/^OL_AI_MODEL_NAME=/ { print; print "OL_AI_API_KEY=" new_key; next } { print }' config.env > "$temp_file"
      # Fallback: add after OL_TOOL_LICENSE if it exists
      elif grep -q "^OL_TOOL_LICENSE=" config.env; then
        awk -v new_key="$OL_AI_API_KEY" '/^OL_TOOL_LICENSE=/ { print; print "OL_AI_API_KEY=" new_key; next } { print }' config.env > "$temp_file"
      # Fallback: add after OL_HUB_API_KEY if it exists
      elif grep -q "^OL_HUB_API_KEY=" config.env; then
        awk -v new_key="$OL_AI_API_KEY" '/^OL_HUB_API_KEY=/ { print; print "OL_AI_API_KEY=" new_key; next } { print }' config.env > "$temp_file"
      else
        echo "OL_AI_API_KEY=$OL_AI_API_KEY" > "$temp_file"
        cat config.env >> "$temp_file"
      fi
    fi
    
    # Replace original file with updated version
    mv "$temp_file" config.env
    echo "Updated OL_AI_API_KEY in config.env"
  fi
}

# Function to prompt for OL_AI_API_KEY if needed
prompt_ai_api_key() {
  if [ "$WITH_AI" = true ]; then
    # Only prompt if OL_AI_API_KEY is empty
    if [ -z "$OL_AI_API_KEY" ]; then
      echo "OL_AI_API_KEY is not set."
      echo -n "Please enter your OpenAI API Key: "
      read -r new_api_key
      if [ -n "$new_api_key" ]; then
        OL_AI_API_KEY="$new_api_key"
        export OL_AI_API_KEY
        save_ai_api_key_to_config
      else
        echo "Error: OL_AI_API_KEY cannot be empty when using --all-ai"
        exit 1
      fi
    fi
  fi
}

# Function to replace ${OL_HUB_API_KEY:} in application.yaml and app-config.json files
replace_hub_api_keys() {
  if [ -z "$OL_HUB_API_KEY" ]; then
    if [ "$WITH_HUB" = false ]; then
      echo "Note: OL_HUB_API_KEY is not set. Skipping hub API key replacement (not required for core services)."
    else
      echo "Warning: OL_HUB_API_KEY is not set. Skipping hub API key replacement."
    fi
    return
  fi
  
  echo "Replacing \${OL_HUB_API_KEY:} and existing API key values in application.yaml and app-config.json files..."
  # Process application.yaml files
  find . -mindepth 2 -name "application.yaml" -type f | while read -r yaml_file; do
    if [ -f "$yaml_file" ]; then
      local updated=false
      # Replace ${OL_HUB_API_KEY:} pattern
      if grep -q '\${OL_HUB_API_KEY:}' "$yaml_file"; then
        # Use awk to safely handle special characters in the API key
        awk -v api_key="$OL_HUB_API_KEY" '{ gsub(/\$\{OL_HUB_API_KEY:\}/, api_key); print }' "$yaml_file" > "${yaml_file}.tmp" && mv "${yaml_file}.tmp" "$yaml_file"
        updated=true
      fi
      # Also replace any existing API key values (handles various YAML formats)
      # Pattern: hubApiKey: value or hub-api-key: value (replace value part, but skip if value is empty)
      if grep -qE '(hubApiKey|hub-api-key):' "$yaml_file"; then
        # Replace the value after the colon, but only if it's not empty (contains at least one non-whitespace character)
        # Use awk to safely handle special characters in the API key
        awk -v api_key="$OL_HUB_API_KEY" '
          /^hubApiKey:/ || /^hub-api-key:/ {
            # Extract the key name (everything before the colon)
            if (/^hubApiKey:/) {
              key_name = "hubApiKey"
            } else {
              key_name = "hub-api-key"
            }
            # Remove any trailing comment
            gsub(/#.*$/, "", $0)
            # Replace everything after the key and colon with the new API key
            print key_name ": " api_key
            next
          }
          { print }
        ' "$yaml_file" > "${yaml_file}.tmp2" && mv "${yaml_file}.tmp2" "$yaml_file"
        updated=true
      fi
      if [ "$updated" = true ]; then
        echo "  Updated: $yaml_file"
      fi
    fi
  done
  
  # Process app-config.json files
  find . -mindepth 2 \( -name "app-config.json" -o -name "appconfig.json" \) -type f | while read -r json_file; do
    if [ -f "$json_file" ]; then
      local updated=false
      # Replace ${OL_HUB_API_KEY:} pattern
      if grep -q '\${OL_HUB_API_KEY:}' "$json_file"; then
        # Use awk to safely handle special characters in the API key
        awk -v api_key="$OL_HUB_API_KEY" '{ gsub(/\$\{OL_HUB_API_KEY:\}/, api_key); print }' "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
        updated=true
      fi
      # Also replace any existing API key values in JSON format
      # Pattern: "apiKey": "any-value" (replace the value part, but skip if value is empty string)
      if grep -qE '"apiKey"\s*:\s*"[^"]+"' "$json_file"; then
        # Replace the value between quotes after "apiKey", but only if it's not an empty string
        # Use awk to safely handle special characters in the API key
        awk -v api_key="$OL_HUB_API_KEY" '
          /"apiKey"[[:space:]]*:[[:space:]]*"[^"]+"/ {
            # Replace the value part while preserving JSON structure
            gsub(/"apiKey"[[:space:]]*:[[:space:]]*"[^"]+"/, "\"apiKey\": \"" api_key "\"")
          }
          { print }
        ' "$json_file" > "${json_file}.tmp2" && mv "${json_file}.tmp2" "$json_file"
        updated=true
      fi
      if [ "$updated" = true ]; then
        echo "  Updated: $json_file"
      fi
    fi
  done
}

# Function to replace ${OL_AI_API_KEY:} in application.yaml files
replace_ai_api_keys() {
  if [ -z "$OL_AI_API_KEY" ]; then
    if [ "$WITH_AI" = false ]; then
      echo "Note: OL_AI_API_KEY is not set. Skipping AI API key replacement (not required for core services)."
    else
      echo "Warning: OL_AI_API_KEY is not set. Skipping AI API key replacement."
    fi
    return
  fi
  
  echo "Replacing \${OL_AI_API_KEY:} in application.yaml files..."
  find . -mindepth 2 -name "application.yaml" -type f | while read -r yaml_file; do
    if [ -f "$yaml_file" ]; then
      local updated=false
      # Replace ${OL_AI_API_KEY:} pattern
      if grep -q '\${OL_AI_API_KEY:}' "$yaml_file"; then
        # Use sed to replace the pattern, escaping special characters
        sed "s|\${OL_AI_API_KEY:}|$OL_AI_API_KEY|g" "$yaml_file" > "${yaml_file}.tmp" && mv "${yaml_file}.tmp" "$yaml_file"
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
    prompt_license
    prompt_tool_license
    prompt_hub_api_key
    prompt_ai_api_key
    replace_hub_api_keys
    replace_ai_api_keys
    echo ""
    echo "Note: For DB2 database connections, ensure db2jcc_license_cisuz.jar is placed in .sqol/jars directory"
    echo ""
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
    echo ""
    echo "Launching browser at http://localhost..."
    # Cross-platform browser launch
    if command -v start >/dev/null 2>&1; then
      # Windows (Git Bash or cmd)
      start http://localhost 2>/dev/null || true
    elif command -v xdg-open >/dev/null 2>&1; then
      # Linux
      xdg-open http://localhost 2>/dev/null || true
    elif command -v open >/dev/null 2>&1; then
      # macOS
      open http://localhost 2>/dev/null || true
    else
      echo "Could not automatically launch browser. Please open http://localhost manually."
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

