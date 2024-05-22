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
    git checkout v0.2.14
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
    pruning_interval="19"
    EXTERNAL_IP=$(wget -qO- eth0.me)
    PROXY_APP_PORT=14658
    P2P_PORT=14656
    PPROF_PORT=14060
    API_PORT=14317
    GRPC_PORT=14090
    RPC_PORT=14657
    GRPC_WEB_PORT=14091
    SEEDS=ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:25756,2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756
    PEERS=27811bb5e1aad01bfbe7d780a23a00d7760deb8d@195.201.9.32:37656,915e9775c93112ab3362d2b7c91c493f56645741@65.109.106.113:26656,c7f31a2ea94e9b39421b2e701a31c7c2fac986f9@37.27.123.237:26656,2692225700832eb9b46c7b3fc6e4dea2ec044a78@34.126.156.141:26656,9e6688ea4901d8e1fb4790f72b132c9132f0b5dc@95.216.195.47:26656,2217df9e5719495992642554682a5c7ab37e5373@37.27.123.239:26656,800906416ec13ec86c005de72bdc7fc5200572eb@171.247.185.179:26666,769b90d0c4c4cedb5d0b8d6a3627a5792b4c8519@5.78.98.32:17956,8e899fc8783c76fa69cb418ace1f1e0368b56746@84.247.129.34:26656,e890a8424001b51214bd5bfbad131e5c3e8f6a7f@158.220.104.83:26656,634b4dd8ad6946e6d1ef4f7f6927c90eba3c42b8@85.10.201.125:17956,843ca2035eb083a1627bf11024385bca647e8f4b@194.163.171.100:26656,26c9295341e6c9784c40b5200e075a7036bf3213@158.220.82.142:53456,0e8a332206dc2c42dc8b48ed7ab26b4f76007535@144.76.14.158:20765,2f72cacc2038f22b7652f3c75e52e285f9e9b801@158.220.103.170:26656,2386ce79b98515184d1477ff67e50b41cd6df9f0@65.108.234.158:26606,66abd758f6971eb8227fc54d11cb56ca1ca280e6@65.109.113.251:13656,65ba81c582442f6e5d364d739cb015100b4078ff@37.27.123.242:26656,5d89ba18ead9d632e5dbc29782ffaeaf93418242@124.156.218.78:26656,df3c89aa5bb7b7a29ec72243873cf1d2d8d3cb60@37.27.43.255:17956,df2b15143dcb2c2afc8380396aaa871e8e9fa6da@217.76.58.26:26656,6a6d164766341e4e4f56d0359f130a757f21851a@95.217.148.179:29656,f4d6ffc7ac7c9d063bcd05af6ec3d18c9f2497ed@149.102.128.41:26656,b6227a9680371ba68cccc29abd232b29e4bba5ea@158.220.101.185:26656,27171b4a6a452cbaac07c09e2ac1062db5af7d62@37.27.40.62:17956,4de71d3e17c550c79913ebdb69f4a543b89e82ab@138.201.142.39:26656,d6933cdec759d3c6be37d630bc484dd6d6d73e18@128.199.34.115:26656,4409ca646c6a92c1a24244dc8a8999d43ed9ac5a@84.247.160.145:26656,62775997caa3d814c5ad91492cb9d411aea91c58@51.38.53.103:26856,ab69ff6da9eb9eeb4261d2e3ab9828b01818cb4f@84.247.131.229:26656,2982e096677fb2bd23b8989b56e10d4e07a3c8f4@158.220.100.221:26656,4d0712cdcd931e108bd74d59d2f3b38f2a5f79b1@178.18.247.81:26656,75588c9d6ece63d0e2631244368c5c1a218f7a17@167.235.115.119:26656,d8d4b5a15d96368a295573e5cf391001d5f4b974@62.72.44.146:26656,4a21ae15f8f0cb4b8061fcdeb29c68d77a42ffe9@109.123.250.247:26656,499480379edf02bd92784284b850985963b156ad@37.27.59.245:27656
    STAKETAB_PEER=c36f8ae42381403d93e9be3fb637eb6c19c1ebce@46.4.87.147:4001
    sed -i -e 's|^persistent_peers *=.*|persistent_peers = "'$STAKETAB_PEER','$PEERS'"|' $HOME/.initia/config/config.toml
    sed -i -e 's|^seeds *=.*|seeds = "'$SEEDS'"|' $HOME/.initia/config/config.toml
    curl -Ls https://snapshots.kjnodes.com/initia-testnet/genesis.json > $HOME/.initia/config/genesis.json
    curl -Ls https://snapshots.kjnodes.com/initia-testnet/addrbook.json > $HOME/.initia/config/addrbook.json
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
    sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit\"|" $HOME/.initia/config/app.toml

}

function prepare_node {
    mkdir -p $HOME/.initia/cosmovisor/genesis/bin
    mkdir -p $HOME/.initia/cosmovisor/upgrades
    cp $HOME/go/bin/initiad $HOME/.initia/cosmovisor/genesis/bin
}

function snap_node {
    curl -L https://snapshots.kjnodes.com/initia-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.initia
### Thanks kjnodes for high-quality snapshots ###
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

function check {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/initia/check.sh)
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
    snap_node
    prepare_systemd
    line
    output_normal "Installation complete"
    line
    output "Cheking node Initia"
    line
    check
    line
    output "Wish lifechange case with DOUBLETOP"
}

main
