#!/bin/bash

sudo tee /etc/systemd/system/dill.service > /dev/null << EOF
[Unit]
Description=Dill Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=$1
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable dill.service
sudo systemctl start dill