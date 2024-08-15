#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление Allora RPC"
echo "-----------------------------------------------------------------------------"

cd basic-coin-prediction-node
docker compose down -v

sed -i "s|sentries|allora|" $HOME/basic-coin-prediction-node/model.py

chmod +x init.config
sudo ./init.config

docker compose up -d

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"