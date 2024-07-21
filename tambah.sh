#!/usr/bin/env bash

# Define variables for input
WALLET_ADDRESS=""
CPU_CORES="8"
RAM_SIZE="7"
DISK_TYPE="SSD"
DISK_SERIAL=""
DISK_SIZE="3000"


# Function to find the next container number
get_next_container_number() {
  local base_name="rivalz-docker-"
  local max_number=0

  # Get a list of all container names and extract numbers
  local container_names=$(sudo docker ps -a --format "{{.Names}}" | grep "^${base_name}[0-9]\+" | sed "s/${base_name}//")

  for name in $container_names; do
    if [[ $name =~ ^[0-9]+$ ]]; then
      if (( name > max_number )); then
        max_number=$name
      fi
    fi
  done

  # Increment the maximum number found
  echo $((max_number + 1))
}

# Get the next container number
NEXT_CONTAINER_NUMBER=$(get_next_container_number)
CONTAINER_NAME="rivalz-docker-$NEXT_CONTAINER_NUMBER"

# Use expect to automate the interactive prompts
expect <<EOF
set timeout -1

spawn sudo docker run -it --name $CONTAINER_NAME sinug/rivalz-docker-1:latest

expect "Enter wallet address (EVM):"
send "$WALLET_ADDRESS\r"

expect "Enter CPU cores number you want to use"
send "$CPU_CORES\r"

expect "Enter Ram size you want to use"
send "$RAM_SIZE\r"

expect "Select disk type you want to use:"
send "$DISK_TYPE\r"

expect "Select disk serial number you want to use (Enter if no option):"
send "$DISK_SERIAL\r"

expect "Enter Disk size of drive-scsi0 (SSD) you want to use"
send "$DISK_SIZE\r"

expect eof
EOF

echo "Started container with name $CONTAINER_NAME"
