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

function plot_size {
  if [ ! $PLOT_SIZE ]; then
  echo -e "Enter your plot size(default is 100G)"
  line_1
  read PLOT_SIZE
  fi
}

function get_vars {
  export CHAIN="gemini-3g"
  export RELEASE="gemini-3g-2023-dec-01"
}

function eof_docker_compose {
  mkdir -p $HOME/subspace_docker/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$RELEASE
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32333:30333/udp"
        - "0.0.0.0:32333:30333/tcp"
        - "0.0.0.0:32433:30433/udp"
        - "0.0.0.0:32433:30433/tcp"
      restart: unless-stopped
      command:
        [
          "--chain", "$CHAIN",
          "--base-path", "/var/subspace",
          "--blocks-pruning", "256",
          "--state-pruning", "archive-canonical",
          "--port", "30333",
          "--dsn-listen-on", "/ip4/0.0.0.0/udp/30433/quic-v1",
          "--dsn-listen-on", "/ip4/0.0.0.0/tcp/30433",
          "--rpc-cors", "all",
          "--rpc-methods", "unsafe",
          "--rpc-external",
          "--no-private-ipv4",
          "--validator",
          "--name", "$SUBSPACE_NODENAME",
          "--out-peers", "100"
        ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 60

    farmer:
      depends_on:
        node:
          condition: service_healthy
      image: ghcr.io/subspace/farmer:$RELEASE
      volumes:
        - farmer-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32533:30533/udp"
        - "0.0.0.0:32533:30533/tcp"
      restart: unless-stopped
      command:
        [
          "farm",
          "--node-rpc-url", "ws://node:9944",
          "--listen-on", "/ip4/0.0.0.0/udp/30533/quic-v1",
          "--listen-on", "/ip4/0.0.0.0/tcp/30533",
          "--reward-address", "$WALLET_ADDRESS",
          "path=/var/subspace,size=$PLOT_SIZE"
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
  docker-compose -f $HOME/subspace_docker/docker-compose.yml down -v &>/dev/null
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
plot_size
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
get_vars
delete_old
line_1
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
