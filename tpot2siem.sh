#!/bin/bash

# Function to prompt for user input with default value
prompt() {
  local prompt_text=$1
  local default_value=$2
  local input

  read -p "$prompt_text [$default_value]: " input
  echo ${input:-$default_value}
}

# Prompt for SIEM details
SIEM_ADDRESS=$(prompt "Enter the SIEM Address" "your.siem.server")
DEST_PORT=$(prompt "Enter the destination port" "514")
PROTOCOL=$(prompt "Enter the protocol (tcp or udp)" "tcp")

# Path to T-Pot directories
TPOT_DIR="$HOME/tpotce"
LOGSTASH_DIR="$TPOT_DIR/logstash"
LOGSTASH_DOCKERFILE="$LOGSTASH_DIR/Dockerfile"
DOCKER_COMPOSE_FILE="$TPOT_DIR/docker-compose.yml"
LOGSTASH_CONF="$LOGSTASH_DIR/logstash.conf"

# Check if directories exist
if [ ! -d "$LOGSTASH_DIR" ]; then
  echo "Logstash directory not found: $LOGSTASH_DIR"
  exit 1
fi

if [ ! -f "$LOGSTASH_DOCKERFILE" ]; then
  echo "Logstash Dockerfile not found: $LOGSTASH_DOCKERFILE"
  exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
  echo "Docker Compose file not found: $DOCKER_COMPOSE_FILE"
  exit 1
fi

# Uncomment the Syslog plugin line in the Dockerfile
sed -i 's/^#\(.*logstash-plugin install logstash-output-syslog.*\)/\1/' $LOGSTASH_DOCKERFILE

# Build the Logstash Docker image
docker build -t custom-logstash-image $LOGSTASH_DIR

# Create the Logstash configuration file
cat <<EOF > $LOGSTASH_CONF
input {
  beats {
    port => 5044
  }
}

output {
  syslog {
    host => "$SIEM_ADDRESS"
    port => $DEST_PORT
    protocol => "$PROTOCOL"
  }
}
EOF

# Update the Docker Compose file to use the custom Logstash image and mount the configuration file
sed -i '/logstash:/,/[^[:space:]]/ {
  s|image:.*|image: custom-logstash-image|
  /volumes:/!b
  :a;/\(^[[:space:]]\+\)[^#]/s|.*|\1- ./logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf|
}' $DOCKER_COMPOSE_FILE

# Restart T-Pot
sudo systemctl stop tpot
sudo systemctl start tpot

echo "Logstash configuration completed and T-Pot restarted successfully."
