#! /bin/bash
#original https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/elixir/elixir_healthcheck.sh

cd "$HOME" || exit

CONTAINER_ID=$(docker ps -aqf "name=ev")
LINES=20

while true
do
      echo -e "Check elixir validator logs \n"
      if docker logs --tail $LINES $CONTAINER_ID 2>&1 | grep -c "Connection closed error"; then
          echo "Connection closed error found in logs. Restarting container..."
          docker restart $CONTAINER_ID
          echo "Container restarted."
      else
          echo "No connection closed errors found in logs."
      fi

      date=$(date +"%H:%M")
      echo "Last Update: ${date}"
      printf "Sleep 15 minutes\n"
      sleep 15m
done