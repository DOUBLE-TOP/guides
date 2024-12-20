#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Установка Allora Worker - Basic Coin Prediction Node"
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
git clone https://github.com/allora-network/basic-coin-prediction-node
cd basic-coin-prediction-node
rm -rf config.json

wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/allora/config.json
sed -i "s|SeedPhrase|$ALLORA_SEED_PHRASE|" $HOME/basic-coin-prediction-node/config.json
ip_address=$(hostname -I | awk '{print $1}') >/dev/null
sed -i "s|inference:|$ip_address:|" $HOME/basic-coin-prediction-node/config.json

sudo tee $HOME/basic-coin-prediction-node/.env > /dev/null <<EOF
TOKEN=ETH
TRAINING_DAYS=30
TIMEFRAME=4h
MODEL=SVR
REGION=US
DATA_PROVIDER=Coingecko
CG_API_KEY=$COIN_GECKO_API_KEY
EOF

sleep 5

sed -i "s|\"8000:8000|\"18000:8000|" $HOME/basic-coin-prediction-node/docker-compose.yml
sed -i "s|alloranetwork/allora-offchain-node:.*|alloranetwork/allora-offchain-node:v0.8.0|" $HOME/basic-coin-prediction-node/docker-compose.yml

chmod +x init.config
./init.config

sleep 5

docker compose up -d --build

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
