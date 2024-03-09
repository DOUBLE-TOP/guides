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

function request_rpc() {
    if [ -z "$SEPOLIA_RPC" ]; then
        echo "It is recommended to use one of the following RPC URLs for Sepolia:"
        echo "1. https://1rpc.io/sepolia"
        echo "2. https://ethereum-sepolia.publicnode.com/"
        echo "3. https://rpc.ankr.com/eth_sepolia"
        echo "4. Enter custom RPC URL(find one on the website: https://chainlist.org/chain/11155111)"
        echo
        read -p "Please select an option (1-4): " SEPOLIA_RPC_OPTION
        case $SEPOLIA_RPC_OPTION in
            1) SEPOLIA_RPC="https://1rpc.io/sepolia" ;;
            2) SEPOLIA_RPC="https://ethereum-sepolia.publicnode.com/" ;;
            3) SEPOLIA_RPC="https://rpc.ankr.com/eth_sepolia" ;;
            4) read -p "Please enter your custom Sepolia RPC URL: " SEPOLIA_RPC ;;
            *) echo "Invalid option selected. Please run the script again and select a valid option."; exit 1 ;;
        esac
        echo "Selected RPC URL: $SEPOLIA_RPC"
        export SEPOLIA_RPC
    fi
}

function stop_service() {
    if [[ $(systemctl is-active $1) == "active" ]]; then
        sudo systemctl stop $1
        sudo systemctl disable $1
    fi
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
        docker_compose_version=v2.16.0
        sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
        chmod +x /usr/bin/docker-compose
        echo "Docker installed successfully"
    else
        echo "Docker is already installed"
    fi
}

function clone_repo {
    if [ ! -d "$HOME/masa-oracle/" ]; then
        git clone https://github.com/masa-finance/masa-oracle.git "$HOME/masa-oracle"
    else
        echo "An old directory was found. Do you want to first remove the node and then reinstall it? (y/n)"
        read -p "" response
        if [[ "$response" == "y" || "$response" == "Y" ]]; then
            docker-compose -f $HOME/masa-oracle/docker-compose.yaml down
            rm -rf "$HOME/masa-oracle/"
            git clone https://github.com/masa-finance/masa-oracle.git "$HOME/masa-oracle"
            echo "The old directory has been removed and the installation has started anew."
        else
            echo "Installation cancelled. The existing directory was kept."
            exit 1
        fi
    fi
}

function prepare_env {
    echo ENV=test > $HOME/masa-oracle/.env
    echo RPC_URL=$SEPOLIA_RPC >> $HOME/masa-oracle/.env
    echo BOOTNODES=/ip4/35.223.224.220/udp/4001/quic-v1/p2p/16Uiu2HAmPxXXjR1XJEwckh6q1UStheMmGaGe8fyXdeRs3SejadSa >> $HOME/masa-oracle/.env
}

function start_masa {
    mkdir -p $HOME/masa-oracle/.masa-keys/
    sudo chown -R 1000.1000 $HOME/masa-oracle/.masa-keys/
    sed -i 's/8080:8080/48080:8080/g' $HOME/masa-oracle/docker-compose.yaml
    docker-compose -f $HOME/masa-oracle/docker-compose.yaml up -d --build
}

function get_public_key {
    sleep 10
    public_key=$(docker-compose -f $HOME/masa-oracle/docker-compose.yaml logs --tail=500 | grep "Public Key" | awk '{print $NF}')
}

function main {
    colors
    line
    logo
    line
    request_rpc
    line
    output "Installing Docker..."
    install_docker
    line
    output "Cloning masa-finance repository..."
    clone_repo
    prepare_env
    line
    output "Starting MASA Oracle..."
    stop_service masa
    start_masa
    output "MASA Oracle installed successfully"
    line
    get_public_key
    output "MASA Oracle Validator's Public Key:"
    echo $public_key
    line
    output "Use faucet in google form to get tokens:"
    echo https://forms.gle/NWJ8B12Tr2Pyvxkz7
    line
    output "Useful commands:"
    output_normal "Show logs:"
    output_normal "docker-compose -f $HOME/masa-oracle/docker-compose.yaml logs -f --tail=100"
    output_normal "Restart node:"
    output_normal "docker-compose -f $HOME/masa-oracle/docker-compose.yaml restart"
    line
    output "Wish lifechange case with DOUBLETOP"
}

main