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

function output {
  echo -e "${YELLOW}$1${NORMAL}"
}

function output_error {
  echo -e "${RED}$1${NORMAL}"
}

function output_normal {
  echo -e "${GREEN}$1${NORMAL}"
}

function stop_service() {
    if [[ $(systemctl is-active $1) == "active" ]]; then
        sudo systemctl stop $1
        sudo systemctl disable $1
        rm -rf $HOME/.local/share/bevm/chains/bevm/db/full/
    fi
}

function migrate_data() {
    nodename=$(cat /etc/systemd/system/bevmd.service | grep -oP -- '--name="\K[^"]*')
    mkdir -p $HOME/.bevm/{data/chains/bevm/network,log,keystore}
    cp $HOME/.local/share/bevm/chains/bevm/network/secret_ed25519 $HOME/.bevm/data/chains/bevm/network/secret_ed25519
}

function install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "Docker is not installed. Installing Docker..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo usermod -aG docker $USER
        echo "Docker installed successfully"
    else
        echo "Docker is already installed"
    fi
}

function prepate_config() {
    echo "Preparing config file..."
    cat > $HOME/.bevm/config.json <<EOF
{
  "chain": "testnet",
  "log-dir": "/log",
  "enable-console-log": true,
  "no-mdns": true,
  "validator": true,
  "unsafe-rpc-external": true,
  "offchain-worker": "when-authority",
  "rpc-methods": "unsafe",
  "log": "info,runtime=info",
  "port": 30333,
  "rpc-port": 8087,
  "pruning": "archive",
  "db-cache": 2048,
  "name": "$nodename",
  "base-path": "/data",
  "telemetry-url": "wss://telemetry-testnet.bevm.io/submit 1",
  "bootnodes": []
}
EOF
    echo "Config file prepared successfully"
}

function pull_and_start_docker() {
    sudo docker pull btclayer2/bevm:testnet-v0.1.3
    if [[ $(sudo docker ps -q -f name=bevm-node) ]]; then
        sudo docker stop bevm-node
        sudo docker rm bevm-node
    fi
    sudo docker run -d --restart always --name bevm-node \
    -p 8987:8087 -p 39333:30333 \
    -v $HOME/.bevm/config.json:/config.json -v $HOME/.bevm/data:/data \
    -v $HOME/.bevm/:/log -v $HOME/.bevm/keystore:/keystore \
    btclayer2/bevm:testnet-v0.1.3 /usr/local/bin/bevm \
    --config /config.json
}


function main {
    colors
    line
    logo
    line
    output "Checking old BEVM installation..."
    stop_service bevmd
    migrate_data
    line
    output "Checking Docker installation..."
    install_docker
    line
    output "Preparing BEVM config..."
    prepate_config
    line
    output "Starting BEVM..."
    pull_and_start_docker
    line
    output "BEVM updated successfully"
    output "To check logs run:"
    output_normal "sudo docker logs --tail=100 -f bevm-node"
    output "To restart BEVM run:"
    output_normal "sudo docker restart bevm-node"
    output "To check node status visit and find your nodename $nodename:"
    output_normal "https://telemetry-testnet.bevm.io/#list/0x309a090992035428553a9b85209cc3c1c0aa8e03030aac6ed4a7d75f37f1b362"
    line
    output "Wish lifechange case with DOUBLETOP"
}

main