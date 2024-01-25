#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools|main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function set_rpc {
  #default is https://ethereum.publicnode.com
  read -p "Enter your ETHEREUM RPC in https:// format: " OP_NODE_L1_ETH_RPC
    if [ -z "$OP_NODE_L1_ETH_RPC" ]; then
    echo "Please enter your ETHEREUM RPC"
    exit 1
    fi
    echo "Your ETHEREUM RPC: $OP_NODE_L1_ETH_RPC"
    sleep 1
}

function install_docker {
  if [ -x "$(command -v 'docker compose')" ]; then
      echo -e "${GREEN}Docker is already installed${NORMAL}"
  else
      echo -e "${GREEN}Installing Docker${NORMAL}"
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker $USER
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo rm get-docker.sh
  fi
}

function seds {
  file=$HOME/conduit_node/docker-compose.yml
  sed -i 's|- .*8545:8545|- 1545:8545|g' $file
  sed -i 's|- .*8546:8546|- 1546:8546|g' $file
  sed -i 's|- .*30303:30303|- 10303:30303|g' $file
  sed -i 's|- .*6060:6060|- 17301:6060|g' $file
  sed -i 's|- .*7545:8545|- 17545:8545|g' $file
  sed -i 's|- .*9222:9222|- 19222:9222|g' $file
  sed -i 's|- .*7300:7300|- 17300:7300|g' $file
  sed -i 's|- .*6060:6060|- 16060:6060|g' $file
  sed -i 's|OP_NODE_L1_ETH_RPC=.*|OP_NODE_L1_ETH_RPC='$OP_NODE_L1_ETH_RPC'|g' .env
}

function source_configure_conduit {
  #check if conduit is already installed
  if [ -d "$HOME/conduit_node" ]; then
    echo -e "${GREEN}Conduit is already installed${NORMAL}"
    echo -e "${GREEN}Updating Conduit${NORMAL}"
    cd $HOME/conduit_node
  else
    git clone https://github.com/conduitxyz/node.git $HOME/conduit_node
    cd $HOME/conduit_node
  fi
    ./download-config.py zora-mainnet-0
    export CONDUIT_NETWORK=zora-mainnet-0
    cp .env.example .env
    seds
    docker compose up -d
}

function main {
  colors
  logo
  line
  set_rpc
  line
  install_docker
  line
  source_configure_conduit
  line
}

main