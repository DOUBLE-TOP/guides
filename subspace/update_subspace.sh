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

function get_vars {
  export CHAIN="gemini-2a"
  export RELEASE="gemini-2a-2022-oct-06"
  export SUBSPACE_NODENAME=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-name" | awk -F\" '{print $4}')
  export WALLET_ADDRESS=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-reward-address" | awk -F\" '{print $4}')
  export PLOT_SIZE=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-plot-size" | awk -F\" '{print $4}')
}

function eof_docker_compose {
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$RELEASE
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:39333:30333"
      restart: unless-stopped
      command: [
        "--chain", "$CHAIN",
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
      image: ghcr.io/subspace/farmer:$RELEASE
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

function check_fork {
  sleep 30
  check_fork=`docker logs --tail 100  subspace_docker_node_1 2>&1 | grep "Node is running on non-canonical fork"`
  if [ -z "$check_fork" ]
  then
    echo -e "${GREEN}Нода не в форке - все ок${NORMAL}"
  else
    echo -e "${RED}Нода была в форке, выполняем сброс и перезапускаем${NORMAL}"
    cd $HOME/subspace_docker/
    docker-compose down
    docker volume rm subspace_docker_farmer-data subspace_docker_node-data subspace_docker_subspace-farmer subspace_docker_subspace-node
    docker-compose up -d
  fi
}

function check_verif {
  sleep 30
  check_verif=`docker logs --tail 100  subspace_docker_node_1 2>&1 | grep "Verification failed for block"`
  if [ -z "$check_verif" ]
  then
    echo -e "${GREEN}Ошибок верификации нет - все ок${NORMAL}"
  else
    echo -e "${RED}Есть ошибки верификации блоков, выполняем сброс и перезапускаем${NORMAL}"
    cd $HOME/subspace_docker/
    docker-compose down
    docker volume rm subspace_docker_farmer-data subspace_docker_node-data subspace_docker_subspace-farmer subspace_docker_subspace-node
    docker-compose up -d
  fi
}

function update_subspace {
  cd $HOME/subspace_docker/
  docker-compose down
  # docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node
  # docker volume rm subspace_docker_farmer-data subspace_docker_node-data
  # docker volume rm subspace_docker_farmer-data
  eof_docker_compose
  docker-compose pull
  docker-compose up -d
}

colors
line
logo
line
get_vars
update_subspace
line
check_fork
line
# check_verif
# line
echo -e "${GREEN}=== Обновление завершено ===${NORMAL}"
