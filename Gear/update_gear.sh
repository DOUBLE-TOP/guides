#!/bin/bash


source $HOME/.profile
sudo systemctl stop gear
/root/gear purge-chain -y

wget https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz
sudo tar -xvf gear-nightly-linux-x86_64.tar.xz -C /root
rm gear-nightly-linux-x86_64.tar.xz


sudo systemctl start gear

sleep 15

NODENAME_GEAR=$(grep -Po '(?<=--name\s)\S+(?=\s*--execution)' /etc/systemd/system/gear.service)

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
        --in-peers 200 \
        --out-peers 200


Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

# cd /root/.local/share/gear/chains
# mkdir -p gear_staging_testnet_v7/network/
# sudo cp gear_staging_testnet_v6/network/secret_ed25519 gear_staging_testnet_v7/network/secret_ed25519  &>/dev/null


sudo systemctl daemon-reload
sudo systemctl restart gear
