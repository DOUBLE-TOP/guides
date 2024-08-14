#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Обновление Allora CLI"
echo "-----------------------------------------------------------------------------"

source .profile

cd basic-coin-prediction-node
docker compose down -v
cd $HOME
rm -rf allora-chain/ basic-coin-prediction-node/

cd $HOME && git clone https://github.com/allora-network/allora-chain.git
cd allora-chain && make all
cd $HOME && source .profile
allorad version

echo "-----------------------------------------------------------------------------"
echo "Восстановление кошелька Allora"
echo "-----------------------------------------------------------------------------"

allorad keys add testkey --recover

echo "-----------------------------------------------------------------------------"
echo "Установка воркера Allora"
echo "-----------------------------------------------------------------------------"

echo "Введите сид фразу от кошелька, который будет использоваться для воркера"
read WALLET_SEED_PHRASE

cd $HOME
git clone https://github.com/allora-network/basic-coin-prediction-node
cd basic-coin-prediction-node
rm -rf config.json

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/config.json
sed -i "s|SeedPhrase|$WALLET_SEED_PHRASE|" $HOME/basic-coin-prediction-node/config.json


chmod +x init.config
./init.config

sed -i "s|8000:8000|18000:8000|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|intervals = [\"1d\"]|intervals = [\"10m\", \"20m\", \"1h\", \"1d\"]|" $HOME/basic-coin-prediction-node/model.py

docker compose up -d --build

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
