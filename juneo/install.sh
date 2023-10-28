#!/bin/bash 
git clone https://github.com/Juneo-io/juneogo-binaries

mkdir -p $HOME/.juneogo/plugins

chmod +x $HOME/juneogo-binaries/juneogo
chmod +x $HOME/juneogo-binaries/plugins/jevm

cp $HOME/juneogo-binaries/plugins/jevm $HOME/.juneogo/plugins/
sudo cp $HOME/juneogo-binaries/juneogo /usr/local/bin/

sudo tee <<EOF >/dev/null /etc/systemd/system/juneo.service
[Unit]
Description=Juneo Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/juneogo
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable juneo
sudo systemctl restart juneo