#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Установка Allora Worker"
echo "-----------------------------------------------------------------------------"

echo "Введите сид фразу от кошелька, который будет использоваться для воркера"
read WALLET_SEED_PHRASE

cd $HOME
git clone https://github.com/allora-network/basic-coin-prediction-node
cd basic-coin-prediction-node
rm -rf config.json

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/config.json
sed -i "s|SeedPhrase|$WALLET_SEED_PHRASE|" $HOME/basic-coin-prediction-node/config.json
sed -i "s|\":8000|\":18000|" $HOME/basic-coin-prediction-node/config.json


chmod +x init.config
./init.config

sed -i "s|\"8000:8000|\"18000:8000|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|intervals = [\"1d\"]|intervals = [\"10m\", \"1d\", \"10m\", \"1d\", \"10m\", \"1d\", \"20m\", \"20m\", \"20m\"]|" $HOME/basic-coin-prediction-node/model.py

export COMPOSE_PROJECT_NAME=worker1
docker compose up -d --build

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
