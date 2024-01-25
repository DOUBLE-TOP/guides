#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function set_rpc {
  #default is https://ethereum.publicnode.com
  read -p "Enter your ETHEREUM RPC in https:// format" OP_NODE_L1_ETH_RPC
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

function source_configure_conduit {
  #check if conduit is already installed
  if [ -d "$HOME/node" ]; then
    echo -e "${GREEN}Conduit is already installed${NORMAL}"
    echo -e "${GREEN}Updating Conduit${NORMAL}"
    cd $HOME/conduit_node
    git pull
    export CONDUIT_NETWORK=zora-mainnet-0
    cp .env.example .env
    sed -i 's/OP_NODE_L1_ETH_RPC=.*/OP_NODE_L1_ETH_RPC='$OP_NODE_L1_ETH_RPC'/g' .env
    docker compose up -d
  else
    git clone https://github.com/conduitxyz/node.git $HOME/conduit_node
    cd $HOME/conduit_node
    export CONDUIT_NETWORK=zora-mainnet-0
    cp .env.example .env
    sed -i 's/OP_NODE_L1_ETH_RPC=.*/OP_NODE_L1_ETH_RPC='$OP_NODE_L1_ETH_RPC'/g' .env
    docker compose up -d
  fi
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