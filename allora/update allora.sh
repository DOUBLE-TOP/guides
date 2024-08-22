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
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
