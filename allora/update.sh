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

# sudo apt update -y && sudo apt upgrade -y
# sudo apt install ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev pkg-config lsb-release libreadline-dev libffi-dev gcc screen unzip lz4 -y
# sudo apt install python3 python3-pip -y

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
mkdir -p worker-data
mkdir -p head-data
sudo chmod -R 777 worker-data head-data

sudo docker run -it --entrypoint=bash -v $(pwd)/head-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"
sudo docker run -it --entrypoint=bash -v $(pwd)/worker-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

HEAD_ID=$(cat head-data/keys/identity)
rm -rf docker-compose.yml 

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/docker-compose.yml
sed -i "s|HEAD_ID|$HEAD_ID|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|WALLET_SEED_PHRASE|$WALLET_SEED_PHRASE|" $HOME/basic-coin-prediction-node/docker-compose.yml


docker-compose build
docker-compose up -d

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
