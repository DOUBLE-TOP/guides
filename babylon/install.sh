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

function get_nodename {
    # source $HOME/.profile
    # sleep 1
    # if [ ! ${BABYLON_MONIKER} ]; then
    echo -e "${YELLOW}Введите имя ноды(придумайте)${NORMAL}"
    line
    read BABYLON_MONIKER
    echo 'export BABYLON_MONIKER='$BABYLON_MONIKER >> $HOME/.profile
    # fi
}

function install_go {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)
    source $HOME/.profile
    sleep 1
}

function source_build_git {
    cd $HOME
    rm -rf babylon
    git clone https://github.com/babylonchain/babylon.git
    cd babylon
    git checkout v0.7.2

    make build

    mkdir -p $HOME/.babylond/cosmovisor/genesis/bin
    mv build/babylond $HOME/.babylond/cosmovisor/genesis/bin/
    rm -rf build

    sudo ln -s $HOME/.babylond/cosmovisor/genesis $HOME/.babylond/cosmovisor/current -f
    sudo ln -s $HOME/.babylond/cosmovisor/current/bin/babylond /usr/local/bin/babylond -f

    go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0
}

function systemd {
    sudo tee /etc/systemd/system/babylon.service > /dev/null << EOF
[Unit]
Description=babylon node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.babylond"
Environment="DAEMON_NAME=babylond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.babylond/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable babylon.service
}

function init_chain {
    babylond config chain-id bbn-test-2
    babylond config keyring-backend test
    babylond config node tcp://localhost:16457

    babylond init $BABYLON_MONIKER --chain-id bbn-test-2

    curl -Ls https://snapshots.kjnodes.com/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
    curl -Ls https://snapshots.kjnodes.com/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

    sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@babylon-testnet.rpc.kjnodes.com:16459\"|" $HOME/.babylond/config/config.toml

    sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00001ubbn\"|" $HOME/.babylond/config/app.toml

    sed -i \
    -e 's|^pruning *=.*|pruning = "custom"|' \
    -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
    -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
    -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
    $HOME/.babylond/config/app.toml

    sed -i -e "s|^timeout_commit *=.*|timeout_commit = \"10s\"|" $HOME/.babylond/config/config.toml

    sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16466\"%" $HOME/.babylond/config/config.toml
    sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:16417\"%; s%^address = \":8080\"%address = \":16480\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:16490\"%; s%^address = \"localhost:9091\"%address = \"0.0.0.0:16491\"%; s%:8545%:16445%; s%:8546%:16446%; s%:6065%:16465%" $HOME/.babylond/config/app.toml
}

function download_snapshot {
    curl -L https://snapshots.kjnodes.com/babylon-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.babylond
    [[ -f $HOME/.babylond/data/upgrade-info.json ]] && cp $HOME/.babylond/data/upgrade-info.json $HOME/.babylond/cosmovisor/genesis/upgrade-info.json
}

function start {
    sudo systemctl start babylon
}

function main {
    colors
    line
    logo
    line
    get_nodename
    line
    install_go
    source_build_git
    line
    systemd
    line
    init_chain
    line
    download_snapshot
    line
    start
}

main