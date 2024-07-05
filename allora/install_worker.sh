#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Установка Allora Worker"
echo "-----------------------------------------------------------------------------"

echo "Введите сид фразу от кошелька, который будет использоваться для воркера"
read seed_phrase

cd $HOME && git clone https://github.com/allora-network/basic-coin-prediction-node

cd basic-coin-prediction-node

mkdir worker-data
mkdir head-data
sudo chmod -R 777 worker-data
sudo chmod -R 777 head-data

sudo docker run -it --entrypoint=bash -v ./head-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

sudo docker run -it --entrypoint=bash -v ./worker-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

sleep 10

HEAD_ID=$(cat head-data/keys/identity)
rm -rf docker-compose.yml 

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/docker-compose.yml

sed -i "s|ALLORA_HEAD_ID|$HEAD_ID|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|ALLORA_MNEMONIC|$seed_phrase|" $HOME/basic-coin-prediction-node/docker-compose.yml


docker compose build
docker compose up -d

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"