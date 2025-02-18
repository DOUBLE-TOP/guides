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
sed -i '/^WorkingDirectory=/a AmbientCapabilities=CAP_NET_BIND_SERVICE\nCapabilityBoundingSet=CAP_NET_BIND_SERVICE' /etc/systemd/system/pop.service

sudo systemctl daemon-reload
sudo systemctl enable pop
sudo systemctl start pop

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
