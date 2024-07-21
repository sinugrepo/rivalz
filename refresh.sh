#!/bin/bash

# Restart all stopped containers using their short IDs
for short_id in $(docker ps -q -f status=exited); do
  echo "Restarting container $short_id"
  docker restart "$short_id"
done

# Wait a few seconds to ensure the containers are fully started
sleep 5

# Function to run rivalz in a container and restart on termination or error
run_rivalz_in_container() {
  local container_id=$1
  local container_name=$2

  while true; do
    echo "Executing 'rivalz run' in container $container_name"
    docker exec "$container_id" rivalz run > ${container_name}_stdout.log 2> ${container_name}_stderr.log
    if [ $? -ne 0 ]; then
      echo "rivalz run in container $container_name terminated with an error. Restarting command."
      docker exec "$container_id" rivalz run > ${container_name}_stdout.log 2> ${container_name}_stderr.log
      sleep 5 # Wait a few seconds to ensure the container is fully restarted
    else
      echo "rivalz run in container $container_name terminated normally. Exiting loop."
      break
    fi
  done
}

# Loop through all running containers and run rivalz
for short_id in $(docker ps -q); do
  container_name=$(docker inspect --format='{{.Name}}' $short_id | sed 's/^\/\///' | sed 's/\///g')
  run_rivalz_in_container "$short_id" "$container_name" &
done

echo "All commands executed."
