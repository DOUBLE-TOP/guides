#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function stop_delete {
  cd $HOME/subspace_docker/
  docker-compose down
  docker volume rm subspace_docker_farmer-data subspace_docker_node-data subspace_docker_subspace-farmer subspace_docker_subspace-node
}

colors
line
logo
line
stop_delete
line
echo -e "${GREEN}Ноду остановили, стораджи очистили. Ждем дальнейших новостей от команды${NORMAL}"
line
