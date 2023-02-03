#!/bin/bash

function logo {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh)
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function main_tools {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
}

function docker {
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
}

function prepare {
  mkdir -p $HOME/sui
  cd $HOME/sui
  wget -O $HOME/sui/fullnode-template.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
  wget -O $HOME/sui/genesis.blob  https://github.com/MystenLabs/sui-genesis/raw/main/testnet/genesis.blob
  IMAGE="mysten/sui-node:6fa859ba7590deb6db72aad42ca689efd69d5329"
  wget -O $HOME/sui/docker-compose.yaml https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
  sed -i.bak "s|image:.*|image: $IMAGE|" $HOME/sui/docker-compose.yaml
}

function run_docker {
  docker-compose -f ${HOME}/sui/docker-compose.yaml pull
  docker-compose -f ${HOME}/sui/docker-compose.yaml up -d
}

function stop_docker {
  docker-compose -f ${HOME}/sui/docker-compose.yaml down
}

function repalce_image {
IMAGE="mysten/sui-node:336ffb7803672e889444a1b411877986637ca345"
sed -i.bak "s|image:.*|image: $IMAGE|" $HOME/sui/docker-compose.yaml
}

function peers {
sudo tee -a $HOME/sui/fullnode-template.yaml  >/dev/null <<EOF

p2p-config:
  seed-peers:
    - address: "/ip4/65.109.32.171/udp/8084"
    - address: "/ip4/65.108.44.149/udp/8084"
    - address: "/ip4/95.214.54.28/udp/8080"
    - address: "/ip4/136.243.40.38/udp/8080"
    - address: "/ip4/84.46.255.11/udp/8084"
EOF
}

colors
line
logo
line
echo "updating docker image"
line
stop_docker
repalce_image
#peers
line
echo "starting docker-compose"
line
run_docker
line
echo "update complete, check logs by command:"
echo "docker-compose -f $HOME/sui/docker-compose.yaml logs -f --tail=100"
