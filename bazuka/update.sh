#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

source $HOME/.profile

sudo systemctl stop bazuka

cd bazuka
git pull origin master
cargo build
cargo install --path .

sudo tee <<EOF >/dev/null /etc/systemd/system/bazuka.service
[Unit]
Description=Zeeka node
After=network.target

[Service]
User=$USER
ExecStart=`RUST_LOG=info which bazuka` node --listen 0.0.0.0:8765 --external $(wget -qO- eth0.me):8765 --network debug --db ~/.bazuka-debug --bootstrap 152.228.155.120:8765 --bootstrap 5.161.152.123:8765 --bootstrap 65.108.201.41:8765 --bootstrap 185.213.25.229:8765 --bootstrap 45.88.106.199:8765 --bootstrap 148.251.1.124:8765 --bootstrap 195.54.41.115:8765 --bootstrap 195.54.41.130:8765
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart bazuka

echo "-----------------------------------------------------------------------------"
echo "Нода Обновлена"
echo "-----------------------------------------------------------------------------"
