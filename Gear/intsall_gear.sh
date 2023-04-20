#!/bin/bash

if [ -z $NODENAME_GEAR ]; then
        read -p "Enter your node name: " NODENAME_GEAR
        echo 'export NODENAME='$NODENAME_GEAR >> $HOME/.profile
fi
echo 'your node name: ' $NODENAME_GEAR
sleep 1
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install git mc clang curl jq htop net-tools libssl-dev llvm libudev-dev -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1



wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz &>/dev/null
tar xvf gear-nightly-linux-x86_64.tar.xz &>/dev/null
rm gear-nightly-linux-x86_64.tar.xz &>/dev/null
chmod +x $HOME/gear &>/dev/null


sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/gear.service
[Unit]
Description=Gear Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/gear \
        --name $NODENAME_GEAR \
        --execution wasm \
	--port 31333 \
        --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0' \
	--telemetry-url 'wss://telemetry.doubletop.io/submit 0' \
        --reserved-nodes \
        "/dns4/testnet-validator-node1.gear-tech.io/tcp/30333/p2p/12D3KooWFqktBAWLLvdySqG5QMcxHnpsDi8vjR9rjCxHotXyXn5R" \
        "/dns4/testnet-validator-node2.gear-tech.io/tcp/30333/p2p/12D3KooWN2Rv9aLGqJ1RohQ9HoYe1nf88Np1M56SZvyWi8rGon36" \
        "/dns4/testnet-validator-node3.gear-tech.io/tcp/30333/p2p/12D3KooWEVvqVD2mrLfmgeX1EXZ2caFXXEWWEs4Taa4mWzFUoF34" \
        "/dns4/testnet-validator-node4.gear-tech.io/tcp/30333/p2p/12D3KooWSf2d69w7RYKtj9mgYpLDs3rqLAz9GHNSHHoCQDLUjeiP" \
        --in-peers 200 \
        --out-peers 200


Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable gear &>/dev/null
sudo systemctl restart gear &>/dev/null