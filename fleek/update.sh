#!/bin/bash

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/lgtn.service
[Unit]
Description=Fleek Network Node lightning service

[Service]
User=$USER
Type=simple
MemoryHigh=32G
RestartSec=15s
Restart=always
ExecStart=lgtn -c $HOME/lightning/lightning.toml run
StandardOutput=append:/var/log/lightning/output.log
StandardError=append:/var/log/lightning/diagnostic.log
Environment=TMPDIR=/var/tmp

[Install]
WantedBy=multi-user.target
EOF


mkdir -p /var/log/lightning/

sudo systemctl daemon-reload
sudo systemctl enable lgtn
sudo systemctl restart lgtn
}

sudo systemctl stop lgtn

wget -O /usr/local/bin/lgtn https://doubletop-bin.ams3.digitaloceanspaces.com/fleek/testnet-alpha-0/lightning-node

chmod +x /usr/local/bin/lgtn

systemd