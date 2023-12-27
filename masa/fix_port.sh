#!/bin/bash
sudo tee <<EOF >/dev/null /etc/systemd/system/masa.service
[Unit]
Description=Masa Node
After=network.target
[Service]
Type=simple
User=$USER
Environment="PORT=28080"
WorkingDirectory=$HOME/masa-oracle-go-testnet/
ExecStart=$HOME/masa-oracle-go-testnet/masa-node \
        --port=28081 \
        --udp=true \
        --tcp=false \
        --start=true
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload &>/dev/null
sudo systemctl restart masa &>/dev/null
