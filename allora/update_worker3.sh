#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Обновление Allora Worker - Reputer Node"
echo "-----------------------------------------------------------------------------"

source $HOME/.profile

if [ -z "$ALLORA_SEED_PHRASE" ]; then
    echo "Введите сид фразу от кошелька, который будет использоваться для воркера"
    read ALLORA_SEED_PHRASE
    echo "export ALLORA_SEED_PHRASE='$ALLORA_SEED_PHRASE'" >> $HOME/.profile
fi

if [ -z "$COIN_GECKO_API_KEY" ]; then
    echo "Введите COINGECKO API KEY"
    read COIN_GECKO_API_KEY
    echo "export COIN_GECKO_API_KEY='$COIN_GECKO_API_KEY'" >> $HOME/.profile
fi

docker-compose -f $HOME/basic-coin-prediction-node/docker-compose.yml down -v &>/dev/null
docker-compose -f $HOME/allora-huggingface-walkthrough/docker-compose.yaml down -v  &>/dev/null
docker-compose -f $HOME/allora-worker-x-reputer/allora-node/docker-compose.yaml down -v &>/dev/null

cd $HOME
rm -rf allora-worker-x-reputer

git clone https://github.com/0xtnpxsgt/allora-worker-x-reputer.git
cd allora-worker-x-reputer
chmod +x init.sh
bash init.sh

cd allora-node
chmod +x ./init.config.sh
bash init.config.sh "testkey" "$ALLORA_SEED_PHRASE" "$COIN_GECKO_API_KEY"

sed -i "s|8001:8001|18001:8001|" $HOME/allora-worker-x-reputer/allora-node/docker-compose.yaml
sed -i "s|8002:8002|18002:8002|" $HOME/allora-worker-x-reputer/allora-node/docker-compose.yaml
sed -i "s|8003:8003|18003:8003|" $HOME/allora-worker-x-reputer/allora-node/docker-compose.yaml

docker compose pull
docker compose up --build -d 

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
