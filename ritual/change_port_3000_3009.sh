#!/bin/bash

CONTAINER_NAME="hello-world"
CONFIG_FILE="$HOME/infernet-container-starter/deploy/config.json"
CONFIG_FILE_OWN="$HOME/infernet-container-starter/projects/hello-world/container/config.json"

if docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Останавливаем контейнеры ритуала..."
  docker compose -f $HOME/infernet-container-starter/deploy/docker-compose.yaml down

  if docker ps --filter "name=^/${CONTAINER_NAME}$" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
    docker stop "$CONTAINER_NAME"
  fi
  docker rm "$CONTAINER_NAME"


  if [ -f "$CONFIG_FILE" ]; then
    sed -i 's/3000/3009/g' "$CONFIG_FILE"
    sed -i 's/3000/3009/g' "$CONFIG_FILE_OWN"
    echo "Порт изменен с 3000 на 3009 в файле $CONFIG_FILE."
    echo "Стартую Ритуал на 3009 порте."
    docker compose -f $HOME/infernet-container-starter/deploy/docker-compose.yaml up -d
  else
    echo "Config file not found: $CONFIG_FILE"
  fi
else
  echo "Ритуал контейнеры не найдены."
fi
