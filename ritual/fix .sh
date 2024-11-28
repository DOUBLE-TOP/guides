#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

docker compose -f infernet-container-starter/deploy/docker-compose.yaml down

sed -i 's|ritualnetwork/infernet-node:.*|ritualnetwork/infernet-node:1.4.0|' $HOME/infernet-container-starter/deploy/docker-compose.yaml

docker compose -f infernet-container-starter/deploy/docker-compose.yaml up -d

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"