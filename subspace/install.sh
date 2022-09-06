#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function read_nodename {
  if [ ! $SUBSPACE_NODENAME ]; then
  echo -e "Enter your node name(random name for telemetry)"
  line_1
  read SUBSPACE_NODENAME
  fi
}

function read_wallet {
  if [ ! $WALLET_ADDRESS ]; then
  echo -e "Enter your polkadot.js extension address"
  line_1
  read WALLET_ADDRESS
  fi
}

# function source_git {
#   git clone https://github.com/subspace/subspace
#   cd $HOME/subspace
#   git fetch
#   git checkout gemini-2a-2022-sep-06
# }
#
# function build_image_node {
#   cd $HOME/subspace
#   docker build -t subspacelabs/subspace-node:gemini-2a-2022-sep-06 -f $HOME/subspace/Dockerfile-node .
# }
#
# function build_image_farmer {
#   cd $HOME/subspace
#   docker build -t subspacelabs/subspace-farmer:gemini-2a-2022-sep-06 -f $HOME/subspace/Dockerfile-farmer .
# }

function eof_docker_compose {
  mkdir -p $HOME/subspace_docker/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:gemini-2a-2022-sep-06
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:30333:30333"
      restart: unless-stopped
      command: [
        "--chain", "gemini-1",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--pruning", "1024",
        "--keep-blocks", "1024",
        "--port", "30333",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--validator",
        "--name", "$SUBSPACE_NODENAME",
        "--telemetry-url", "wss://telemetry.subspace.network/submit 0",
        "--telemetry-url", "wss://telemetry.postcapitalist.io/submit 0"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5

    farmer:
      depends_on:
        - node
      image: ghcr.io/subspace/farmer:gemini-2a-2022-sep-06
      volumes:
        - farmer-data:/var/subspace:rw
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--ws-server-listen-addr", "0.0.0.0:9955",
        "--reward-address", "$WALLET_ADDRESS",
        "--plot-size", "100G"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart node \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart farmer \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 node \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов фармера выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 farmer \n ${NORMAL}"
}

function delete_old {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml down &>/dev/null
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node &>/dev/null
}

colors
line_1
logo
line_2
read_nodename
line_2
read_wallet
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
delete_old
line_1
# echo -e "Скачиваем репозиторий"
# source_git
# line_1
# echo -e "Билдим образ ноды"
# build_image_node
# line_1
# echo -e "Билдим образ фармера"
# build_image_farmer
# line_1
echo -e "Создаем docker-compose файл"
line_1
eof_docker_compose
line_1
echo -e "Запускаем docker контейнеры для node and farmer Subspace"
line_1
docker_compose_up
line_2
echo_info
line_2
