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

function get_nodename {
    if [ ! ${INITIA_NODENAME} ]; then
        line
        read INITIA_NODENAME
    fi
    echo 'export INITIA_NODENAME='$INITIA_NODENAME >> $HOME/.profile
}

function source_git {
    git clone https://github.com/initia-labs/initia $HOME/initia
    cd $HOME/initia
    git checkout v0.2.11
    make install
}

function install_go {
    sudo rm -rvf /usr/local/go/
    wget https://golang.org/dl/go1.21.1.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
    rm go1.21.1.linux-amd64.tar.gz

    echo "export GOROOT=/usr/local/go" >> $HOME/.profile 
    echo "export GOPATH=$HOME/go" >> $HOME/.profile 
    echo "export GO111MODULE=on" >> $HOME/.profile 
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.profile 
    source $HOME/.profile
}

function install_cosmovisor {
    go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
}

function install_main_tools {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
}

function init_node {
    initiad init $INITIA_NODENAME --chain-id initiation-1
}

function config_node {
    pruning="custom"
    pruning_keep_recent="100"
    pruning_keep_every="0"
    pruning_interval="10"
    EXTERNAL_IP=$(wget -qO- eth0.me)
    PROXY_APP_PORT=14658
    P2P_PORT=14656
    PPROF_PORT=14060
    API_PORT=14317
    GRPC_PORT=14090
    RPC_PORT=14657
    GRPC_WEB_PORT=14091
    PEERS="6c50666c45e8a86e04af84b0dcef29469ce284be@213.199.40.241:53456,1677252f64d728aa9598cb7365f74af7c862d9df@65.109.57.221:25756,5f934bd7a9d60919ee67968d72405573b7b14ed0@65.21.202.124:29656,04f0d493cb02a43d85b4fcd4bafd171500a433a0@162.55.27.107:46656,31da678c571c34cef11612d1ef166b9ea32829f4@149.50.96.124:39656"
    SEEDS="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:25756"
    wget -O genesis.json https://snapshots.polkachu.com/testnet-genesis/initia/genesis.json --inet4-only
    mv genesis.json $HOME/.initia/config
    sed -i 's/seeds = ""/seeds = "ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:25756"/' $HOME/.initia/config/config.toml
    wget -O addrbook.json https://snapshots.polkachu.com/testnet-addrbook/initia/addrbook.json --inet4-only
    mv addrbook.json $HOME/.initia/config
    sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.initia/config/app.toml
    sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml

    sed -i \
        -e "s/\(proxy_app = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$PROXY_APP_PORT\"/" \
        -e "s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$RPC_PORT\"/" \
        -e "s/\(pprof_laddr = \"\)\([^:]*\):\([0-9]*\).*/\1localhost:$PPROF_PORT\"/" \
        -e "/\[p2p\]/,/^\[/{s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$P2P_PORT\"/}" \
        -e "/\[p2p\]/,/^\[/{s/\(external_address = \"\)\([^:]*\):\([0-9]*\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/; t; s/\(external_address = \"\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/}" \
        $HOME/.initia/config/config.toml
    sed -i \
        -e "/\[api\]/,/^\[/{s/\(address = \"tcp:\/\/\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$API_PORT\4/}" \
        -e "/\[grpc\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_PORT\4/}" \
        -e "/\[grpc-web\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_WEB_PORT\4/}" $HOME/.initia/config/app.toml

    sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.initia/config/config.toml
    sed -i -e "s|^node *=.*|node = \"tcp://localhost:14657\"|" $HOME/.initia/config/client.toml
}

function prepare_node {
    mkdir -p $HOME/.initia/cosmovisor/genesis/bin
    mkdir -p $HOME/.initia/cosmovisor/upgrades
    cp $HOME/go/bin/initiad $HOME/.initia/cosmovisor/genesis/bin
}

function prepare_systemd {
    sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
    sudo systemctl restart systemd-journald

    sudo tee /etc/systemd/system/initia.service > /dev/null <<EOF
[Unit]
Description="initia node"
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment="DAEMON_NAME=initiad"
Environment="DAEMON_HOME=$HOME/.initia"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable initia
    sudo systemctl restart initia
}

function main {
    colors
    line
    logo
    line
    output "Welcome to the Initia installation script"
    line
    output "Enter your nodename"
    get_nodename
    line
    output "Installing Initia..."
    line
    install_main_tools
    install_go
    install_cosmovisor
    source_git
    init_node
    config_node
    prepare_node
    prepare_systemd
    line
    output_normal "Installation complete"
    line
    output "Wish lifechange case with DOUBLETOP"
}

main
