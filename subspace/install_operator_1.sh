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

function read_nodename {
  if [ ! $SUBSPACE_NODENAME ]; then
  echo -e "Enter your node name(random name for telemetry)"
  line_1
  read SUBSPACE_NODENAME
  fi
}

function domain_id {
  if [ ! $DOMAIN_ID ]; then
  echo -e "Enter your domain id"
  line_1
  read DOMAIN_ID
  fi
}

function get_vars {
  export CHAIN="gemini-3g"
  export RELEASE="gemini-3g-2023-nov-21"
}

function eof_docker_compose {
  mkdir -p $HOME/subspace_docker_operator/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker_operator/docker-compose.yml
  version: "3.7"
  services:
    operator:
      image: ghcr.io/subspace/node:$RELEASE
      volumes:
        - operator-data:/var/subspace:rw
      ports:
        - "0.0.0.0:42333:30333/udp"
        - "0.0.0.0:42333:30333/tcp"
        - "0.0.0.0:42433:30433/udp"
        - "0.0.0.0:42433:30433/tcp"
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

  volumes:
    operator-data:
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки оператора  subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска оператора subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки оператора subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml restart \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов оператора выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker_operator/docker-compose.yml logs -f --tail=100 \n ${NORMAL}"
}

colors
line_1
logo
line_2
read_nodename
# line_2
# domain_id
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_docker
get_vars
line_1
echo -e "Создаем docker-compose файл"
line_1
eof_docker_compose
line_1
echo -e "Запускаем docker контейнеры для оператора Subspace"
line_1
docker_compose_up
line_2
echo_info
line_2
