#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

cd $HOME/nwaku-compose

docker compose down

sed -i 's|127.0.0.1:8003:8003|127.0.0.1:8333:8003|' $HOME/nwaku-compose/docker-compose.yml
sed -i 's|- 80:80|- 1989:80|' $HOME/nwaku-compose/docker-compose.yml

docker compose up -d

systemctl stop pop
rm -rf /etc/systemd/system/pop.service
sudo tee /etc/systemd/system/pop.service > /dev/null << EOF
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=$HOME/opt/dcdn/pop --ram=4 --pubKey $PUB_KEY --max-disk 100 --cache-dir $HOME/opt/dcdn/download_cache
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node
WorkingDirectory=$HOME/opt/dcdn
AmbientCapabilities=CAP_NET_BIND_SERVICE CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable pop
sudo systemctl start pop


echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
