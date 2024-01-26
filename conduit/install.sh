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

function env_zora {
  tee <<EOF >/dev/null $HOME/conduit_node/networks/zora-mainnet-0/.env
OP_GETH_SEQUENCER_HTTP=https://rpc-zora-mainnet-0.t.conduit.xyz
OP_NODE_P2P_BOOTNODES=enode://9d221b41d61cb40162ae573b5ba7063c9535b5088ddc06f87099c461e7969068a54d93cdbd3ab119885481c7aec68f81500b400f36ac1bfef11efa116c1a2c1b@35.230.23.214:9222?discport=30301,enode://d25ce99435982b04d60c4b41ba256b84b888626db7bee45a9419382300fbe907359ae5ef250346785bff8d3b9d07cd3e017a27e2ee3cfda3bcbb0ba762ac9674@bootnode.conduit.xyz:0?discport=30301,enode://2d4e7e9d48f4dd4efe9342706dd1b0024681bd4c3300d021f86fc75eab7865d4e0cbec6fbc883f011cfd6a57423e7e2f6e104baad2b744c3cafaec6bc7dc92c1@34.65.43.171:0?discport=30305,enode://9d7a3efefe442351217e73b3a593bcb8efffb55b4807699972145324eab5e6b382152f8d24f6301baebbfb5ecd4127bd3faab2842c04cd432bdf50ba092f6645@34.65.109.126:0?discport=30305
OP_NODE_P2P_STATIC=/ip4/35.230.23.214/tcp/9222/p2p/16Uiu2HAmPENXJ1a1SFj7tSrwuvTM2dXAAKsKjPobXmjds9U76XUB
EOF
}

function source_configure_conduit {
  #check if conduit is already installed
  if [ -d "$HOME/conduit_node" ]; then
    echo -e "${GREEN}Conduit is already installed${NORMAL}"
    echo -e "${GREEN}Updating Conduit${NORMAL}"
    CONDUIT_NETWORK=zora-mainnet-0 docker compose -f $HOME/conduit_node/docker-compose.yml down
    cd $HOME/conduit_node
    git pull
    
  else
    git clone https://github.com/conduitxyz/node.git $HOME/conduit_node
    cd $HOME/conduit_node
  fi
    ./download-config.py zora-mainnet-0
    export CONDUIT_NETWORK=zora-mainnet-0
    cp .env.example .env
    seds
    env_zora
    CONDUIT_NETWORK=zora-mainnet-0 docker compose -f $HOME/conduit_node/docker-compose.yml up -d
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