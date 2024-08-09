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

cp config.example.json config.json

sed -i "s|8000:8000|18000:8000|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|addressKeyName\": \"test\"|addressKeyName\": \"testkey\"|" $HOME/basic-coin-prediction-node/config.json
sed -i "s|addressRestoreMnemonic\": \"\"|addressRestoreMnemonic\": \"$WALLET_SEED_PHRASE\"|" $HOME/basic-coin-prediction-node/config.json

docker-compose build
docker-compose up -d

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"