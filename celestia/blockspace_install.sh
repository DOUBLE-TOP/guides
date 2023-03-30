#!/bin/bash



function get_nodename {
    if [ -z $NODENAME_BLOCKSPACE ]; then
        read -p "Enter your node name: " NODENAME_BLOCKSPACE
        echo 'export NODENAME_BLOCKSPACE='$NODENAME_BLOCKSPACE >> $HOME/.profile
    fi
}

function install_dependencies {
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)
    source $HOME/.profile
}

function source_build_code {
    cd $HOME
    if [ -d "$HOME/celestia-node" ]; then
        rm -rf "$HOME/celestia-node"
    fi

    git clone https://github.com/celestiaorg/celestia-node.git
    cd $HOME/celestia-node
    git checkout tags/v0.8.0
    make build
    make install
    make cel-key
    cp cel-key /usr/local/bin/cel-key
}

function create_key_for_node {
    cel-key add $NODENAME_BLOCKSPACE --keyring-backend test --node.type light --p2p.network blockspacerace > $HOME/$NODENAME_BLOCKSPACE.blockspace_wallet.txt 2>&1
}

function initialize_node {
    celestia light init --keyring.accname $NODENAME_BLOCKSPACE --p2p.network blockspacerace
}

function create_service {
    sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd Light Node
After=network-online.target
 
[Service]
User=$USER
ExecStart=/usr/local/bin/celestia light start --rpc.port 46658 \
--core.ip https://grpc-blockspacerace.pops.one/ \
--core.grpc.port 49090 \
--gateway --gateway.addr localhost --gateway.port 46659 \
--p2p.network blockspacerace \
--metrics.tls=false --metrics --metrics.endpoint otel.celestia.tools:4318
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
 
[Install]
WantedBy=multi-user.target
EOF
}


get_nodename
install_dependencies
source_build_code
create_key_for_node
initialize_node
create_service

sudo systemctl enable celestia-lightd
sudo systemctl restart celestia-lightd
